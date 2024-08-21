#!/bin/bash
set -o errexit  # exit immediately if any untested command fails
set -o nounset  # exit immediately on expanding a variable that is not set

# Создаёт нагрузку на дисковую подсистему в течении 10 секунд и записывает
# количество выполненных операций в указанный файл.
# Arguments:
#   1. Файл, в который нужно записать результаты выполнения.
function load()
{
  local result_file="${1}"
  local counter=0
  start="${SECONDS}"
  while :; do
    echo 3 > /proc/sys/vm/drop_caches
    dd if=/dev/sda of=/dev/null bs=1M count=16 seek=${RANDOM}K status=none
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
    for sched in none mq-deadline kyber bfq; do
      echo ${sched} > /sys/block/sda/queue/scheduler
      for class in {0..3}; do
        for classdata in {0..7}; do
          if [[ ${classdata} == 0 || ${class} == [12] ]]; then
            "${0}" /run/nice_load1 &
            if [[ ${class} == [12] ]]; then
              ionice -c "${class}" -n "${classdata}" "${0}" /run/nice_load2 &
            else
              ionice -c "${class}" "${0}" /run/nice_load2 &
            fi
            wait

            local load1=$(cat /run/nice_load1)
            local load2=$(cat /run/nice_load2)
            local loads=$((${load1} + ${load2}))

            printf "%-11s " "${sched}"
            printf "class=0/0 load=%-4s percent=%-3s | " \
              "${load1}" "$((100*${load1}/${loads}))%"
            printf "class=%1s/%1s load=%-4s percent=%-3s\n" "${class}" \
              "${classdata}" "${load2}" "$((100*${load2}/${loads}))%"
          fi
        done
      done
    done

    # восстановление scheduler:
    echo mq-deadline > /sys/block/sda/queue/scheduler
  fi
}

main "$@"
