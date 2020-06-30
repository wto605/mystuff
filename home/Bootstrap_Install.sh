#!/bin/sh

if ! command -v 'git' > /dev/null 2>&1; then
  echo "git not found, attempting to install."
  if ! command -v 'sudo' > /dev/null 2>&1; then
    echo "Sudo not found, assuming root"
    alias sudo=''
  fi

  if command -v 'apt' > /dev/null 2>&1; then
    echo "Using apt"
    sudo apt update; sudo apt install git
  elif command -v 'aptitude' > /dev/null 2>&1; then
    echo "Using aptitude"
    sudo aptitude update; sudo aptitude install git
  elif command -v 'apt-get' > /dev/null 2>&1; then
    echo "Using apt-get"
    sudo apt-get update; sudo apt-get install git
  elif command -v 'yum' > /dev/null 2>&1; then
    echo "Using yum"
    sudo yum install git
  else
    echo "Package manager not recognized, please install git and ensure it's in your path"
    exit 1
  fi
fi

# Cloning mystfull using https
git clone https://github.com/4wrxb/mystuff.git $HOME/mystuff

# Set the origin back to ssh
cd $HOME/mystuff
git remote set-url origin git@github.com:4wrxb/mystuff.git

# Launch the install-from-dir
cd $HOME/mystuff/home
./Install_from_dir.sh

# TODO: git-crypt
