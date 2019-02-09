#!/bin/sh
#
# Entrypoint for the git server docker container
#
# This script will create the /home/git/.ssh/authorized_keys file and copy the
# value of the $AUHTORIZED_KEYS environment variable into it. Then it will run
# either /usr/bin/top or the command provided as arguments to this script.
#
# Adopted from https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh
set -eufo pipefail

# Configure OpenSSH
# - generate host keys
# - disallow password based logins - the user git may only use key-based auth
# - allow the users matching AUTHORIZED_KEYS to log in as user "git"
ssh-keygen -A

# Toggle the PasswordAuthentication flag from "yes" to "no"
sed -i '/#PasswordAuthentication/ s/yes/no/' /etc/ssh/sshd_config

# Uncomment the PasswordAuthentication flag
sed -i '/#PasswordAuthentication no/ s/#//' /etc/ssh/sshd_config

echo "$AUTHORIZED_KEYS" | sed 's/\\n/\n/g' >/home/git/.ssh/authorized_keys
chown git.git /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys

# Enable the git user by configuring a random 64 byte password
export PASSWD="$(LC_ALL=C tr -dc 'A-Za-z0-9!#$%&()*+,-./:;<=>?@[]_{|}' </dev/urandom | head -c 64)"
echo -e "$PASSWD\n$PASSWD" | passwd git
export PASSWD=

if [ "$1" = "gitserver" ]; then
    /usr/sbin/sshd -D -e
else
    exec "$@"
fi
