# Работа с процессами

## Задание

1. Написать свою реализацию **ps ax** используя анализ **/proc**.
2. Написать свою реализацию **lsof**.
3. Дописать обработчики сигналов в прилагаемом скрипте, оттестировать, приложить сам скрипт, инструкции по использованию.
4. Реализовать 2 конкурирующих процесса по **IO**. пробовать запустить с разными **ionice**.
5. Реализовать 2 конкурирующих процесса по **CPU**. пробовать запустить с разными **nice**

## Реализация

Под каждое задание был написан отдельный скрипт. Все скрипты лежат в директории [scripts](scripts/):

1. [psax.sh](scripts/psax.sh) - реализация **ps ax**.
2. [psax.sh](scripts/lsof.sh) - реализация **lsof**.
3. [psax.sh](scripts/trap.sh) - обработчик сигналов.
4. [psax.sh](scripts/psax.sh) - тестирование **ionice** с различными планировщиками **IO**.
5. [psax.sh](scripts/psax.sh) - тестирование **nice**.

Задание сделано на **generic/centos9s** версии **v4.2.12**. После загрузки запускается **Ansible Playbook** [playbook.yml](playbook.yml), который копирует перечисленные скрипты в директорию **/usr/local/sbin/**.

Вывод всех скриптов можно найти в директории [output](output/).

## Запуск

Необходимо скачать **VagrantBox** для **generic/centos9s** версии **v4.2.12** и добавить его в **Vagrant** под именем **generic/centos9s**. Сделать это можно командами:

```shell
curl -OL https://app.vagrantup.com/generic/boxes/centos9s/versions/4.3.12/providers/virtualbox/amd64/vagrant.box
vagrant box add vagrant.box --name "generic/centos9s"
rm vagrant.box
```

После этого нужно сделать **vagrant up**. Все скрипты доступны пользователю **root** и должны запускаться под пользователем **root** без дополнительных аргументов.

Протестировано в **OpenSUSE Tumbleweed**:

- **Vagrant 2.3.7**
- **VirtualBox 7.0.20_SUSE r163906**
- **Ansible 2.17.3**
- **Python 3.11.9**
- **Jinja2 3.1.4**

## psax.sh

Скрипт в точности повторяет вывод команды **ps ax**. В том числе указывается был ли изменён приоритет процесса (**nice**), наличие **IO** в момент его выполнения, является ли процесс лидером сессии и работает ли он в фоне. Вывод скрипта приведён в [psax.log](output/psax.log).

## lsof.sh

Вывод **lsof.sh** упрощён. Скрипт выводит только имя исполняемого файла, его **PID**, реальный идентификатор пользователя, файловый дискриптор и его права доступа, текущую директорию, корневую директорию, исполняемый файл, библиотеки. Вывод скрипт приведён в [lsof.log](output/lsof.log).

## trap.sh

Простой скрипт, который обрабатывает все полученные сигналы. Сигналы можно послать скрипту с помощью команды **kill** (скрипт указывает **PID** процесса, которому нужно послать сигнал), а также нажав **CTRL+C** и **CTRL+Z** после его выполнения. Для завершения скрипта ему нужно послать **SIGKILL**. Например:

```text
[root@proc-scripts ~]# trap.sh
Получен сигнал: SIGCHLD. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
^CПолучен сигнал: SIGINT. PID: 38390.
^ZПолучен сигнал: SIGTSTP. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
Получен сигнал: SIGHUP. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
Получен сигнал: SIGQUIT. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
Получен сигнал: SIGSEGV. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
Получен сигнал: SIGTERM. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
Получен сигнал: SIGUSR1. PID: 38390.
Получен сигнал: SIGSEGV. PID: 38390.
Получен сигнал: SIGCHLD. PID: 38390.
Killed
```

## ionice.sh

Скрипт запускает два процесса, читающие диск **/dev/sda** с различным планировщиками **class** и **storageclass**. Результаты выполнения приведены в файле [ionice.log](output/ionice.log). По результатам видно, что **ionice** работает только с планировщиком **bfq**, которые сейчас редко используется. И даже с **bfq**, он оказывает небольшое влияние (не более 10%). Также заметно, что использование **bfq** снижает производительность **IO**, а установка приоритетов только снижает производительность диска.

## nice.sh

Скрипт запускает два процесса генерации случайных чисел, один без использования **nice**, а другой с **nice** от -20 до 19. Результаты выполнения приведены в файле [nice.log](output/nice.log). Видно, что при одинаковым **nice** у процессов нагрузка распределяется равномерно. Единица в **nice** измеряет это соотношение от 0% до 5% и изменение (на единицу) тем выше, чем ближе **nice** к 0. При этом какое-то влияние на запущенные процессы оказывают только два класса **realtime (1)** и **idle (3)**. При этом приоритет в **realtime** классе не оказывает существенного влияния.
