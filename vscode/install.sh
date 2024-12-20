#!/usr/bin/env bash

[ -n "${DEBUG}" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] ' ; set -x; }
set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH=${DOTFILES_PATH:-.}
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/ -name _helpers.bash 2>/dev/null |sort));. $_HELPERS
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"

test -d "${DOTFILES_PATH}/vscode/.vscode"
test -f "${HOME}/Library/Application Support/Code/User/settings.json" && {
        _log "===> File: $(ls -l "${HOME}/Library/Application Support/Code/User/settings.json")\n ===> Remove file before symlinking" ;
        return ;
    } || ln -svnf "${DOTFILES_PATH}"/vscode/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"
test -f "${HOME}/Library/Application Support/Code/User/keybindings.json" && {
        _log "===> File: $(ls -l "${HOME}/Library/Application Support/Code/User/keybindings.json")\n ===> Remove file before symlinking" ;
        return ;
    } || ln -svnf "${DOTFILES_PATH}"/vscode/keybindings.json "${HOME}/Library/Application Support/Code/User/keybindings.json"

CODE_EXTENSIONS=(
    andyyaldoo.vscode-json
    DavidAnson.vscode-markdownlint
    dbaeumer.vscode-eslint
    oderwat.indent-rainbow
    johnpapa.vscode-peacock
    shardulm94.trailing-spaces
    jakearl.search-editor-apply-changes
    eamodio.gitlens
    esbenp.prettier-vscode
    github.remotehub
    github.vscode-pull-request-github
    mhutchie.git-graph
    donjayamanne.githistory
    nhoizey.gremlins
    golang.go
    hashicorp.terraform
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-vscode-remote.remote-containers
    ms-python.python
    formulahendry.code-runner
    ionutvmi.path-autocomplete
    redhat.vscode-yaml
)
#for ext in "${CODE_EXTENSIONS[@]}"; do printf "installing %s\n" "${ext}" && code --install-extension "${ext}" --force; done

__main__() { _log 'VSCode' ; }
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
