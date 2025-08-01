#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-gearcoleco"
rp_module_desc="ColecoVision emulator - libretro core"
rp_module_help="ROM Extensions: .col .cv .bin .rom\nCopy your ColecoVision roms to $romdir/coleco\nCopy the BIOS file to $biosdir/colecovision.rom"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/gearcoleco/master/LICENSE"
rp_module_repo="git https://github.com/drhelius/gearcoleco.git main"
rp_module_section="exp"

function sources_lr-gearcoleco() {
    gitPullOrClone
}

function build_lr-gearcoleco() {
    cd platforms/libretro
    make clean
    make
    md_ret_require="$md_build/platforms/libretro/gearcoleco_libretro.so"
}

function install_lr-gearcoleco() {
    md_ret_files=(
        'platforms/libretro/gearcoleco_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-gearcoleco() {
    mkRomDir "coleco"
    defaultRAConfig "coleco"
    addEmulator 0 "$md_id" "coleco" "$md_inst/gearcoleco_libretro.so"
    addSystem "coleco"
}
