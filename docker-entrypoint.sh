#!/bin/bash
set -e

# Check if there is a configdir mounted, if not copy the default config from the installation.
if [ ! -d "/etc/salt" ]; then
	echo "# No config mounted, so copying the default."
	mv /etc/salt-default /etc/salt 
else
	echo "# config mounted, so not copying the default."
fi

# Check if the git client is been configured, otherwise generate the required config.
if [ ! -d "~/.ssh" ]; then
	ssh-keygen -b 521 -t ecdsa -q -f /root/.ssh/id_ecdsa -N ""
elif [ "$SSH_PUBKEY" != "" ] && [ "$SSH_PRIVKEY" != "" ]; then
	echo "$SSH_PUBKEY" > ~/.ssh/id_ecdsa.pub
	echo "$SSH_PUBKEY" > /etc/ssh/ssh_host_ecdsa_key.pub
	echo "$SSH_PRIVKEY" > ~/.ssh/id_ecdsa
	echo "$SSH_PRIVKEY" > /etc/ssh/ssh_host_ecdsa_key
elif [ "$SSH_PUBKEY" != "" ] || [ "$SSH_PRIVKEY" != "" ]; then
	echo "# Error, only SSH_PUBKEY pr SSH_PRIVKEY given. Need both."
else
	echo "# Using the .ssh config mounted."
fi

if [ ! -f "~/.gitconfig" ] && [ "$GIT_NAME" != "" ] && [ "$GIT_NAME" != "" ]; then
	echo "# No gitconfig found, creating it"
	echo "[user]" > ~/.gitconfig
	echo "	name = $GIT_NAME" >> ~/.gitconfig
	echo "	email = $GIT_EMAIL" >> ~/.gitconfig
elif [ ! -f "~/.gitconfig" ]; then
	echo "# No .gitconfig found, also no GIT_NAME and/or GIT_EMAIL variable so not creating .gitconfig"
else
	echo "# .gitconfig found, not editing it"
fi

echo "##########################################"
echo "# The public ssh-key for the salt-master #"
echo "##########################################"
cat ~/.ssh/id_ecdsa.pub
echo "##########################################"

if [ "$SSH_PASSWORD" != "" ]; then
	echo "# Set the password for the root user and allow password login."
	echo "root:$SSH_PASSWORD" | chpasswd
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
fi

if [ "$SSH_AUTHKEY" != "" ]; then
	echo "# Set authorized keys for the root user."
	mkdir -p /root/.ssh
	echo "$SSH_AUTHKEY" | tr ";" "\n" > /root/.ssh/authorized_keys
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
fi


if [ "$1" = 'test' ]; then
	exec "bash"
	exit 0
fi

if [ "$DISABLE_MINION" != "yes" ]; then
	echo "# Salt minion is not disabled, starting the minion"
	exec /usr/bin/salt-minion --user root &
	echo "# Salt minion started."
fi

if [ "$DISABLE_SSH" != "yes" ]; then
	echo "# OpenSSH server is not disabled, starting the deamon"
	exec /usr/sbin/sshd -e &
	echo "# OpenSSH server started."
fi

echo "# Starting the Salt-master" 
exec /usr/bin/salt-master --user root "$@"

