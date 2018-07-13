#!/bin/sh

##############################
# Sanity checks
##############################
if [ ! -z $INST_HOME ]
then
  homedir=$INST_HOME
elif [ ! -z $HOME ]
then
  homedir=$HOME
else
  echo "ERROR, \$HOME is not set"
  myexit 1
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

