#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-hatari"
rp_module_desc="Atari emulator - Hatari port for libretro"
rp_module_help="ROM Extensions: .st .stx .img .rom .raw .ipf .ctr .zip\n\nCopy your Atari ST games to $romdir/atarist and the BIOS file 'tos.img' to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/hatari/main/gpl.txt"
rp_module_repo="git https://github.com/libretro/hatari.git main"
rp_module_section="opt"

function depends_lr-hatari() {
    getDepends cmake
}

function sources_lr-hatari() {
    gitPullOrClone
}

function build_lr-hatari() {
    rm -fr build && mkdir build && cd build
    cmake -S .. -DENABLE_LIBRETRO=ON -DENABLE_HATARI=OFF -DENABLE_TOOLS=OFF -DENABLE_STATIC_ZLIB=ON -DENABLE_STATIC_CAPSIMAGE=ON
    make
    md_ret_require="$md_build/build/src/hatari_libretro.so"
}

function install_lr-hatari() {
    md_ret_files=(
        'build/src/hatari_libretro.so'
        'readme.txt'
        'gpl.txt'
    )
}

function configure_lr-hatari() {
    mkRomDir "atarist"
    defaultRAConfig "atarist"

    # move any old configs to new location
    moveConfigDir "$home/.hatari" "$md_conf_root/atarist"

    addEmulator 1 "$md_id" "atarist" "$md_inst/hatari_libretro.so"
    addSystem "atarist"
}
