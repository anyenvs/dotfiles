ARG DIST=alpine:edge
# syntax=docker/dockerfile:1.3-labs
## ######################################################################
## STAGE_1: Build Confd
## ######################################################################
FROM golang:1.15-alpine as CONFDBUILD

ARG APP_NAME=${APP_NAME:-confd}
ARG ENTRYPOINT='deploy/entrypoint.sh'
ARG SOPS_VERSION=${SOPS_VERSION:-3.8.1}
ARG CONFD_VERSION=${CONFD_VERSION:-0.16.0}

WORKDIR /src/

ADD https://github.com/kelseyhightower/confd/archive/v${CONFD_VERSION}.tar.gz /tmp/

RUN set -xe &&\
    . /etc/os-release && \
    _OS=$(uname -s | tr '[:upper:]' '[:lower:]') && _ARCH=$(uname -m | tr '[:upper:]' '[:lower:]' | sed 's/x86_64/amd64/g; s/armv7.*/armv7/g; s/arm64/aarch64/g ') ;\
    apk add --no-cache \
    bzip2 make gcc && \
    mkdir -p /go/src/github.com/kelseyhightower/confd && \
    cd /go/src/github.com/kelseyhightower/confd && \
    tar --strip-components=1 -zxf /tmp/v${CONFD_VERSION}.tar.gz && \
    go install github.com/kelseyhightower/confd && \
    rm -rf /tmp/v${CONFD_VERSION}.tar.gz

ARG DIST=alpine:edge
FROM confd:latest as CONFDBIN

## ######################################################################
## STAGE_2: Build Proxy
## ######################################################################
ARG DIST=alpine:edge
FROM ${DIST}

ARG EXPOSE="8118 9050"
ARG PORT_EXPOSE_HTTP
ARG PORT_EXPOSE_SOCKS
ARG PORT_EXPOSE_DNS
ARG TOR_EXITNODES
ARG CONFD_LOG_LEVEL
ARG CONFD_BACKEND
ARG CONFD_DEBUG
EXPOSE ${PORT_EXPOSE_HTTP} ${PORT_EXPOSE_SOCKS}

ENV PORT_EXPOSE_HTTP=${PORT_EXPOSE_HTTP} \
    PORT_EXPOSE_SOCKS=${PORT_EXPOSE_SOCKS} \
    PORT_EXPOSE_DNS=${PORT_EXPOSE_DNS} \
    #TOR_EXITNODES=${TOR_EXITNODES} \ ## don need to set status ENV via docker-compose
    CONFD_LOG_LEVEL=${CONFD_LOG_LEVEL} \
    CONFD_BACKEND=${CONFD_BACKEND} \
    CONFD_DEBUG=${CONFD_DEBUG}

#ADD proxy/service/tor/torrc /etc/tor/torrc
#ADD proxy/service/tor proxy/service/privoxy  /etc/service/
ADD proxy.tar /etc/service/
ADD proxy/service/assets/root/ /

COPY --from=CONFDBUILD /go/bin/confd /usr/bin/confd

## DIST=alpine:edge PORT_EXPOSE_SOCKS=9050 PORT_EXPOSE_HTTP=8118 PORT_EXPOSE_DNS=127.0.0.1:9053 CONFD_BACKEND=env CONFD_DEBUG=Y29uZmQgLW9uZXRpbWUgLWJhY2tlbmQgZW52IC1sb2ctbGV2ZWwgZGVidWcK CONFD_LOG_LEVEL=info docker build --build-arg DIST=alpine:edge --network host -t proxy -f proxy/Dockerfile .
RUN set -xe ;\
    . /etc/os-release &&\
    _OS=$(uname -s | tr '[:upper:]' '[:lower:]') && _ARCH=$(uname -m | tr '[:upper:]' '[:lower:]' | sed 's/x86_64/amd64/g; s/armv7.*/armv7/g; s/aarch64/arm64/g' ) &&\
    #echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories &&\
    #apk add --update privoxy tor@testing runit@testing openrc &&\
    #echo -e 'https://dl-cdn.alpinelinux.org/alpine/v3.17/main\nhttps://dl-cdn.alpinelinux.org/alpine/v3.17/community' > /etc/apk/repositories &&\
    echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community' > /etc/apk/repositories &&\
    apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community tor runit &&\
    apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main privoxy openrc &&\
    ##
    ## Additional packages
    apk add --update ca-certificates vim curl bash jq whois wget &&\
    apk add --no-cache netcat-openbsd &&\
    ## strace busybox whois www.google.com
    ## whois -h whois.arin.net IP
    ##
    ## Confd download
    ## https://github.com/kelseyhightower/confd
    ## https://theagileadmin.com/2015/11/12/templating-config-files-in-docker-containers/
    #curl -sSLo /usr/bin/confd $(curl -sSL https://api.github.com/repos/kelseyhightower/confd/releases/latest | jq -r '.assets[]| select(.name | contains("linux-amd64")) | .browser_download_url') &&\
    chmod +x /usr/bin/confd &&\
    mkdir -p /etc/confd/{conf.d,templates} &&\
    ##
    ## Copy confd configs
    ##  - /etc/service/assets/root/ -> /etc
    ##  - /etc/service/**/*.tmpl -> /etc/confd/templates/
    # ls -R  /opt/service/
    # cp -Rfv /etc/service/assets/root/* / &&\
    #bash -c "ln -svnf \$(ls -R /etc/service/**/*.tmpl) /etc/confd/templates/" &&\
    #bash -c "ln -svnf \$(ls -R /etc/service/**/*.toml) /etc/confd/conf.d/" &&\
    ln -svnf `ls -R /etc/service/**/*.tmpl` /etc/confd/templates/ &&\
    ln -svnf `ls -R /etc/service/**/*.toml` /etc/confd/conf.d/ &&\
    #exit 0 &&\
    rc-update add local &&\
    rc-update add confd &&\
    ##
    ## Tor script
    ##
    chmod +x /etc/service/privoxy/run /etc/service/tor/run ||\
    exit $?

#RUN chmod +x /etc/service/privoxy/run /etc/service/tor/run

CMD ["runsvdir", "/etc/service"]
