#!/bin/sh

if ! command -v 'git' > /dev/null 2>&1; then
  to_install="git"
fi

# TODO: add option to bypass git-crypt
if ! command -v 'git-crypt' > /dev/null 2>&1; then
  to_install="$to_install git-crypt"
fi

if [ -n "$to_install" ]; then
  echo "$to_install not found, attempting to install."
  if ! command -v 'sudo' > /dev/null 2>&1; then
    echo "Sudo not found, assuming root"
    alias sudo=''
  fi

  if command -v 'apt' > /dev/null 2>&1; then
    echo "Using apt"
    sudo apt update && sudo apt install $to_install
  elif command -v 'aptitude' > /dev/null 2>&1; then
    echo "Using aptitude"
    sudo aptitude update && sudo aptitude install $to_install
  elif command -v 'apt-get' > /dev/null 2>&1; then
    echo "Using apt-get"
    sudo apt-get update && sudo apt-get install $to_install
  elif command -v 'yum' > /dev/null 2>&1; then
    echo "Using yum"
    sudo yum install $to_install
  else
    echo "Package manager not recognized, please install git and git-crypt and ensure it's in your path"
    exit 1
  fi

  # Remove any sudo alias if added (quash the error)
  unalias sudo > /dev/null 2>&1
fi

# Cloning mystfull using https
git clone -b bootstrap_wip https://github.com/4wrxb/mystuff.git $HOME/mystuff


# TODO: git-crypt & SSH key

# Set the origin back to ssh
cd $HOME/mystuff
git remote set-url origin git@github.com:4wrxb/mystuff.git

# Launch the install-from-dir in a new shell
cd $HOME/mystuff/home
./Install_from_dir.sh

echo "DONE: Exit all shells and re-open"