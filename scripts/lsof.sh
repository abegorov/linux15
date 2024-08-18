#!/bin/bash
set -o nounset  # exit immediately on expanding a variable that is not set

echo 'COMMAND              PID   UID  FD NAME'

find /proc/ -mindepth 1 -maxdepth 1 -type d -regex '/proc/[0-9]+' \
| while read dir; do
  PID=$(basename "${dir}")
  COMMAND="$(cat "${dir}/status" | grep 'Name:' | cut -d $'\t' -f 2 )" \
    || continue
  USERID="$(cat "${dir}/status" | grep 'Uid:' | cut -d $'\t' -f 2 )" \
    || continue
  find "${dir}/fd/" -mindepth 1 -maxdepth 1 -type l \
  | while read file; do
    FD=$(basename "${file}") || continue
    NAME=$(readlink "${file}") || continue

    printf '%-16s %7s %5s %3s %s\n' \
      "${COMMAND}" "${PID}" "${USERID}" "${FD}" "${NAME}"
  done
done
