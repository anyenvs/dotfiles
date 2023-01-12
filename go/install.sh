#!/usr/bin/env bash

#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find "${DOTFILES_PATH}"/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

_go-init() {
    # ######
    # GOlang
    # ######
    mkdir -p $HOME/.go ; ln -svnf $HOME/.go $HOME/go ; ln -svnf $HOME/.go $HOME/sdk
    test -f ~/.anyenvrc && . ~/.anyenvrc || _error "===> ❌ No ANYENV installed" ;
    grep -q anyenvrc $HOME/.bashrc || echo 'test -f ~/.anyenvrc && . ~/.anyenvrc' >>$HOME/.bashrc
    eval which {go,} || { _error "===> ❌ No Go installed" ; exit; }
}

_go-alt-init() {
    ###
    # GO Alternative version
    ###
    export GOALT=${GOALT:-1.17.11}
    GOROOT=$GOPATH/go${GOALT} go install golang.org/dl/go${GOALT}@latest ; GOROOT=$GOPATH/go${GOALT} go${GOALT} download ;
    #echo -e 'GOROOT=$HOME/go/go${GOALT}\nGOTOOLDIR=$HOME/go/go${GOALT}/pkg/tool/darwin_amd64' >>"/Users/malinovv/Library/Application Support/go/env"
}

GO_MODULES=(
    go.mozilla.org/sops/v3/cmd/sops@latest
)
_go-modules() {
    # ######
    # GO packages
    # - Sops
    # ######
    GO_MODULES=( ${@} )
    for mod in ${GO_MODULES[@]} ;do
        #GOBIN=$HOME/go/bin GO111MODULE=on CGO_ENABLED="0" go${GOALT} install go.mozilla.org/sops/v3/cmd/sops@latest  ## SOPS can only be install unsing Goland <= 1.17
        GOBIN=$HOME/go/bin GO111MODULE=on CGO_ENABLED="0" go install ${mod}  ## SOPS v3 new install works
    done
}

__main__() {
    _go-init || true ;
    _go-alt-init || true ;
    _go-modules ${GO_MODULES[@]}|| true ;
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
