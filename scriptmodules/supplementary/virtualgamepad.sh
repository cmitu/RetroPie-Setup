#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="virtualgamepad"
rp_module_desc="Virtual Gamepad for Smartphone"
rp_module_licence="MIT https://raw.githubusercontent.com/jehervy/node-virtual-gamepads/master/LICENSE"
rp_module_section="exp"
rp_module_flags="noinstclean nobin"

function depends_virtualgamepad() {
    local nodejs_ver="$(apt-cache show nodejs | grep -m1 Version | cut -d' ' -f 2)"
    local npm_ver="$(apt-cache show npm | grep -m1 Version | cut -d' ' -f 2)"

    # Check if we have at least Node 8.x and NPM 5.x, otherwise install a LTS version from NodeSource
    # Handle Ubuntu 18.x the same way, since it doesn't have an installable NPM - see LP#1809828
    if [ -n "$__os_ubuntu_ver" ] && compareVersions "$__os_ubuntu_ver" lt 19.04; then
        _install_nodejs_virtualgamepad
    elif compareVersions "$nodejs_ver" lt 8.0 || compareVersions "$npm_ver" lt 5.0; then
        _install_nodejs_virtualgamepad
    else
        getDepends nodejs npm
    fi
}

function remove_virtualgamepad() {
    pm2 delete main
    pm2 save --force
    pm2 -s unstartup systemd
    pm2 kill
    [ -f /etc/apt/sources.list.d/nodesource.list ] && rm -f /etc/apt/sources.list.d/nodesource.list
}

function sources_virtualgamepad() {
    gitPullOrClone "$md_inst" https://github.com/jehervy/node-virtual-gamepads develop
}

function install_virtualgamepad() {
    chown -R $user:$user "$md_inst"
    cd "$md_inst"
    sudo -u $user npm install
    npm install pm2 -g
}

function configure_virtualgamepad() {
    [[ "$md_mode" == "remove" ]] && return
    pm2 update
    pm2 delete main
    pm2 start main.js
    pm2 startup systemd
    pm2 save
}

function _install_nodejs_virtualgamepad() {
    local nodejs_ver="$(apt-cache show nodejs | grep -m1 Version | cut -d' ' -f 2)"

    # Run the NodeSource installer only for new installations
    if [[ ! "$nodejs_ver" =~ .*nodesource ]] || compareVersions "$nodejs_ver" lt 10.0;  then
        # The NodeSource package includes npm, so delete the distro one
        hasPackage npm && aptRemove npm
        wget -qO- https://deb.nodesource.com/setup_10.x | bash -
    fi
    aptInstall nodejs
}
