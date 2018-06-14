#!/usr/bin/env bash

if ! type 'sudo' > /dev/null 2>&1
then
  echo "nosudo"
  # just guess that we're already root if sudo doesn't exist
  alias sudo=''
fi

# Package Manger Updates
if type 'apt' > /dev/null 2>&1
then
  echo "apt"
  sudo apt update; sudo apt upgrade; sudo apt autoremove
elif type 'aptitude' > /dev/null 2>&1
then
  echo "aptitude"
  sudo aptitude update; sudo aptitude safe-upgrade
elif type 'apt-get' > /dev/null 2>&1
then
  echo "apt-get"
  sudo apt-get update; sudo apt-get upgrade; sudo apt-get autoremove
elif type 'yum' > /dev/null 2>&1
then
  echo "yum"
  sudo yum upgrade
else
  echo "package manager not found"
fi

# golang updates on debian
if type "dpkg" > /dev/null 2>&1
then
  echo "on a deb-based system, checking for go"
  if type "go" > /dev/null 2>&1
  then
    echo "go exists, checking for godeb"
    if type "godeb" > /dev/null 2>&1
    then
      echo "godeb is installed, running it directly"
      echo "  note: if godeb needs updated run go get -u gopkg.in/niemeyer/godeb.v1/cmd/godeb"
      echo "  HOWEVER: you must have access to the current godeb location in your go path"
      godeb install
    elif [ ! -z ${GOPATH+x} ] || [ -d $HOME/go ]
    then
      echo "go appears to be in use, but godeb is not found, installing"
      go get -u gopkg.in/niemeyer/godeb.v1/cmd/godeb
      godeb install
    fi
  fi
fi    

