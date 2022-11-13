#!/usr/bin/env bash

#set -e
set -x
ls *.env &>/dev/null && . *.env || true
DOTFILES_PATH=${DOTFILES_PATH:-..}
test -z "${A_COMMON_FUNCTIONS}" && A_COMMON_FUNCTIONS=($(find ${DOTFILES_PATH}/ -name a_common_functions.bash 2>/dev/null)) ;. $A_COMMON_FUNCTIONS
test -n "$A_COMMON_FUNCTIONS" || _error "===> ❌ A_COMMON_FUNCTIONS env var is missing in $0"
export COMPDIR=/etc/bash_completion.d
test -d "$COMPDIR" || mkdir -p $COMPDIR
set +x

###
# ANYENV Installation of ENVS
###
_ANYENV_ENVS=(
  ANYENV
  KREW
  GOENV PYENV JENV NODENV TFENV BAZELENV
  HELMENV HELMFILENV ISTIOENV
  #OPSDKENV
)
##ALL_PACKAGES=("${IBREW_PACKAGES[@]}" "${ABREW_PACKAGES[@]}")
for env in ${_ANYENV_ENVS[@]^^} ;do export ${env^^}_ROOT=$HOME/.${env,,} ;done
for env in ${_ANYENV_ENVS[@]^^} ;do val=$(env|grep "${env^^}_ROOT="|head -1) ; test -n "${val}" && export ANYENV_ENVS=${ANYENV_ENVS}:${val##*=}/bin:${val##*=}/shims ;done

#export ANYENV_ROOT=$HOME/.anyenv KREW_ROOT=$HOME/.krew GOENV_ROOT=$HOME/.goenv PYENV_ROOT=$HOME/.pyenv JENV_ROOT=$HOME/.jenv NODENV_ROOT=$HOME/.nodenv TFENV_ROOT=$HOME/.tfenv BAZELENV_ROOT=$HOME/.bazelenv HELMENV_ROOT=$HOME/.helmenv HELMFILENV_ROOT=$HOME/.helmfilenv ISTIOENV_ROOT=$HOME/.istioenv
#export ANYENV_ENVS=$KREW_ROOT/bin:$GOENV_ROOT/bin:$GOENV_ROOT/shims:$PYENV_ROOT/bin:$PYENV_ROOT/shims:$JENV_ROOT/bin:$JENV_ROOT/shims:$NODENV_ROOT/bin:$NODENV_ROOT/shims:$TFENV_ROOT/bin:$TFENV_ROOT/shims:$BAZELENV_ROOT/bin:$BAZELENV_ROOT/shims:$HELMENV_ROOT/bin:$HELMENV_ROOT/shims:$HELMFILENV_ROOT/bin:$HELMFILENV_ROOT/shims:$ISTIOENV_ROOT/bin:$ISTIOENV_ROOT/shims
export GO111MODULE=on CGO_ENABLED="0" GOBIN=${HOME}/go/bin GOPATH=${HOME}/.go
export PATH=$(echo -n "$HOME/bin:$HOME/.local/bin:$ANYENV_ROOT/bin:$ANYENV_ENVS:$PATH" | awk -v RS=: -v ORS=: '!x[$0]++' | sed "s/\(.*\).\{1\}/\1/")
echo -e 'verbose=off \nprogress=bar:force:noscroll \nshow_progress=on \n' > ~/.wgetrc; cat ~/.wgetrc ;
#eval which {git,gpg,wget} || getInstaller install wget gnupg2 git-core -y;

#_aptget(){ set_stat=$- ; set +x ; [[ $set_stat =~ [x] ]] && { set +x ; set_x_true=1 ; }; local _aptget=({$(command -v apt-get),$(command -v apt),$(command -v yum),$(command -v brew)}); echo ${_aptget[${1:-0}]}; test -z "$set_x_true" || { unset set_x_true;set -x ; }; }  # get possible package manager in order: echo ${_apt[*]} ${_apt[@]} ${!_apt[@]}
#aptGetInstall() { runAsRoot $(_aptget) update -yqq && runAsRoot $(_aptget) install "${@}" --no-install-recommends -y >/dev/null; }
#runAsRoot() { if [ $EUID -ne 0 -a "$USE_SUDO" = "true" ]; then sudo "${@}"; else ${@}; fi || su -c "${@}" ; }
#isPackageInstalled() { test -n "$(command -v $1)" -a -d $(ls -d1 ${HOME}/{.*,*} | grep $1 | head -1) && { _log "===> Binary: $(command -v $1)\n ===> DIR: $(ls -d1 ${HOME}/{.*,*} | grep $1)"; return 0; } || { _error "Missing or Binary in PATH\n ===> DIR: $(ls -d1 ${HOME}/{.*,*} | grep $1) \n ===> Binary in PATH: $(command -v $1)"; return -1; }; set +x; }
#getInstaller() { _cmd=( $(eval which {apt-get,dnf,yum,brew}) ); test -n ${_cmd} || return 1; echo ${_cmd[@]}; echo ${_cmd}; }

_setup_anyenv() {
    local anyenvs=(goenv jenv nodenv pyenv tfenv bazelenv helmenv helmfilenv)
    test -n "${ANYENV_ENVS}" && export PATH=$(echo -n "$HOME/bin:$HOME/.local/bin:$ANYENV_ROOT/bin:$ANYENV_ENVS:$PATH" | awk -v RS=: -v ORS=: '!x[$0]++' | sed "s/\(.*\).\{1\}/\1/")
    echo -e 'verbose=off \nprogress=bar:force:noscroll \nshow_progress=on \n' > ~/.wgetrc; cat ~/.wgetrc ;
    eval which {git,gpg,wget} || _Install install wget gnupg2 git-core ;
    _log "===> anyenv install -l | xargs -n1 anyenv install --force --link \n ===> echo ${anyenvs[@]} | xargs -n1 anyenv install --force --link \n ===> _setup_completions \$(anyenv envs | xargs) \n ===> anyenv install -l" ;
    _log "===> _setup_completion ANYENV \$(anyenv envs | xargs)" ;
    isAnyEnvInstalled anyenv $$ ; test "$?" -eq "0" && { return; set +x; }
    touch ~/.bashrc ;
    _log "===> Installing AnyEnv" ;
    #git clone --branch=master --depth=1 https://github.com/anyenv/anyenv $HOME/.anyenv ;
    git clone --branch=main --depth=1 https://github.com/anyenvs/anyenv $ANYENV_ROOT ;
    mkdir -p $(anyenv root)/plugins ;
    test -d $(anyenv root)/plugins/anyenv-update || git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update ;
    echo -e 'export ANYENV_ROOT='$HOME/.anyenv > ~/.anyenvrc ;
    echo -e 'export PATH=$(echo -n "$HOME/bin:$HOME/.local/bin:$ANYENV_ROOT/bin:$ANYENV_ROOT/shims:$ANYENV_ROOT:$PATH" | awk -v RS=: -v ORS=: '\''!x[$0]++'\'' | sed "s/\(.*\).\{1\}/\1/")' >> ~/.anyenvrc ;
    echo -e 'anyenv init\neval "$(anyenv init -)"\nanyenv install --force-init' >> ~/.anyenvrc ;
    ## if .anyenvrc exist and not in .bashrc
    test -z "$(grep '~/.anyenvrc' ~/.bashrc)" -a -f ~/.anyenvrc && echo -e '. ~/.anyenvrc' >> ~/.bashrc ;
    ## Enable AnyENV completion
    test -f "$HOME/.anyenv/completions/anyenv.bash" && echo '. ~/.anyenv/completions/anyenv.bash' >> ~/.anyenvrc
    test -f "$HOME/.anyenvrc" && . ~/.anyenvrc ;
    ## Creating symlinks for anyenv envs in $HOME
    anyenv install -l | xargs -n1 anyenv install --force --link

    ## Enable completions
    _setup_completion ANYENV $(anyenv envs | xargs)
    _log '===> Restart SHELL\n exec $SHELL' ;
    _log "===> anyenv install -l | xargs -n1 anyenv install --force --link \n ===> echo ${anyenvs[@]} | xargs -n1 anyenv install --link \n ===> _setup_completions \$(anyenv envs | xargs) \n ===> anyenv install -l" ;
    set +xe ;
}

