#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gsplus"
rp_module_desc="Apple IIgs Emulator based on KEGS"
rp_module_help="ROM/Disk Extensions: .2img .po\n\nCopy your floppy images to $romdir/apple2\n\nCopy bios files ROM,ROM1,ROM3 to $biosdir/apple2"
ro_module_license="GPL2 https://raw.githubusercontent.com/digarok/gsplus/master/LICENSE.txt"
rp_module_section="exp"
rp_module_flags=""

function depends_gsplus() {
    getDepends re2c libsdl2-dev libsdl2-image-dev libfreetype6-dev libpcap0.8-dev libreadline-dev
}

function sources_gsplus() {
    gitPullOrClone "$md_build" https://github.com/digarok/gsplus.git
}

function build_gsplus() {
    mkdir "$md_build/build"
    pushd "$md_build/build"

    cmake ../ -DDRIVER=SDL2 -DWITH_DEBUGGER=OFF
    make
    popd

    md_ret_require="build/bin/GSplus"
}

function install_gsplus() {
    md_ret_files=(
        "build/bin/GSplus"
        "lib"
        "README.md"
        "LICENSE.txt"
    )
}

function _default_config_gsplus() {
    local config="$(mktemp)"

    iniConfig " = " '' "$config"
    iniSet g_cfg_rom_path "$biosdir/apple2/APPLE2GS.ROM"

    echo "$config"
}

function configure_gsplus() {
    mkRomDir "apple2"
    addSystem "apple2"

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$biosdir/apple2gs"
    addEmulator 0 "$md_id" "apple2" "$md_inst/GSplus -fullscreen -borderless %ROM%"

    local config
    config=$(_default_config_gsplus)
    copyDefaultConfig "$config" "$md_conf_root/apple2/gsplus.ini"
    moveConfigFile "$home/.config.gsp" "$md_conf_root/apple2/gsplus.ini"

    # Remove un-necessary files copied by the installer in 'lib'
    rm -fr "$md_inst/lib/arch"
}
