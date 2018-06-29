# ~/.will.profile: Cross-platform options for login shells...

# If running interactively, print debug
case $- in
    *i*) echo "running .will.profile";;
      *) ;;
esac

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

