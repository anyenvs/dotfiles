## https://rakhesh.com/docker/building-a-docker-sops-image/
## https://hub.docker.com/_/golang/tags?page=1&name=1.17
#ARG DIST=${DIST:-golang:1.17-alpine}
ARG DIST=${DIST:-golang:1.17-bullseye}
FROM ${DIST} AS gobase

ARG SOPS_VERSION=${SOPS_VERSION:-3.7.3}
ENV SOPS_VERSION=${SOPS_VERSION}

WORKDIR /go/src/app/sops-${SOPS_VERSION}
ADD https://github.com/mozilla/sops/archive/v${SOPS_VERSION}.tar.gz /go/src/app/sops-v${SOPS_VERSION}.tar.gz
### make to compile sops
RUN set -xe ;\
    apt-get update -yqq &&\
    apt-get install make wget -yq >/dev/null || exit $? ;\
    ### Download release; untar it; make it;
    tar xzf /go/src/app/sops-v${SOPS_VERSION}.tar.gz -C /go/src/app/ &&\
    make install || exit $?
