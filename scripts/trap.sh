#!/bin/bash
set -o nounset  # exit immediately on expanding a variable that is not set

trap "on_signal SIGHUP" SIGHUP
trap "on_signal SIGINT" SIGINT
trap "on_signal SIGQUIT" SIGQUIT
trap "on_signal SIGILL" SIGILL
trap "on_signal SIGTRAP" SIGTRAP
trap "on_signal SIGABRT" SIGABRT
trap "on_signal SIGBUS" SIGBUS
trap "on_signal SIGFPE" SIGFPE
trap "on_signal SIGKILL" SIGKILL
trap "on_signal SIGUSR1" SIGUSR1
trap "on_signal SIGSEGV" SIGSEGV
trap "on_signal SIGUSR2" SIGUSR2
trap "on_signal SIGPIPE" SIGPIPE
trap "on_signal SIGALRM" SIGALRM
trap "on_signal SIGTERM" SIGTERM
trap "on_signal SIGSTKFLT" SIGSTKFLT
trap "on_signal SIGCHLD" SIGCHLD
trap "on_signal SIGCONT" SIGCONT
trap "on_signal SIGSTOP" SIGSTOP
trap "on_signal SIGTSTP" SIGTSTP
trap "on_signal SIGTTIN" SIGTTIN
trap "on_signal SIGTTOU" SIGTTOU
trap "on_signal SIGURG" SIGURG
trap "on_signal SIGXCPU" SIGXCPU
trap "on_signal SIGXFSZ" SIGXFSZ
trap "on_signal SIGVTALRM" SIGVTALRM
trap "on_signal SIGPROF" SIGPROF
trap "on_signal SIGWINCH" SIGWINCH
trap "on_signal SIGIO" SIGIO
trap "on_signal SIGPWR" SIGPWR
trap "on_signal SIGSYS" SIGSYS
trap "on_signal SIGRTMIN" SIGRTMIN
trap "on_signal SIGRTMIN+1" SIGRTMIN+1
trap "on_signal SIGRTMIN+2" SIGRTMIN+2
trap "on_signal SIGRTMIN+3" SIGRTMIN+3
trap "on_signal SIGRTMIN+4" SIGRTMIN+4
trap "on_signal SIGRTMIN+5" SIGRTMIN+5
trap "on_signal SIGRTMIN+6" SIGRTMIN+6
trap "on_signal SIGRTMIN+7" SIGRTMIN+7
trap "on_signal SIGRTMIN+8" SIGRTMIN+8
trap "on_signal SIGRTMIN+9" SIGRTMIN+9
trap "on_signal SIGRTMIN+10" SIGRTMIN+10
trap "on_signal SIGRTMIN+11" SIGRTMIN+11
trap "on_signal SIGRTMIN+12" SIGRTMIN+12
trap "on_signal SIGRTMIN+13" SIGRTMIN+13
trap "on_signal SIGRTMIN+14" SIGRTMIN+14
trap "on_signal SIGRTMIN+15" SIGRTMIN+15
trap "on_signal SIGRTMAX-14" SIGRTMAX-14
trap "on_signal SIGRTMAX-13" SIGRTMAX-13
trap "on_signal SIGRTMAX-12" SIGRTMAX-12
trap "on_signal SIGRTMAX-11" SIGRTMAX-11
trap "on_signal SIGRTMAX-10" SIGRTMAX-10
trap "on_signal SIGRTMAX-9" SIGRTMAX-9
trap "on_signal SIGRTMAX-8" SIGRTMAX-8
trap "on_signal SIGRTMAX-7" SIGRTMAX-7
trap "on_signal SIGRTMAX-6" SIGRTMAX-6
trap "on_signal SIGRTMAX-5" SIGRTMAX-5
trap "on_signal SIGRTMAX-4" SIGRTMAX-4
trap "on_signal SIGRTMAX-3" SIGRTMAX-3
trap "on_signal SIGRTMAX-2" SIGRTMAX-2
trap "on_signal SIGRTMAX-1" SIGRTMAX-1
trap "on_signal SIGRTMAX" SIGRTMAX

# Обработчик сигналов.
# Arguments:
#   1. Полученный сигнал.
function on_signal()
{
  local signal="${1}"
  echo "Получен сигнал: ${signal}. PID: $$."
}

while :; do sleep 5 & wait; done
