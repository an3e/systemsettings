#!/bin/bash

SCRIPTS_DIR="${HOME}/.scripts/"
SCRIPTS_LIB_DIR="${SCRIPTS_DIR}/lib"
[[ ! -d ${SCRIPTS_DIR} ]] \
    && mkdir -p ${SCRIPTS_DIR} \
    && git clone git@github.com:an3e/scripts.git ${SCRIPTS_DIR}

source "${SCRIPTS_LIB_DIR}/runtime.sh"

###############################################################################

doInitUbuntu() {
    apt-cache policy | grep http://dl.google.com/linux/chrome/deb &>/dev/null \
        || {
            wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - \
            && sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'
        }
    sudo apt update \
    && sudo apt upgrade \
    && sudo apt install -y \
        apt-file \
        build-essential \
        cmake curl \
        filezilla fortune-mod \
        google-chrome-stable g++-5 clang-6.0 clang-format-6.0 clang-tidy-6.0 \
        kde-plasma-desktop \
        meld \
        papirus-icon-theme python3-dev \
        rar \
        samba sddm \
        thunderbird tig \
        vim vlc \
        yakuake \
        wget \
        zsh \
    && sudo apt-file update
}

###############################################################################

doInitArch() {
    pacman -Syu \
        alsa-utils ark \
        base-devel breeze-gtk \
        calibre clang cmake cups curl \
        filezilla fortune-mod \
        git gwenview \
        kate kde-graphics-thumbnailers kde-gtk-config kde-network-filesharing konsole \
        meld \
        okular openssh \
        p7zip plasma-meta print-manager \
        xf86-video-nouveau \
        tig \
        unarchiever unrar \
        vim vlc \
        yakuake \
        wget \
        zsh \
    || return 1;

    gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53 \
        && cd /tmp \
        && wget -q -O https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz | tar xvf \
        && cd cower \
        && makepkg -si \
        && cd /tmp \
        && wget -q -O https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz | tar xvf \
        && cd pacaur \
        && makepkg -si \
        || return 3;

    pacaur -Syu \
        google-chrome \
        visual-studio-code-bin
}

###############################################################################

doInit() {
    case $(cat /etc/os-release | grep ^NAME 2>/dev/null) in
        *Ubuntu*) doInitUbuntu ;;
        *Arch*)   doInitArch   ;;
        *) ;;
    esac
}

###############################################################################

doSetup() {
    # link all hidden files in repository to ${HOME}/
    isInstalled realpath || return 1;
    for file in .*; do
        local srcfile="$(realpath ${file})"
        local dstfile="${HOME}/${file}"
        [[ -f ${srcfile} ]] \
            && printf "[%s] --> [%s]\n" ${srcfile} ${dstfile} \
            && ln -sf ${srcfile} ${dstfile}
    done
}

###############################################################################

isSourced \
    && printf "This script is not allowed to be sourced!!!\n" \
    && printf "Please execute it.\n" \
    && return 1

_doInit=""
while [ $# -gt 0 ]; do
    case "${1}" in
        -i|--init) _doInit="true" ;;
        *) printf "Unknown argument [%s]\n" "${1}" && exit 3 ;;
    esac
    shift 1;
done

[[ -n "${_doInit}" ]] && doInit
isInstalled realpath || exit 1;

case $(git config --get remote.origin.url 2>/dev/null) in
    git@github.com:an3e/systemsettings*)
        doSetup && setupDone="true"
        ;;
    *)  ;;
esac

[[ -z ${setupDone} ]] \
    && printf "Nothing has been done.\n" \
    && exit 1

exit 0
