#!/bin/bash
#
# Entrypoint for the git server docker container
#
# This script will create the /home/git/.ssh/authorized_keys file and copy the
# value of the $AUHTORIZED_KEYS environment variable into it. Then it will run
# either /usr/bin/top or the command provided as arguments to this script.
#
# Adopted from https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh
set -eufo pipefail

echo "$AUTHORIZED_KEYS" >/home/git/.ssh/authorized_keys
chown git.git /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys

if [ "$1" = "gitserver" ]; then
    /usr/bin/top
else
    exec "$@"
fi
