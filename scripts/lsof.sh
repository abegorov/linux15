#!/bin/bash
set -o nounset   # exit immediately on expanding a variable that is not set
set -o pipefail  # the return value of a pipeline is the status of the last
                 # command to exit with a non-zero status, or zero if no
                 # command exited with a non-zero status

# Печатает на экран строку в нужном формате с информацией о файле,
# которая берётся из переменных среды
function line()
{
  printf '%-27s %7s %5s %3s%-1s %s\n' \
    "${COMMAND}" "${PID}" "${USERID}" "${FD}" "${ACCESS}" "${NAME}"
}

COMMAND='COMMAND'
PID='PID'
USERID='UID'
FD='FD'
ACCESS=''
NAME='NAME'
line

find /proc/ -mindepth 1 -maxdepth 1 -type d -regex '/proc/[0-9]+' \
| while read dir; do
  PID=$(basename "${dir}")
  COMMAND="$(cat "${dir}/status" | grep 'Name:' | cut -d $'\t' -f 2 )" \
    || continue
  USERID="$(cat "${dir}/status" | grep 'Uid:' | cut -d $'\t' -f 2 )" \
    || continue

  ACCESS=''

  FD='cwd'
  NAME=$(readlink "${dir}/cwd") || continue
  line

  FD='rtd'
  NAME=$(readlink "${dir}/root") || continue
  line

  FD='txt'
  NAME=$(readlink "${dir}/exe") || continue
  line

  FD='mem'
  cat "${dir}/maps" | grep --only-matching '/.*' | uniq \
  | while read file; do
    NAME="${file}"
    line
  done

  find "${dir}/fd/" -mindepth 1 -maxdepth 1 -type l \
  | while read file; do

    STAT=$(stat --format='%A' "${file}") || continue
    if [[ ${STAT} =~ ^lrw.+ ]]; then
      ACCESS='u'
    elif [[ ${STAT} =~ ^lr.+ ]]; then
      ACCESS='r'
    elif [[ ${STAT} =~ ^l-w.+ ]]; then
      ACCESS='w'
    else
      ACCESS=''
    fi

    FD=$(basename "${file}") || continue
    NAME=$(readlink "${file}") || continue
    line
  done
done
