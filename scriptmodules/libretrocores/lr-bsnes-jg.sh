#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bsnes-jg"
rp_module_desc="Super Nintendo Emulator - cycle accurate emulator, fork of Bsnes v115"
rp_module_help="ROM Extensions: .bml .smc .sfc .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bsnes/master/LICENSE.txt"
rp_module_repo="git https://github.com/libretro/bsnes-jg.git libretro"
rp_module_section="opt"
rp_module_flags="!armv6 !:\$__gcc_version:-lt:7"

function sources_lr-bsnes-jg() {
    gitPullOrClone
}

function build_lr-bsnes-jg() {
    local params=(target="libretro" build="release" binary="library")
    make -C libretro clean "${params[@]}"
    make -C libretro "${params[@]}"
    md_ret_require="$md_build/libretro/bsnes-jg_libretro.so"
}

function install_lr-bsnes-jg() {
    md_ret_files=(
        'libretro/bsnes-jg_libretro.so'
        'README'
        'COPYING'
    )
}

function configure_lr-bsnes-jg() {
    mkRomDir "snes"
    defaultRAConfig "snes"

    addEmulator 0 "$md_id" "snes" "$md_inst/bsnes-jg_libretro.so"
    addSystem "snes"
}
