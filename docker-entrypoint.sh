#!/bin/bash
set -e

if [ ! -d "/etc/salt" ]; then
	mv /etc/salt-default /etc/salt 
fi

if [ "$1" = 'test' ]; then
	exec "bash"
else
	exec /usr/bin/salt-minion --user root &
	exec /usr/bin/salt-master --user root "$@"
fi
