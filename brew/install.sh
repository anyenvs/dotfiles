#!/usr/bin/env bash

#set -e
set -x
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"
set +x

#if test ! $(which brew); then
#    printf "\n ===> 🚀 Installing BREW package manager\n"
#    eval which {curl,wget,sudo} || _install apt-transport-https ca-certificates curl sudo wget
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sed 's% == "0"% == "1"%g')" <<<y
#fi

_BREW_PACKAGES=(
    # anyenv managed: nvm, pyenv, terraform, terragrunt, go, golangci-lint, bazel, helm, helmfile, istio
    # awscli
    ## build utils
    bash bash-completion@2 dos2unix bat
    fd colordiff gls gawk htop jq jid python-yq tree
    coreutils findutils diffutils binutils iputils
    gcc@8 gcc make cmake libffi
    gnupg grep ca-certificates
    xz bzip2 lzlib zlib zip 7zip p7zip
    autoconf openssl@1.1 pkg-config readline
    # fzf
    git #gh
    far2l
    avro-c c-ares kcat
    kubectl kubectx kube-ps1 k9s hidetatz/tap/kubecolor
    # kind
    ## development tools
    delve
    httping httpie
    iam-policy-json-to-terraform
    reattach-to-user-namespace
    sops
    ## needed to build openshift-client
    gpgme heimdal
    ## other plugins & tools
    curl wget
    pinentry watch
    osx-cpu-temp
    task tldr oniguruma
    gnu-sed
    ## ip tools , networking
    iproute2mac nmap
    # mysql-client pgloader postgresql@14
    # glow hugo
)

_xcode-cli-install() {
    ##
    # MacOS install Apple Command Line Tools
    ##
    _log "===> 🚀 MacOS install Apple Command Line Tools"
    #eval which {brew,} || { return; set +x; }
    eval which {xcode-select,} && xcode-select --install || true
}

export BREW_HOME=/home/linuxbrew BREW_USER=linuxbrew
_add-linuxbrew-user() {
    ## Add linuxbrew user
    _log "===> 🚀 Add linuxbrew user on $(_myOS)"
    test -n "$( which groupadd )" -a -n "$( getent group )" && runAsRoot "groupadd linuxbrew -f";
    test -n "$( which  useradd )" -a -z "$( getent passwd linuxbrew )" && ( runAsRoot mkdir -p $BREW_HOME ; runAsRoot useradd -g linuxbrew -m -s /bin/bash linuxbrew );
    test -d $BREW_HOME && runAsRoot chown linuxbrew:linuxbrew -R $BREW_HOME ;
    test -d $BREW_HOME && runAsRoot chmod -R 775 -R $BREW_HOME ;
    ## allow SUDO access
    id linuxbrew && echo -e "linuxbrew ALL=(root) NOPASSWD: ALLOW" >/etc/sudoers.d/linuxbrew
}

_brew-install() {
    echo -e 'verbose=off \nprogress=bar:force:noscroll \nshow_progress=on \ncheck_certificate=off\n' > ~/.wgetrc; cat ~/.wgetrc ;
    eval which {git,gcc,make} || _install git-core make gcc g++ gawk bison libreadline-dev libffi-dev libtool ;
    eval which {curl,wget,sudo} || _install apt-transport-https ca-certificates curl sudo wget
    ##
    #set -x;
    #local _EUID=1; local _UID=1
    test -z "$(which brew)" && {
        _log "===> 🚀 Installing BREW package manager on $(_myOS)"
        chown linuxbrew:linuxbrew -R $BREW_HOME
        #yes | su -l linuxbrew bash -c "$(wget -qO- https://raw.githubusercontent.com/Homebrew/install/master/install.sh | sed 's|${_EUID:-${_UID}}|$(echo 1)|g;s|"fetch"|"fetch" "--depth=1"|g')"
        #su -l linuxbrew bash -c "$( wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sed 's| == "0"| == "1"|g;s|"fetch"|"fetch" "--depth=1"|g' )" <<<y
        #yes | USER=$BREW_USER HOME=$BREW_HOME su -l linuxbrew bash -c " wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sed 's#set -u#set -x#g; s# == \"0\"# == \"1\"#g;s#\"fetch\"#\"fetch\" \"--depth=1\"#g' | USER=$BREW_USER HOME=$BREW_HOME bash"
        yes | USER=$BREW_USER HOME=$BREW_HOME su -l linuxbrew bash -c " wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sed 's#set -u#set -u#g; s# == \"0\"# == \"1\"#g' | USER=$BREW_USER HOME=$BREW_HOME bash"
        ## ;/when reinstalling/a\ \ chmod -R 775 /home/linuxbrew/
        ## ;/when reinstalling/a\ \ ${CHMOD[@]} -R 775 /home/linuxbrew/
    } ||{  _log "===> 🚀 Brew update in progress on $(_myOS)" ;
            git -C $BREW_HOME/.linuxbrew/Homebrew unignore Library/Homebrew/brew.sh ;
            sed -i 's# == 0# == 1#g' $BREW_HOME/.linuxbrew/Homebrew/Library/Homebrew/brew.sh ;
            git -C $BREW_HOME/.linuxbrew/Homebrew ignore Library/Homebrew/brew.sh ;
            brew update-reset ;
            git -C $BREW_HOME/.linuxbrew/Homebrew ignore Library/Homebrew/brew.sh; }
    echo 'eval which {brew,} && eval "$('$BREW_HOME'/.linuxbrew/bin/brew shellenv)"' > ~/.brewrc
    grew -q brewrc ~/.bashrc || echo '. ~/.brewrc' >> ~/.bashrc
    sed -i 's# == 0# == 1#g' $BREW_HOME/.linuxbrew/Homebrew/Library/Homebrew/brew.sh
    git -C $BREW_HOME/.linuxbrew/Homebrew ignore Library/Homebrew/brew.sh;
    eval "$($BREW_HOME/.linuxbrew/bin/brew shellenv)"
}

_brew-install-packages() {
    local _BREW_PACKAGES=${1}
    _log "===> 🚀 Installing BREW Packages on $(_myOS)"
    ###
    # Install brew packages
    ###
    # Arm
    for pkg in "${_BREW_PACKAGES[@]}"; do printf " ===> 🚀 Installing %s\n" "${pkg}" && brew install ${pkg,,} || true; done

    _log "===> 🌈 Architectures for the brew installed applications:  $(_myOS), $(_myARCH)"
    #ALL_PACKAGES=("${IBREW_PACKAGES[@]}" "${ABREW_PACKAGES[@]}")
    #for pkg in "${ALL_PACKAGES[@]}"; do printf "%s - " "${pkg}" && (lipo -archs "$(command -v "${pkg}")" || true); done

    # Casks
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code
    brew install vim -vd protobuf

    # Some tidying up
    brew autoremove -v
    brew cleanup --prune=all
}


## _MAIN__
__main__() {
    case $(_myOS) in linux) _add-linuxbrew-user || return 1 ;; darwin) _xcode-cli-install ;; *) _error "OS $(_myOS) is currently not supported" ;; esac ;
    _brew-install || return 1 ;
    _brew-install-packages $_BREW_PACKAGES ;
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__

set +x
