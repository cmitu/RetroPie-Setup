#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="woof"
rp_module_desc="DOOM source port (continuation of MBF)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/fabiangreffrath/woof/master/COPYING"
rp_module_repo="git https://github.com/fabiangreffrath/woof.git master"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_woof() {
    local depends=(cmake libfluidsynth-dev libsdl2-dev libsdl2-mixer-dev libsdl2-net-dev libsndfile1-dev)
    getDepends "${depends[@]}"
}

function sources_woof() {
    gitPullOrClone
}

function build_woof() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release)
    cmake "${params[@]}" ..
    make woof
    md_ret_require="$md_build/release/src/$md_id"
}

function install_woof() {
    md_ret_files=(
        'release/src/woof'
        'autoload'
        'docs'
        'soundfonts'
        'README.md'
        'COPYING'
    )
}

function add_games_woof() {
    local params=("-fullscreen -hires -nogui")
    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"
    _add_games_lr-prboom "$launcher_prefix $md_inst/$md_id -iwad %ROM% ${params[*]}"
}

function configure_woof() {
    mkRomDir "ports/doom"

    moveConfigDir "$home/.local/share/$md_id" "$md_conf_root/doom/woof"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom

    add_games_${md_id}
}
