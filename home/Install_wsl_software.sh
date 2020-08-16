#!/bin/sh
# Installs software I use on WSL
# Assumes env (including any proxies) already set up
# Does NOT use Sanity_checks.sh since this isn't dependent on most of that

# TODO: compare vs personal WSL setup

if [ ! `uname -r`="*Microsoft" ]; then
  echo "ERROR: this script is intended for WSL only."
  exit 1
fi

# fetch a compiled godeb to bootstrap go, then get the actual godeb for future.
if ! command -v 'go' > /dev/null 2>&1; then
  echo "Go not found, installing for the first time by downloading a compiled godeb."
  c\d /tmp
  wg\et https://godeb.s3.amazonaws.com/godeb-amd64.tar.gz
  ta\r -xzf godeb-amd64.tar.gz
  ./godeb install
  echo "Go installed, now getting and installing the real godeb for future use."
  go get -u gopkg.in/niemeyer/godeb.v1/cmd/godeb
  rm /tmp/godeb*
  rm $HOME/go_*.deb
  rm /tmp/go_*.deb
  
  # If gopath is already being set leave it alone
  if [ -z "$GOPATH" ]; then
    echo '' >> $HOME/.profile
    echo '\nexport GOPATH="$HOME/go"\n' >> $HOME/.profile
  fi
fi

if [ ! -d $HOME/go ]; then
  mkdir $HOME/go
fi

# Set gopath manually so we don't need to re-source anything
if [ -z "$GOPATH" ]; then
  export GOPATH="$HOME/go"
fi

# set up assh through go
if ! command -v 'assh' > /dev/null 2>&1; then
  if ! command -v 'go' > /dev/null 2>&1; then
    echo "assh not found, but nor is go. Did go install successfully? Re-run this script after restarting your shell."
  else
    echo "assh not found, installing."
    go get -u moul.io/assh
    if command -v 'assh' > /dev/null 2>&1; then
      echo "assh successfully installed, building first config and setting the alias (will happen automatically in the future)."
      if [ -f $HOME/.ssh/config ]; then
        mv $HOME/.ssh/config $HOME/.ssh/config_pre_assh
      fi
      assh config build > $HOME/.ssh/config
      chmod 600 $HOME/.ssh/config
      alias ssh='assh wrapper ssh'

      #TODO: prompt before setting up assh devel environment?
      #TODO: generalize the godevel process and call that?
      cd $HOME/go/src/moul.io/assh
      git remote add my-fork git@github.com:4wrxb/assh.git
      git fetch my-fork
      git branch master -u my-fork/master
      git branch upstream_master origin/master
      git fetch my-fork master && git reset --hard FETCH_HEAD
      go install moul.io/assh
    else
      echo "assh failed to install, did NOT set up config file etc.. Please check on your (a)ssh install."
    fi
  fi
fi

# apt install
# GENERAL:
# - git-crypt (probably already done by bootstrap, but harmless to repeat)
# - git-gui (bring gitk and a lot of font/X11 stuff I'll need anyway
# - kdiff3
# - meld
# - perlbrew (gives us some build env too)
# - python3
# - unzip
# - wget
# - zsh
# FOR OPENWRT:
# - build-essential
# - libncurses5-dev
# - libncursesw5-dev
# - python2
# - zlib1g-dev
# - gawk
# - gettext
# - libssl-dev
# - xsltproc
echo "Running apt install through sudo. Enter password if prompted."
sudo apt install git-crypt git-gui kdiff3 meld perlbrew python3 unzip wget zsh build-essential libncurses5-dev libncursesw5-dev python2 zlib1g-dev gawk gettext libssl-dev xsltproc
