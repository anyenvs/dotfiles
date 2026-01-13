ARG DIST=alpine:edge
## Stage 1 - building app
#FROM golang:1.15-alpine AS BUILD
#
#ARG APP_NAME=${APP_NAME:-confd}
#ARG ENTRYPOINT='deploy/entrypoint.sh'
#ARG SOPS_VERSION=${SOPS_VERSION:-3.10.1}
#WORKDIR /src/
#
## download modules in separated layer, to speed up rebuild by utilising Docker layer caching system
##COPY go.mod go.sum /src/
## NOTE: build error may occur due to temporary unavailability of some packages sources
## Wait and build again is usually a good solution
##RUN set -xe &&\
##    go mod download
#
#COPY . /src/
#
### docker run -it --rm alpine:edge wget -qO- https://api.github.com/repos/mozilla/sops/releases/latest | jq -r '.assets[] | select(.name | endswith("linux")) | .browser_download_url'
### docker run -it --rm golang:1.17 "apk add --update jq && wget get -qO- https://api.github.com/repos/mozilla/sops/releases/latest | jq -r '.assets[] | select(.name | endswith(\"linux\")) | .browser_download_url'"
#RUN set -xe &&\
#    . /etc/os-release && \
#    _OS=$(uname -s | tr '[:upper:]' '[:lower:]') && _ARCH=$(uname -m | tr '[:upper:]' '[:lower:]' | sed 's/x86_64/amd64/g; s/armv7.*/armv7/g; s/arm64/aarch64/g ') &&\
#    apk --update --no-cache add gnupg jq && apk --update add wget bind-tools &&\
#    ping -c 6 api.github.com ; dig +answer +noall api.github.com &&\
#    SOPS_URL=$(wget -qO- https://api.github.com/repos/mozilla/sops/releases/latest | jq -r '.assets[] | select(.name | endswith("'${_OS}.${_ARCH}'")) | .browser_download_url' 2>/dev/null ) &&\
#    test -n "${SOPS_URL}" && wget -qO /usr/local/bin/sops ${SOPS_URL} || exit 1 &&\
#    test -n "${SOPS_URL}" || { echo sops/releases/latest for ${_OS}.${_ARCH} not found ; } &&\
#    chmod +x /usr/local/bin/sops /src/${ENTRYPOINT} &&\
#    sops --version || wget -qO /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION##v}/sops-v${SOPS_VERSION##v}.linux || exit 1 &&\
#    chmod +x /usr/local/bin/sops /src/${ENTRYPOINT} &&\
#    #wget -qO- https://dl.dropboxusercontent.com/s/noe19dbp3mxyzgf/appconfig.asc | gpg --import - &&\
#    ## /src/config.enc - not required
#    ( test -f /src/config.enc && sops -d --input-type yaml /src/config.enc > /src/config.toml || true ) ||\
#    exit 1
#
#RUN set -xe &&\
#    go build -o /src/bin/${APP_NAME} ./cmd/controller/main.go

FROM ${DIST} AS git-shell

WORKDIR /git-repos
ARG GIT_UID=1002

ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1

## Git aliases
#ADD /git-repos/deploy/git-shell/_bashrc /home/git/.bashrc
COPY . /src/

RUN set -xe ;\
    apk update &&\
    apk add --no-cache git git-bash-completion \
    git-lfs git-diff-highlight \
    colordiff delta \
    bash gpg less patch perl vim \
    openssh \
    sudo shadow \
    && apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing git-extras \
    && rm -rf /var/cache/apk/* ||\
    exit $?

# Create git user and group with UID/GID ${GIT_UID:-1002}
RUN set -xe ;\
    addgroup -g ${GIT_UID} git && \
    adduser -D -u ${GIT_UID} -G git -s /bin/bash git && \
    GIT_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8) &&\
    test -n "$GIT_PASSWORD" && echo $GIT_PASSWORD > /tmp/git-pwd &&\
    echo "git:$GIT_PASSWORD" | chpasswd ;\
    # Create .ssh directory for git user and set proper permissions
    sleep 3 ;\
    mkdir -pv /home/git/.ssh && \
    chown -R git:git /home/git && \
    chmod 700 /home/git/.ssh

# Configure SSH to allow password authentication and public key auth
RUN set -xe ;\
    mkdir -p /run/sshd && \
    mkdir -p /etc/ssh/ssh_config.d /etc/ssh/sshd_config.d &&\
    sed -i \
    -e 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' \
    -e 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' \
    -e 's/^#PermitRootLogin.*/PermitRootLogin no/' \
    -e 's/^#PermitEmptyPasswords.*/PermitEmptyPasswords no/' \
    /etc/ssh/sshd_config

# Generate SSH host keys if they don't exist
RUN set -xe ;\
    ssh-keygen -A

# Generate SSH key pair for git user (optional - for testing)
# Note: In production, you should mount authorized_keys or generate them separately
RUN set -xe ;\
    su - git -c "ssh-keygen -t rsa -b 4096 -f /home/git/.ssh/id_rsa -N ''" && \
    su - git -c "cat /home/git/.ssh/id_rsa.pub >> /home/git/.ssh/authorized_keys" && \
    chmod 600 /home/git/.ssh/authorized_keys && \
    chown git:git /home/git/.ssh/authorized_keys

    # Create git repositories directory
RUN set -xe ;\
    mkdir -p /home/git/repositories && \
    chown -R git:git /home/git/repositories ;\
    sleep 5;\
    ## Create a test repository
    su - git -c "cd /home/git/repositories && \
    git init --bare test-repo.git && \
    chown -R git:git /home/git/repositories"

# Set up git-shell for security (optional but recommended)
# RUN which git-shell > /dev/null && chsh -s $(which git-shell) git

# Copy entrypoint script
#COPY entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh

RUN echo "git        ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers.d/git ;\
    chown -R git:git /src ;\
    GIT_HOME=/home/git ;\
    echo "alias g='git'" >> $GIT_HOME/.bashrc ;\
    echo "alias gs='git fetch ;git status -uno; git rev-parse --abbrev-ref HEAD  ;set +x'"  >> $GIT_HOME/.bashrc ;\
    echo "alias gd='git diff --no-ext-diff -w HEAD'"  >> $GIT_HOME/.bashrc ;

# Expose SSH port
EXPOSE 22

USER git
#WORKDIR /git-repos
## Git aliases
#ADD /git-repos/deploy/git-shell/_bashrc /home/git/.bashrc
#COPY . /src/


# Health check
#HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#    CMD netstat -an | grep -q 0.0.0.0:22 || exit 1

# Start SSH daemon
#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/sbin/sshd", "-D", "-e"]