_setup_anyenv_completions() { _setup_completion ANYENV; }
_setup_pyenv_completion() { _setup_completion PYENV; }
_setup_nodenv_completion() { _setup_completion NODENV; }
_setup_jenv_completion() { _setup_completion JENV; }
_setup_tfenv_completion() { _setup_completion TFENV; }
_setup_helmenv_completion() { _setup_completion HELMENV; }
_setup_completions() { _setup_completion $@; }

_setup_completion() {
  unset POSIXLY_CORRECT
  local envs=$@
  export GO111MODULE=on CGO_ENABLED="0" GOBIN=${HOME}/go/bin GOPATH=${HOME}/.go
  [[ "${envs,,}" == *"goenv"* ]] && export GOENV_PREFIX=$(goenv prefix)/bin
  export JAVA_PACKAGES=openjdk-11-jdk-headless JENV_ROOT=$HOME/.jenv JENV_PATH=$HOME/.jenv
  export JAVA_PATHS=/Library/Java/JavaVirtualMachines,/System/Library/Java/JavaVirtualMachines,/usr/local/Cellar/openjdk*/bash_completion.d,/usr/lib/jvm
  test -n "${ANYENV_ENVS}" && export PATH=$(echo -n "$HOME/bin:$HOME/.local/bin:$ANYENV_ROOT/bin:${GOPATH}/bin:${GOENV_PREFIX}:$ANYENV_ENVS:$PATH" | awk -v RS=: -v ORS=: '!x[$0]++' | sed "s/\(.*\).\{1\}/\1/")

  for env in ${envs}; do
    _log "===> Enable ${env^^} completion"
    ## Filling .${env,,}rc
    echo -e 'export '${env^^}'_ROOT="$HOME/.'${env,,}'"' > ~/.${env,,}rc
    test ${env,,} == "jenv" && echo -e 'export JAVA_PATHS='${JAVA_PATHS} >> ~/.${env,,}rc
    test ${env,,} == "jenv" && echo -e 'test -z "${JAVA_PATHS}" || for i in $(echo ${JAVA_PATHS//,/\/* }/*); do [[ -d ${i} ]] && { [[ -d ${i}/bin ]] && jenv add $i || jenv add ${i}/Contents/Home/; }; done' >> ~/.${env,,}rc
    test ${env,,} == "pyenv" && echo -e 'export PYTHONPATH=$(python -c "import site; print(site.getsitepackages()[0])")' >> ~/.${env,,}rc
    echo -e 'export PATH=$(echo -n "$HOME/bin:$HOME/.local/bin:$'${env^^}'_ROOT/bin:'${env^^}'_ROOT/shims:$PATH" | awk -v RS=: -v ORS=: '\''!x[$0]++'\'' | sed "s/\(.*\).\{1\}/\1/")' >> ~/.${env,,}rc
    echo -e 'command -v '${env,,}' && eval "$('${env,,}' init --path)" && eval "$('${env,,}' init -)"' >> ~/.${env,,}rc
    ## if .${env,,}rc exist and not in .bashrc
    test -z "$(grep ${env,,}rc ~/.bashrc)" -a -f ~/.${env,,}rc && echo -e '. ~/.'${env,,}'rc' >> ~/.bashrc
  done
  set +x

  ## Enable AnyENV completion
  grep -q anyenv.bash $HOME/.anyenvrc || echo '. ~/.anyenv/completions/anyenv.bash' >> ~/.anyenvrc
  test -f "$HOME/.anyenvrc" && . ~/.anyenvrc

  ## Enable GOENV completion
  [[ "${envs,,}" == *"goenv"* ]] && wget -O $COMPDIR/goenv-completion.bash https://raw.githubusercontent.com/syndbg/goenv/master/completions/goenv.bash
  test -f $COMPDIR/goenv-completion.bash && . $COMPDIR/goenv-completion.bash >/dev/null || true
  ## Enable GO completion
  ## https://raw.githubusercontent.com/kura/go-bash-completion/main/etc/bash_completion.d/go
  [[ "${envs,,}" == *"goenv"* ]] && wget -O $GOENV_ROOT/completions/go-completion.bash https://raw.githubusercontent.com/anyenvs/go-completion/main/.goenv/completions/go-completion.bash
  test -f $GOENV_ROOT/completions/go-completion.bash && . $GOENV_ROOT/completions/go-completion.bash >/dev/null || true
  #complete -C /root/go/1.17.0/bin/gocomplete go
  ## GOENV links
  [[ "${envs,,}" == *"goenv"* ]] && ln -svnf ${HOME}/.go ${HOME}/go
  [[ "${envs,,}" == *"goenv"* ]] && test -d "${GOPATH}/src/github.com" || mkdir -p ${GOPATH}/{bin,src/github.com}

  ## Enable JENV completion
  [[ "${envs,,}" == *"jenv"* ]] && wget -O $COMPDIR/jenv-completion.bash https://raw.githubusercontent.com/jenv/jenv/master/completions/jenv.bash
  test -f $COMPDIR/jenv-completion.bash && . $COMPDIR/jenv-completion.bash >/dev/null || true

  ## Enable NVM completion
  test -f "${COMPDIR}/nvm-completion" || wget -O $COMPDIR/nvm-completion https://raw.githubusercontent.com/nvm-sh/nvm/master/bash_completion
  test -f "${COMPDIR}/nvm-completion" && . ${COMPDIR}/nvm-completion >/dev/null || true

  ## Enable PYENV completion
  ## Enable Poetry completion
  test -f ${HOME}/.poetry/env && . ${HOME}/.poetry/env

  ## Enable TFENV completion (not exist)
  ## TFENV links
  [[ "${envs,,}" == *"tfenv"* ]] && ln -svnf ${TFENV_ROOT}/libexec/tfenv-version-name ${TFENV_ROOT}/libexec/tfenv-global
  [[ "${envs,,}" == *"tfenv"* ]] && ln -svnf ${TFENV_ROOT}/libexec/tfenv-list ${TFENV_ROOT}/libexec/tfenv-versions
  [[ "${envs,,}" == *"tfenv"* ]] && echo 'which terraform && complete -C $(which terraform) terraform terragrunt t tg' >> $HOME/.bash_completion

  ## Enable BAZEL completion
  [[ "${envs,,}" == *"bazelenv"* ]] && test -f $(bazelenv root)/completions/*.bash && . $(bazelenv root)/completions/*.bash
  [[ "${envs,,}" == *"bazelenv"* ]] && test -f $(bazelenv bin-path)/../lib/bazel/bin/*complete*.bash && . $(bazelenv root)/versions/*/lib/bazel/bin/*complete*.bash

  ## Enable HELMENV completion
  [[ "${envs,,}" == *"helmenv"* ]] && test -f $(helmenv root)/completions/*.bash && . $(helmenv root)/completions/*.bash
  [[ "${envs,,}" == *"helmenv"* ]] && test -n "$(helmenv version-name|grep -v system)" -a -f $(helmenv bin-path)/helm && . <($( helmenv bin-path)/helm completion bash)

  ## Enable HELMFILENV completion
  [[ "${envs,,}" == *"helmfilenv"* ]] && test -f ${HELMFILENV_ROOT}/completions/helmfile.bash && . <( cat ${HELMFILENV_ROOT}/completions/*.bash ) || wget -qO ${HELMFILENV_ROOT}/completions/helmfile.bash https://raw.githubusercontent.com/roboll/helmfile/master/autocomplete/helmfile_bash_autocomplete
  [[ "${envs,,}" == *"helmfilenv"* ]] && . <( cat ${HELMFILENV_ROOT}/completions/*.bash )
}

###
# Install Anyenv packages
###
__main__() {
    eval which {anyenv,} && printf "\n🚀 ANYENV Installed at: ${ANYENV_ROOT}\n"
    echo "ANYENV_ENVS=$ANYENV_ENVS"
    if test ! $(which anyenv); then
      printf "\n🚀 Installing ANYENV manager\n"
      _setup_anyenv ${_ANYENV_ENVS[@],,}
    fi
}
# ######
# Main
# ######
test -n "$1" && $1 || __main__

set +x
