#!/usr/bin/env bash

[ -n "${DEBUG}" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] ' ; set -x; }
#set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH="${DOTFILES_PATH:-$(readlink -f ..)}"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

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
    test -z "$GOPATH" && export GOPATH=$HOME/go${GOALT} ;
    test -d $GOPATH || mkdir -pv $GOPATH ;
    GOROOT=$GOPATH GO111MODULE=on CGO_ENABLED="0" go install golang.org/dl/go${GOALT}@latest ;
    GOROOT=$GOPATH GO111MODULE=on CGO_ENABLED="0"  go${GOALT} download ;
    #echo -e 'GOROOT=$HOME/go/go${GOALT}\nGOTOOLDIR=$HOME/go/go${GOALT}/pkg/tool/darwin_amd64' >>"/Users/malinovv/Library/Application Support/go/env"
}

GO_MODULES=(
    ## https://github.com/getsops/sops/pull/911#issuecomment-1004922856
    # go.mozilla.org/sops/v3/cmd/sops@latest ## deprecated
    github.com/getsops/sops/v3/cmd/sops@latest
    github.com/danielmiessler/fabric@latest
    github.com/mikefarah/yq/v4@latest
    gitlab.com/gitlab-org/cli/cmd/glab@main
    github.com/gorilla/mux@latest
    github.com/derailed/k9s@latest
)
_go-modules() {
    # ######
    # GO packages
    # - Sops
    # ######
    test -d $HOME/go/bin || mkdir -pv $HOME/go/bin
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
