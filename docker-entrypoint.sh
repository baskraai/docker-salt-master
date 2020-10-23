#!/bin/bash
set -e

# Check if there is a configdir mounted, if not copy the default config from the installation.
if [ ! -d "/etc/salt" ]; then
	mv /etc/salt-default /etc/salt 
fi

# Check if the git client is been configured, otherwise generate the required config.
if [ ! -d "~/.ssh" ]; then
	ssh-keygen -b 521 -t ecdsa -q -f /root/.ssh/id_ecdsa -N ""
fi
if [ ! -f "~/.gitconfig" ]; then
	echo "[user]" > ~/.gitconfig
	echo "	name = $GIT_NAME" >> ~/.gitconfig
	echo "	email = $GIT_EMAIL" >> ~/.gitconfig
fi

echo "#####################################"
echo "# The public ssh-key for the salt-master:"
echo "#####################################"
cat ~/.ssh/id_ecdsa.pub
echo "#####################################"

if [ "$1" = 'test' ]; then
	exec "bash"
else
	exec /usr/bin/salt-minion --user root &
	exec /usr/bin/salt-master --user root "$@"
fi
