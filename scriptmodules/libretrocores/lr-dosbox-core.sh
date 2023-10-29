#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-dosbox-core"
rp_module_desc="DOS emulator - A libretro core of DOSBox for use in RetroArch"
rp_module_help="ROM Extensions: .bat .com .exe .sh .conf\n\nCopy your DOS games to $ROMDIR/pc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dosbox-core/master/COPYING"
rp_module_repo="git https://github.com/libretro/dosbox-core.git libretro"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-dosbox-core() {
    if [[ "$__gcc_version" -lt 8 ]]; then
        md_ret_errors+=("Sorry, you need an OS with gcc 8 or newer to compile $md_id")
        return 1
    fi
    getDepends cmake libasound2-dev libflac-dev libogg-dev libopus-dev libopusfile-dev libmpg123-dev libsdl1.2-dev libsdl-net1.2-dev libsndfile-dev libvorbis-dev
}
function sources_lr-dosbox-core() {
    gitPullOrClone
}

function build_lr-dosbox-core() {
    local params=(BUNDLED_LIBSNDFILE=0 BUNDLED_AUDIO_CODECS=0 CMAKE_GENERATOR="Unix Makefiles" WITH_BASSMIDI=0 WITH_FLUIDSYNTH=1 WITH_VOODOO=0)
    if isPlatform "arm"; then
        if isPlatform "armv6"; then
            params+="WITH_DYNAREC=oldarm"
        else
            params+="WITH_DYNAREC=arm"
        fi
        [[ isPlatform "64bit" ]] && params+="WITH_DYNAREC=arm64"
    fi
    cd libretro
    make clean
    make "${params[@]}"
    md_ret_require="$md_build/libretro/dosbox_core_libretro.so"
}

function install_lr-dosbox() {
    md_ret_files=(
        'COPYING'
        'dosbox_core_libretro.so'
        'README'
    )
}

function configure_lr-dosbox-core() {
    mkRomDir "pc"
    defaultRAConfig "pc"

    addEmulator 0 "$md_id" "pc" "$md_inst/dosbox_core_libretro.so"
    addSystem "pc"
}
