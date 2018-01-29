#!/bin/sh
# both group and user id
USE_ID=3325
# both group and user name
USE_NAME=certdrop
# home path
USE_HOME=/certs

if [ "$USER" != "root" ]
then
  echo "UH-OH: you must be root to run this"
  exit 1
fi

OFFENDU=$(cat /etc/passwd | awk -F: '{print "user " $1 " is " $3}' | grep -E " $USE_ID\$")
OFFENDG=$(cat /etc/group | awk -F: '{print "user " $1 " is " $3}' | grep -E " $USE_ID\$")

if [ "${OFFENDU}${OFFENDG}" ]
then
  echo "UH-OH: ${OFFENDU} and ${OFFENDG} already. Exiting..."
  exit 1
fi

echo "$USE_NAME:*:$USE_ID:$USE_ID:$USE_NAME:$USE_HOME:/bin/ash" >> /etc/passwd
echo "$USE_NAME:x:$USE_ID:" >> /etc/group
echo "$USE_NAME:*:0:0:99999:7:::" >> /etc/shadow

if [ -e $USE_HOME ]
then
  echo "UH-OH: $USE_HOME already exits, the user is created, but the home must be done manually"
  exit 1
fi

mkdir -p $USE_HOME/.ssh
cp authorized_keys $USE_HOME/.ssh
cp certdrop_ssh.sh /root/.

chmod 755 /root/certdrop_ssh.sh
touch /root/certdrop.log
chmod 622 /root/certdrop.log

chown -R $USE_NAME:$USE_NAME $USE_HOME
chmod -R 755 $USE_HOME
chmod 644 $USE_HOME/.ssh/authorized_keys

