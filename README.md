# SaltStack Master Container
This container containers a salt-minion en salt-master.
It is designed to be a potable SaltStack server with the possibility to run commands on it's container.
The version on Docker Hub are based on the releases of SaltStack.
Auto-build has not been enabled yet, so if this image is behind the releases of SaltStack please let me know!

## Ports
This containers exposes the following ports:

| Port | usage |
| :---: | --- |
| 22 | OpenSSH server |
| 4505 | SaltStack Publisher |
| 4506 | SaltStack Request Server |

## Storage
You can save the data from the Salt Master and Salt Minion outside of the container:

- `/etc/salt` = general config 
- `/srv/salt` = states and pillars

Is the general config directory is not mounted, a default is placed.
If the directory is mounted the data is not copied so to not overwrite your config.

The SaltStack recommended directory `/srv/salt` is used.
But you can mount your config anywhere.

## SSH
The containers has an OpenSSH server included.
You can disable this server by setting the parameter `DISABLE_SSH' to 'yes'.
You can pass the ssh public via `SSH_PUBKEY` and private key via `SSH_PRIVKEY` for the main server SSH keys.
At this time the key needs to be a ECDSA server, this will be sorted later.
If you like to login with a password, you can set the `SSH_PASSWORD` variable.
If this variable is not set, password authentication for root is disabled.
You can pass ssh_keys that are allowed to login as root via the `SSH_AUTHKEY` variable seperated by `;`.

# Git
This image contains git so you can pull or push config from GitHub.
You can set the git name via `GIT_NAME` and git email via `GIT_MAIL`.
You can pass the ssh public via `SSH_PUBKEY` and private key via `SSH_PRIVKEY` for pushing config from the container to a git server.
At this time the key needs to be a ECDSA server, this will be sorted later.

# Salt minion
This container also has a salt-minion.
If you like to disable this minion, you can set `DISABLE_MINION` to 'yes'.

## Usage
You can use this image with docker run and docker-compose.
Below are examples for both.

### Docker run
The most basic docker run config is:
```
docker run --name "salt-master" --hostname salt baskraai/salt-master
```

### Parameters
You can use the following parameters with this container:

| Parameter | meaning |
| :---: | --- |
| --hostname | Used to set the minion and master name |

### Environment variables

You can use the following environment variables with this container:

| Variable | Required | meaning | values |
| :---: | --- | --- | --- |
| SSH\_PUBKEY | Optional | Specify the publickey for ssh here | <string>
| SSH\_PRIVKEY | Optional | Specify the privatekey for ssh here | <string>
| SSH\_PASSWORD | Optional | Specify the password for the root user | <string>
| GIT\_NAME | Optional | Specify the name used for git commits | <string>
| GIT\_EMAIL | Optional | Specify the email used for git commits | <string>
| DISABLE\_MINION | Optional | Disable the minion in the container | 'yes' or 'no'
| DISABLE\_SSH | Optional | Disable the OpenSSH server in the container | 'yes' or 'no'

## Extend image
```
FROM baskraai/salt-master:stable
RUN apt-get update \
    && apt-get install -y <packages> \
    && rm -rf /var/lib/apt/lists/
```

With this Dockerfile the rest of the container keeps working as expected.

### Mitigations
There are a few mitigations applied to to images.
  - [CVE Nov 3 2020](https://www.saltstack.com/blog/on-november-3-2020-saltstack-publicly-disclosed-three-new-cves/) -> images recreated, downloaded up-to-date packages.

### Todo
- Enable auto-build with release check.
- Allow password ssh to be passed hashed, and detect that.
- Allow more then only ECDSA ssh keys in environment variables.
- Able to control or SSH into the container.
