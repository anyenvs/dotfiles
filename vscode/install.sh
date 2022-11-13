#!/usr/bin/env bash

set -e
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH=${DOTFILES_PATH:-.}
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find ${DOTFILES_PATH}/ -name a_common_functions.bash 2>/dev/null));. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"

test -d "${DOTFILES_PATH}/vscode/.vscode"
test -f "${HOME}/Library/Application Support/Code/User/settings.json" || ln -sf "${DOTFILES_PATH}/vscode/settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
test -f "${HOME}/Library/Application Support/Code/User/keybindings.json" || ln -sf "${DOTFILES_PATH}/vscode/keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"

CODE_EXTENSIONS=(
    DavidAnson.vscode-markdownlint
    dbaeumer.vscode-eslint
    eamodio.gitlens
    esbenp.prettier-vscode
    # felixfbecker.php-intellisense
    github.remotehub
    github.vscode-pull-request-github
    golang.go
    hashicorp.terraform
    ms-azuretools.vscode-docker
    ms-vscode-remote.remote-containers
    ms-python.python
    sdras.night-owl
    streetsidesoftware.code-spell-checker
    # timonwong.shellcheck
    Tyriar.sort-lines
)
#for ext in "${CODE_EXTENSIONS[@]}"; do printf "installing %s\n" "${ext}" && code --install-extension "${ext}" --force; done

__main__() { _log 'VSCode' ; }
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
