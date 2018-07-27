#!/usr/bin/env bash

##############################
# Sanity checks
##############################
sanity_checks_ok=0
if ! . Sanity_checks.sh || [ $sanity_checks_ok -ne "1" ]; then
  echo "The sanity check script failed or could not be found, exiting."
  exit
fi

##############################
# Copy .ssh
##############################
cd "$(dirname "$0")"
if [ -d $HOME/.ssh ]
then
  echo "Moving existing .ssh to .ssh.old"
  m\v $HOME/.ssh $HOME/.ssh.old
fi
cppath=`which cp`
if [ `readlink -f $cppath | grep "busybox"` ]
then
  echo "busybox detected, doing simple cp, check ownership/perms of copied files"
  c\p -iR .ssh $HOME/
else
  c\p -viR --no-preserve=ownership .ssh $HOME/
fi

##############################
# Copy .gitconfig but don't overwrite
##############################
cd "$(dirname "$0")"
cppath=`which cp`
if [ `readlink -f $cppath | grep "busybox"` ]
then
  echo "busybox detected, doing simple cp, check ownership/perms of copied files"
  c\p -i .gitconfig $HOME/.gitconfig.new
else
  c\p -vi --no-preserve=ownership .gitconfig $HOME/.gitconfig.new
fi

if [ -f $HOME/.gitconfig ]
then
  echo ".gitconfig exists, leave .gitconfig.new for manual merge"
else
  m\v $HOME/.gitconfig.new $HOME/.gitconfig
fi

##############################
# WSL-specific changes
##############################
#if [ `uname -r`="*Microsoft" ]
#then
  echo "Making WSL speicfic changes"
#fi

##############################
# Now run the injector for includes
##############################
./Include_injector.sh

