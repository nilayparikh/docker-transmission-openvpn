FROM ubuntu:16.04

VOLUME /config

ARG DOCKERIZE_ARCH=amd64
ARG DOCKERIZE_VERSION=v0.6.1
ARG DUMBINIT_VERSION=1.2.2

# Update, upgrade and install core software
RUN apt update \
    && apt -y upgrade \
    && apt -y install software-properties-common wget git curl jq \
    && wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - \
    && echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list \
    && apt update \
    && apt install -y sudo curl rar unrar zip unzip ufw iputils-ping openvpn bc tzdata python2.7 python2.7-pysqlite2 && ln -sf /usr/bin/python2.7 /usr/bin/python2 \
    && apt install -y tinyproxy telnet \
    && wget https://github.com/Yelp/dumb-init/releases/download/v${DUMBINIT_VERSION}/dumb-init_${DUMBINIT_VERSION}_amd64.deb \
    && dpkg -i dumb-init_${DUMBINIT_VERSION}_amd64.deb \
    && rm -rf dumb-init_${DUMBINIT_VERSION}_amd64.deb \
    && curl -L https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-${DOCKERIZE_ARCH}-${DOCKERIZE_VERSION}.tar.gz | tar -C /usr/local/bin -xzv \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc

COPY openvpn/ /etc/openvpn/
COPY tinyproxy /opt/tinyproxy/
COPY scripts /etc/scripts/

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    GLOBAL_APPLY_PERMISSIONS=true \
    ENABLE_UFW=false \
    UFW_ALLOW_GW_NET=false \
    UFW_EXTRA_PORTS= \
    UFW_DISABLE_IPTABLES_REJECT=false \
    PUID= \
    PGID= \
    DROP_DEFAULT_ROUTE= \
    WEBPROXY_ENABLED=false \
    WEBPROXY_PORT=8888 \
    HEALTH_CHECK_HOST=google.com

HEALTHCHECK --interval=5m CMD /etc/scripts/healthcheck.sh

# Expose port and run
EXPOSE 8888
CMD ["dumb-init", "/etc/openvpn/start.sh"]
