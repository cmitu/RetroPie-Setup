#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-sameboy"
rp_module_desc="Open source Game Boy (DMG) and Game Boy Color (CGB) emulator"
rp_module_help="ROM Extensions: .gb .gbc .gba .zip\n\nCopy your Game Boy roms to $romdir/gb\nGame Boy Color roms to $romdir/gbc"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/SameBoy/master/LICENSE"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-sameboy() {
    gitPullOrClone "$md_build" https://github.com/libretro/sameboy.git
}

function build_lr-sameboy() {
    # build dependencies for 'rgbds'
    aptInstall libpng-dev bison flex
    gitPullOrClone "rgbds" https://github.com/rednex/rgbds
    make -C rgbds

    make -C libretro clean
    PATH=$PATH:"`pwd`/rgbds" make -C libretro
    
    md_ret_require="$md_build/build/bin/sameboy_libretro.so"
}

function install_lr-sameboy() {
    md_ret_files=(
        'build/bin/sameboy_libretro.so'
        'CHANGES.md'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-sameboy() {
    local system
    local def
    for system in gb gbc; do
        def=0
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        addEmulator "$def" "$md_id" "$system" "$md_inst/sameboy_libretro.so"
        addEmulator "$def" "${md_id}-link" "$system" "$md_inst/sameboy_libretro.so %ROM% --subsystem gb_link_2p"
        addSystem "$system"
    done
    
    # Add core option for Link Cable Layout
    setRetroArchCoreOption sameboy_screen_layout left-right
}
