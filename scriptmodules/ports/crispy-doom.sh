#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="crispy-doom"
rp_module_desc="Crispy Doom is a limit-removing enhanced-resolution Doom source port based on Chocolate Doom"
rp_module_licence="GPL2 https://raw.githubusercontent.com/fabiangreffrath/crispy-doom/master/COPYING.md"
rp_module_repo="git https://github.com/fabiangreffrath/crispy-doom.git master"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_crispy-doom() {
    local depends=(cmake libpng-dev libsamplerate0-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev zlib1g-dev)
    getDepends "${depends[@]}"
}

function sources_crispy-doom() {
    gitPullOrClone
}

function build_crispy-doom() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release)
    cmake "${params[@]}" ..
    make crispy-doom crispy-heretic crispy-hexen
    md_ret_require="$md_build/release/src/$md_id"
}

function install_crispy-doom() {
    md_ret_files=(
        'release/src/crispy-doom'
        'release/src/crispy-heretic'
        'release/src/crispy-hexen'
        'README.md'
        'COPYING.md'
    )
}

function add_games_crispy-doom() {
    local params=("-fullscreen -nogui")
    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"
    _add_games_lr-prboom "$launcher_prefix $md_inst/$md_id -iwad %ROM% ${params[*]}"
}

function configure_crispy-doom() {
    mkRomDir "ports/doom"

    moveConfigDir "$home/.local/share/$md_id" "$md_conf_root/doom/crispy-doom"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom

    add_games_${md_id}
}
