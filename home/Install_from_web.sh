#!/bin/sh

waterfall_profile="0"
waterfall_bashrc="0"
waterfall_bash_profile="0"
waterfall_bash_login="0"

if [ -z $HOME ]
then
  echo "ERROR, \$HOME is not set"
  exit 1
fi

mkdir -p $HOME/tmp_web
cd $HOME/tmp_web
if [ wget https://github.com/4wrxb/mystuff/raw/master/home/.will.aliases ]
then
  wget http://github.com/4wrxb/mystuff/raw/master/home/.will.aliases
  wget http://github.com/4wrxb/mystuff/raw/master/home/.will.bashrc
  wget http://github.com/4wrxb/mystuff/raw/master/home/.will.profilei
  wget http://github.com/4wrxb/mystuff/raw/master/home/.ssh/authorized_keys
else
  wget https://github.com/4wrxb/mystuff/raw/master/home/.will.bashrc
  wget https://github.com/4wrxb/mystuff/raw/master/home/.will.profile
  wget https://github.com/4wrxb/mystuff/raw/master/home/.ssh/authorized_keys
fi
chmod 644 .will.*
chmod 600 authorized_keys

if [ ! -d $HOME/.ssh ]
then
  mkdir -p .ssh
  chmod 600 $HOME/.ssh 
fi

mv .will.* $HOME/
mv authorized_keys $HOME/.ssh

cd $HOME
rmdir $HOME/tmp_web

if [ -f $HOME/.profile ]
then
  if result=`g\rep ".will." $HOME/.profile`
  then
    echo ".will.profile may already be included:"
    echo "$result"
    echo "writing .profile.new but not using it, copy yourself if needed"
  else
    waterfall_profile="1"
  fi
  c\p -a $HOME/.profile $HOME/.profile.new
  echo >> $HOME/.profile.new
  echo 'if [ -f "$HOME/.will.profile" ]; then' >> $HOME/.profile.new
  echo '    . "$HOME/.will.profile"' >> $HOME/.profile.new
  echo 'fi' >> $HOME/.profile.new
else
  echo "Creating a .profile to source .will.profile"
  echo 'if [ -f "$HOME/.will.profile" ]; then' > $HOME/.profile
  echo '    . "$HOME/.will.profile"' >> $HOME/.profile
  echo 'fi' >> $HOME/.profile
fi

if [ -f $HOME/.bash_profile ]
then
  if result=`g\rep ".will." $HOME/.bash_profile`
  then
    echo ".will.bash_profile may already be included:"
    echo "$result"
    echo "writing .bash_profile.new but not using it, copy yourself if needed"
  else
    waterfall_bash_profile="1"
  fi
  c\p -a $HOME/.bash_profile $HOME/.bash_profile.new
  echo >> $HOME/.bash_profile.new
  echo 'if [ -f "$HOME/.will.bash_profile" ]; then' >> $HOME/.bash_profile.new
  echo '    . "$HOME/.will.bash_profile"' >> $HOME/.bash_profile.new
  echo 'fi' >> $HOME/.bash_profile.new
fi

if [ -f $HOME/.bash_login ]
then
  if result=`g\rep ".will." $HOME/.bash_login`
  then
    echo ".will.bash_login may already be included:"
    echo "$result"
    echo "writing .bash_login.new but not using it, copy yourself if needed"
  else
    waterfall_bash_login="1"
  fi
  c\p -a $HOME/.bash_login $HOME/.bash_login.new
  echo >> $HOME/.bash_login.new
  echo 'if [ -f "$HOME/.will.bash_login" ]; then' >> $HOME/.bash_login.new
  echo '    . "$HOME/.will.bash_login"' >> $HOME/.bash_login.new
  echo 'fi' >> $HOME/.bash_login.new
fi

if [ -f $HOME/.bashrc ]
then
  if result=`g\rep ".will." $HOME/.bashrc`
  then
    echo ".will.bashrc may already be included:"
    echo "$result"
    echo "writing .bashrc.new but not using it, copy yourself if needed"
  else
    waterfall_bashrc="1"
  fi
  c\p -a $HOME/.bashrc $HOME/.bashrc.new
  echo >> $HOME/.bashrc.new
  echo 'if [ -f "$HOME/.will.bashrc" ]; then' >> $HOME/.bashrc.new
  echo '    . "$HOME/.will.bashrc"' >> $HOME/.bashrc.new
  echo 'fi' >> $HOME/.bashrc.new
else
  echo "Creating a .bashrc to source .will.bashrc"
  echo 'if [ -f "$HOME/.will.bashrc" ]; then' > $HOME/.bashrc
  echo '    . "$HOME/.will.bashrc"' >> $HOME/.bashrc
  echo 'fi' >> $HOME/.bashrc
fi

if [ $waterfall_profile -eq 1 ]
then
  c\p -ai $HOME/.profile $HOME/.profile.old && mv $HOME/.profile.new $HOME/.profile
  echo ".profile updated, PLEASE DIFF against .profile.old"
fi

if [ $waterfall_bash_profile -eq 1 ]
then
  c\p -ai $HOME/.bash_profile $HOME/.bash_profile.old && mv $HOME/.bash_profile.new $HOME/.bash_profile
  echo ".bash_profile updated, PLEASE DIFF against .bash_profile.old"
fi

if [ $waterfall_bash_login -eq 1 ]
then
  c\p -ai $HOME/.bash_login $HOME/.bash_login.old && mv $HOME/.bash_login.new $HOME/.bash_login
  echo ".bash_login updated, PLEASE DIFF against .bash_login.old"
fi

if [ $waterfall_bashrc -eq 1 ]
then
  c\p -ai $HOME/.bashrc $HOME/.bashrc.old && mv $HOME/.bashrc.new $HOME/.bashrc
  echo ".bashrc updated, PLEASE DIFF against .bashrc.old"
fi

