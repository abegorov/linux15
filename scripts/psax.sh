#!/bin/bash
set -o nounset  # exit immediately on expanding a variable that is not set

CLK_TCK=$(getconf CLK_TCK)

echo '    PID TTY      STAT   TIME COMMAND'

find /proc/ -mindepth 1 -maxdepth 1 -type d -regex '/proc/[0-9]+' \
| while read dir; do

  PID=$(basename "${dir}")

  TTY=""
  if [[ -L "${dir}/fd/0" ]]; then
    TTY=$(readlink "${dir}/fd/0")
    if [[ "${TTY}" != "/dev/null" && "${TTY}" =~ ^/dev/ ]]; then
      TTY="${TTY#/dev/}"
    else
      TTY="?"
    fi
  fi

  PSSTAT=$(cat "${dir}/stat") || continue
  # удаляем всё до последней скопки на случай, если имя процесса содержит
  # пробел или закрывающуюся скобку, пробел в начале важен, чтобы индексы
  # полей соответствовали man proc_pid_stat:
  PSSTAT=" ${PSSTAT#*)}"
  STAT=$(echo "${PSSTAT}" | cut -d ' ' -f 3)
  PGRP=$(echo "${PSSTAT}" | cut -d ' ' -f 5)
  SESSION=$(echo "${PSSTAT}" | cut -d ' ' -f 6)
  TPGID=$(echo "${PSSTAT}" | cut -d ' ' -f 8)
  UTIME=$(echo "${PSSTAT}" | cut -d ' ' -f 14)
  STIME=$(echo "${PSSTAT}" | cut -d ' ' -f 15)
  NICE=$(echo "${PSSTAT}" | cut -d ' ' -f 19)
  THREADS=$(echo "${PSSTAT}" | cut -d ' ' -f 20)
  SECONDS=$(((${UTIME} + ${STIME})/${CLK_TCK}))
  TIMEM=$((${SECONDS}/60))
  TIMES=$((${SECONDS}%60))
  TIME="${TIMEM}:$(printf '%02i' "${TIMES}")"

  # <    high-priority (not nice to other users)
  (( "${NICE}" < 0 )) && STAT="${STAT}<"
  # N    low-priority (nice to other users)
  (( "${NICE}" > 0 )) && STAT="${STAT}N"
  # L    has pages locked into memory (for real-time and custom IO)
  cat "${dir}/status" | grep VmLck: | grep --quiet --invert-match  '\b0' \
    && STAT="${STAT}L"
  # s    is a session leader
  [[ "${PID}" == "${SESSION}" ]] && STAT="${STAT}s"
  # l    is multi‐threaded (using CLONE_THREAD, like NPTL pthreads do)
  (( "${THREADS}" > 1 )) && STAT="${STAT}l"
  # +    is in the foreground process group
  [[ "${TPGID}" -gt 0 && "${PGRP}" == "${TPGID}" ]] && STAT="${STAT}+"

  CMDLINE=$(cat "${dir}/cmdline" | tr '\0' ' ') || continue
  if [[ -z "${CMDLINE}" ]]; then
    CMDLINE="[$(cat "${dir}/status" | grep 'Name:' | cut -d $'\t' -f 2 )]"
  fi

  printf '%7s %-8s %-6s %-4s %s\n' \
    "${PID}" "${TTY}" "${STAT}" "${TIME}" "${CMDLINE}"
done
