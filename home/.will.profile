# ~/.will.profile: Cross-platform options for login shells...

# If running interactively, print debug
case $- in
    *i*) echo "running .will.profile";;
      *) ;;
esac

if [ $( uname -r )="*Microsoft" ]; then
  # winhome link
  tmp_winuser=$USER
  tmp_newln=1
  if [ -h "${HOME}/winhome" ]; then #Existing link
    if [ -d "${HOME}/winhome" ]; then #Link is to valid dir
      tmp_newln=0
    else
      rm "${HOME}/winhome" > /dev/null 2>&1
    fi
  fi
  if [ $tmp_newln -eq 1 ] && ! [ -d "/mnt/c/Users/${tmp_winuser}" ]; then
    tr '[A-Z]' '[a-z]' < $tmp_winuser
    if ! [ -d "/mnt/c/Users/${tmp_winuser}" ]; then
      tmp_winuser="$(tr '[a-z]' '[A-Z]' <<< ${tmp_winuser:0:1})${tmp_winuser:1}"
      if ! [ -d "/mnt/c/Users/${tmp_winuser}" ]; then
        tmp_newln=0
      fi
    fi
  fi
  if [ $tmp_newln -eq 1 ]; then
    ln -s "/mnt/c/Users/${tmp_winuser}" "${HOME}/winhome"
  fi
fi

# Use this for where we come from
mystuffpath="$( readlink -f `dirname $BASH_SOURCE[0]` )"

# Add the go path first
if [ -d "$HOME/go/bin" ] ; then
  PATH="$HOME/go/bin":$PATH
fi

# Add the mystuff bin to $PATH
if [ -d "${mystuffpath}/bin" ]; then
  PATH="${mystuffpath}/bin":$PATH
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin":$PATH
fi

# Source aliases last (so they have the full path etc.)
if [ -f "${mystuffpath}/.will.aliases" ]; then
  source "${mystuffpath}/will.aliases"
fi

if [ -f "$HOME/workstuff/home/work_env" ]; then
  source "$HOME/workstuff/home/work_env"
fi

