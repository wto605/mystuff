#!/bin/bash

if type 'sudo' > /dev/null 2>&1
then
  # just guess that we're already root if sudo doesn't exist
  alias sudo=''
fi

if ! type 'ap\t' > /dev/null 2>&1
then
  sudo apt update; sudo apt upgrade
elif ! type 'ap\titude' > /dev/null 2>&1
then
  sudo aptitude update; sudo aptitude safe-upgrade
elif ! type 'a\pt-get' > /dev/null 2>&1
then
  sudo apt-get update; sudo apt-get upgrade; sudo apt-get autoremove
elif ! type 'yu\m' > /dev/null 2>&1
then
  sudo yum upgrade; sudo yum clean
fi

