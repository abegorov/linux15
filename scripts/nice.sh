#!/bin/bash
set -o errexit  # exit immediately if any untested command fails
set -o nounset  # exit immediately on expanding a variable that is not set

# Создаёт нагрузку на центральный процессор в течении 10 секунд и записывает
# количество выполненных операций генерации 16MiB случайных данных в указанный
# файл.
# Arguments:
#   1. Файл, в который нужно записать результаты выполнения.
function load()
{
  local result_file="${1}"
  local counter=0
  start="${SECONDS}"
  while :; do
    dd if=/dev/urandom of=/dev/null bs=1M count=16 status=none
    ((++counter))
    if ((${SECONDS} - ${start} >= 10)); then break; fi
  done
  echo "${counter}" > "${result_file}"
}

# Основной код скрипта.
function main()
{
  if (($# > 0)); then
    load "${1}"
  else
    for n in {-20..19}; do
      "${0}" /run/nice_load1 &
      nice -n "${n}" "${0}" /run/nice_load2 &
      wait

      local load1=$(cat /run/nice_load1)
      local load2=$(cat /run/nice_load2)
      local loads=$((${load1} + ${load2}))
      printf "nice=0   load=%-4s percent=%-3s | " \
        "${load1}" "$((100*${load1}/${loads}))%"
      printf "nice=%-3s load=%-4s percent=%-3s\n" \
        "${n}" "${load2}" "$((100*${load2}/${loads}))%"
    done
  fi
}

main "$@"
