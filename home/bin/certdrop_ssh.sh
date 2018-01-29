#/bin/sh

LOGFILE="/root/certdrop.log"

echo "New connection $SSH_CONNECTION on `date`" >> $LOGFILE
echo "  details:" >> $LOGFILE
echo "    user $USER" >> $LOGFILE
echo "    command \`${SSH_ORIGINAL_COMMAND}\`" >> $LOGFILE

if [ $USER != "certdrop" ]
then
  echo "  ACCESS DENIED: this user may not use this key" | tee -a $LOGFILE
  exit 1
fi

if [ -z "$SSH_ORIGINAL_COMMAND" ]
then
  echo "  ACCESS DENIED: shell not allowed" | tee -a $LOGFILE
  exit 1
else
  case "$SSH_ORIGINAL_COMMAND" in
    "scp -t "* | "scp -d -t "* )
      echo "  APPROVED: executing scp receive command" >> $LOGFILE
      eval "$SSH_ORIGINAL_COMMAND"
      exit $?
    ;;
    *)
    echo "  ACCESS DENIED: remote command is not approved" | tee -a $LOGFILE
    exit 1
esac
fi

echo "  UNKNOWN ERROR: should not have reached the end of security script" | tee -a $LOGFILE
exit 100

