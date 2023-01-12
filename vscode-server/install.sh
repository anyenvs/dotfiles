#!/usr/bin/env bash

#set -e
ls *.env &>/dev/null && . *.env || true
export BASH_SOURCE_DIR="$(dirname $(readlink -f ${BASH_SOURCE:-$0}))" BASH_SOURCE_DIR_UP="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE:-$0}))/../)";
export DOTFILES_PATH="$( readlink -f $(ls -d ${DOTFILES_PATH:-$BASH_SOURCE_DIR}/_helpers 2>/dev/null || ls -d ${DOTFILES_PATH:-$BASH_SOURCE_DIR_UP}/_helpers 2>/dev/null) | xargs dirname )"
test -z "${_HELPERS}" && _HELPERS=($(find "${DOTFILES_PATH}"/_helpers -name *.bash 2>/dev/null));
for h in ${_HELPERS[@]} ;do . "$h" ;done
test -n "$_HELPERS" || _error "===> ❌ _HELPERS env var is missing in $0"
echo _HELPERS = "${_HELPERS[@]}"

test -d "${DOTFILES_PATH}/vscode/.vscode"
#test -f "${HOME}/Library/Application Support/Code/User/settings.json" && {
#        _log "===> File: $(ls -l "${HOME}/Library/Application Support/Code/User/settings.json")\n ===> Remove file before symlinking" ;
#        return ;
#    } || ln -svnf "${DOTFILES_PATH}"/vscode/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"
#test -f "${HOME}/Library/Application Support/Code/User/keybindings.json" && {
#        _log "===> File: $(ls -l "${HOME}/Library/Application Support/Code/User/keybindings.json")\n ===> Remove file before symlinking" ;
#        return ;
#    } || ln -svnf "${DOTFILES_PATH}"/vscode/keybindings.json "${HOME}/Library/Application Support/Code/User/keybindings.json"

_vscode-server-install() {
    curl -fsSL https://code-server.dev/install.sh | sed '/arm64)/ i \\tarmv7l) return 0 ;;' | sh
}

CODE_EXTENSIONS=( )
#for ext in "${CODE_EXTENSIONS[@]}"; do printf "installing %s\n" "${ext}" && code --install-extension "${ext}" --force; done

DATA_1=/mnt/HD/HD_a2/DATA_1
DATA_1_APPS=${DATA_1}/opt/repos/_dotfiles
DATA_1_ARMV7=${DOTFILES_PATH}/linux-armv7/armv7-android-tools
LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/lib/git-core
PATH=$PATH:/lib/git-core
#export GIT_TRACE2=2 GIT_CURL_VERBOSE=1

__main__() {
    _log '===> VSCode Server Install' ;
    ## link git if missing
    for i in lib ;do ( cd ${DOTFILES_PATH}/linux-armv7/armv7-android-tools ; test -d ${i} && cp -fv ${i}/lib* /lib/ ) ;done
    for i in lib/git-core.tar.gz ;do ( cd ${DOTFILES_PATH}/linux-armv7/armv7-android-tools ; test -f ${i} && tar zxvf ${i} -C /lib/ ) ;done
    for i in bin/git bin/vim bin/sops bin/strace bin/tcpdump ;do eval which ${i##*/} || ( cd /usr/local/bin ; test -f ${DATA_1_ARMV7}/${i} && ln -svnf ${DATA_1_ARMV7}/${i} ${i##*/} ; chmod +x ${i##*/} ) ;done
    ##
    echo -e '## https://github.com/coder/code-server/blob/main/docs/FAQ.md#how-do-i-debug-issues-with-code-server \n## https://coder.com/docs/code-server/latest/install#installsh \n## https://technixleo.com/running-vs-code-code-server-in-docker-docker-compose/\n## https://github.com/linuxserver/docker-code-server\n## https://hub.docker.com/r/linuxserver/code-server/tags?page=1&name=arm'
    _sops-decrypt ${DOTFILES_PATH}/vscode-server/.config/code-server/code-config.yaml ;
    echo 'VSCode Server Standalone install: ${DOTFILES_PATH}/vscode-server/install.sh _vscode-server-install' ;
    echo 'VSCode Server docker-compose: ( cd '${DOTFILES_PATH}'/vscode-server ; docker-compose config --services )' ;
    echo 'VSCode Server docker-compose: ( cd '${DOTFILES_PATH}'/vscode-server ; docker-compose -d up code-server)' ;
    echo 'VSCode Server build docker: ( cd '${DOTFILES_PATH}'/vscode-server ; docker-compose build build-code-server)' ;
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__
set +x
