# ~/.will.bashrc: Cross-platform BASH related options for login shells...

if ! type wills_supper_hacky_guard_alias > /dev/null 2>&1
then
  if [ -n "$BASH_VERSION" ]; then
    # if running bash I want bashrc (which will bring .will.bashrc and .will.aliases)
    if [ -f "$HOME/.bashrc" ]; then
      . "$HOME/.bashrc"
    fi
  else
    # Otherwise I want my alias file at least
    if [ -f "$HOME/.will.aliases" ]; then
      . "$HOME/.will.aliases"
    fi
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

