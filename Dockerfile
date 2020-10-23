FROM ubuntu:bionic
MAINTAINER Bas Kraai <bas@kraai.email>


RUN apt-get update \
    && apt-get install -y curl jq vim wget nano python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://bootstrap.saltstack.com | bash -s -- -M -X -x python3 $DOCKER_TAG \
    && rm -rf /var/lib/apt/lists/*

RUN mv /etc/salt /etc/salt-default

VOLUME /etc/salt /var/log/salt

EXPOSE 4505 4506

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
