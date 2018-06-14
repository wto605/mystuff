#!/usr/bin/env bash

# Updated "includer" script

myexit() {
exit $1
echo "got code $1"
echo "externalinstdir: $externalinstdir"
echo "homedir: $homedir"
echo "realhome: $realhome"
echo "instdir: $instdir"
echo "realinstdir: $realinstdir"
}

loopdebug () {
echo "dotfile: $dotfile"
echo "includefile: $includefile"
echo "oldinclude: $oldinclude"
echo "awkit: $awkit"
echo "appendit: $appendit"
echo "waterfall: $waterfall"
}

oldfilecheck () {
  oldinclude=$1
  if [ -f $oldinclude ]
  then
    echo "WARNING: An old copy of $( basename $oldinclude ) exists in HOME. New method keeps"
    echo "         these files in the install dir. Would you like to remove the file?"
    echo "         There will be an option to remove the old include (if it exists) later."
    select yn in "Yes" "No" "Disable old file checks"
    do
      case $yn in
        Yes ) rm $oldinclude; return 0;;
        No ) return 0;;
        "Disable old file checks" ) return 99;;
      esac
    done
  fi
  return 0
}

oldincludecheck () {
  dotfile=$1
  if result=`g\rep '$HOME/.will.' $dotfile`
  then
    if [ `g\rep -c '$HOME/.will.' $dotfile` -gt 2 ]
    then
      echo "ERROR: There appears to be mor ethan one old include in $dotfile."
      echo "        The script cannot handle this. Please remove old includes or add it manually."
      return 0
    fi
    echo "WARNING: An old include may be in $dotfile."
    echo "         New method keeps these files in the install dir. Would you like to"
    echo "         replace this old include? Otherwise a new one will be added."
    echo "$result"
    select yn in "Yes" "No" "Disable old include checks"
    do
      case $yn in
        Yes ) return 1;;
        No ) return 0;;
        "Disable old include checks" ) return 99;;
      esac
    done
  fi
  return 0
}

##############################
# Get our bearings (path munching)
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

if [ -z $instdir ]
then
  instdir="$( cd "$( dirname "${0}" )" && pwd )"
fi

realhome=`readlink -f $homedir`
realinstdir=`readlink -f $instdir`

##############################
# Sanity checks
##############################
externalinstdir=0
# be extra paranoid in case the downloader used tmp dir
# the not equals means the replacement *worked* so realinstdir IS in tmp
if [ "${realinstdir##/tmp}" != "${realinstdir}" ]
then
  echo "ERROR: instdir is in tmp, please place in a permament location"
  myexit 1
fi

# Use replacement to test if de-referenced install dir is inside derefenced home
# the not equals means the replacement *worked* so realinstdir IS in realhome
if [ ! "${realinstdir##$realhome}" != "${realinstdir}" ]
then
  echo "WARNING: Installdir ($instdir) is not inside home. This is not recommended,"
  echo "         but OK if you know the dir is permanent and portable. Continue?"
  echo "CAREFUL: if instdir IS in home please answer no and reurn with overrides to fix this"
  echo "         INST_HOME overrides \$HOME, instdir overrides install dir"
  select yn in "Yes" "No"
  do
    case $yn in
      Yes ) echo; externalinstdir=1; break;;
      No ) myexit 1;;
    esac
  done
fi

# Check if home lives on a remote filesystem, if so confirm it's portable
if [ "$(stat -f -L -c %T $homedir)" = "*nfs*" ]
then
  if [ "$homedir" = "$realhome" ] # Assume it's portable if it's linked
  then
    echo "WARNING: Home path $homedir is remote, but directly referenced."
    echo "         Is this a portable path?"
    select yn in "Yes" "No"
    do
      case $yn in
        Yes ) echo; break;;
        No ) echo "re-run with \"INST_HOME=/portable/home/path\" in front"; myexit 1;;
      esac
    done
  else
    echo "INFO: assuming nfs home path $homedir is portable since it is linked to $realhome"
  fi
fi

##############################
# Now, inject the includes into dotfiles
##############################
# Re-base instdir to $HOME (if it's there)
if [ $externalinstdir -ne 1 ]
then
  # By using de-referenced paths here we ensure a mismatch of portable paths is fixed
  instdir='$HOME'"${realinstdir##$realhome}"
fi
dooldfilechecks=1
dooldincludechecks=1
# use realinstdir here because instdir has been string-ified for injections
for includefile in $realinstdir/.will.*
do
  # Figure out the name of the dotfile
  dotfile=${HOME}/${includefile##*.will}
  # default is to take no actions
  awkit=0
  appendit=0
  waterfall=1
  # Check if the home directory has an old .will.* file (now kept in install dir)
  if [ $dooldfilechecks -eq 1 ]
  then
    oldfilecheck "${HOME}/.will${includefile##*.will}"
    if [ $? -eq 99 ]
    then
      dooldfilechecks=0
    fi
  fi
  # Now check if the base dotfile actually exists
  if [ -f $dotfile ]
  then
    echo "attempting to update $dotfile"
    # Now check for an old include
    if [ $dooldincludechecks -eq 1 ]
    then
      oldincludecheck "$dotfile"
      case $? in
        99 ) dooldincludechecks=1;;
        0 ) appendit=1;;
        1 ) awkit=1;;
      esac
    else
      # Without old file checks default to append
      appendit=1
    fi
    # Convert includefile to $HOME based path
    includefile='$HOME'"${includefile##$realhome}"
    # Now check for ANY .will inclusion except old ones
    if result=`g\rep -v '$HOME/.will.' $dotfile | g\rep ".will."`
    then
      echo "WARNING: An include already exists in $dotfile:"
      echo "         Does it match the current install dir ${instdir}?"
      echo "$result"
      echo "         Yes will not make any changes"
      if [ $appendit -eq 1 ]
      then
        echo "         No will append a new include, but only into ${dotfile}.new"
      else
        echo "         No will continue updating the old include, but only into ${dotfile}.new"
      fi
      select yn in "Yes" "No"
      do
        case $yn in
          Yes ) echo "$dotfile was not updated"; echo; waterfall=0; awkit=0; appendit=0; break;; # Do nothing
          No ) waterfall=0;break;;
        esac
      done
    fi
    if [ $awkit -eq 1 ]
    then
      # If the user said to update include use awk
      echo "updating existing include in $dotfile"
      awk "{gsub(/\\\$HOME\/.will./,\"$instdir/.will.\"); print}" $dotfile > ${dotfile}.new
    fi
    if [ $appendit -eq 1 ]
    then
      # otherwise, copy the dotfile and append
      c\p -a $dotfile ${dotfile}.new
      echo >> ${dotfile}.new
      echo "if [ -f \"$includefile\" ]; then" >> ${dotfile}.new
      echo "    . \"$includefile\"" >> ${dotfile}.new
      echo "fi" >> ${dotfile}.new
      echo >> ${dotfile}.new
    fi
    if [ $waterfall -eq 1 ]
    then
      c\p -ai $dotfile ${dotfile}.old && mv ${dotfile}.new $dotfile
      echo "$dotfile updated, PLEASE DIFF against ${dotfile}.old"
      echo
    elif [ -f ${dotfile}.new ]
    then
      echo "$dotfile changes were made but NOT applied, please review ${dotfile}.new and update"
      echo
    fi
  else
    echo "Creating a $( basename $dotfile ) to source $includefile"
    echo
    echo "if [ -f \"$includefile\" ]; then" > $dotfile
    echo "    . \"$includefile\"" >> $dotfile
    echo "fi" >> $dotfile
    echo >> $dotfile
  fi
  #loopdebug
done

exit 0

