#!/usr/bin/env bash

#set -e
ls *.env && . *.env || true
DOTFILES_PATH=${DOTFILES_PATH:-..}
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find ${DOTFILES_PATH}/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

###
# GO
###
mkdir -p $HOME/.go ; ln -svnf $HOME/.go $HOME/go ; ln -svnf $HOME/.go $HOME/sdk
test -f ~/.anyenvrc && . ~/.anyenvrc || _error "===> ❌ No ANYENV installed" ;
eval which {go,} || { _error "===> ❌ No Go installed" ; exit; }

###
# GO Alternative version
###
export GOALT=${GOALT:-1.17.11}
GOROOT=$GOPATH/go${GOALT} go install golang.org/dl/go${GOALT}@latest ; GOROOT=$GOPATH/go${GOALT} go${GOALT} download ;
#echo -e 'GOROOT=$HOME/go/go${GOALT}\nGOTOOLDIR=$HOME/go/go${GOALT}/pkg/tool/darwin_amd64' >>"/Users/malinovv/Library/Application Support/go/env"

###
# GO packages
#   Sops
###
#GOBIN=$HOME/go/bin GO111MODULE=on CGO_ENABLED="0" go${GOALT} install go.mozilla.org/sops/v3/cmd/sops@latest  ## SOPS can only be install unsing Goland <= 1.17
GOBIN=$HOME/go/bin GO111MODULE=on CGO_ENABLED="0" go install go.mozilla.org/sops/v3/cmd/sops@latest  ## SOPS v3 new install works

set +x
