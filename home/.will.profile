# ~/.will.bashrc: Cross-platform BASH related options for login shells...

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

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
