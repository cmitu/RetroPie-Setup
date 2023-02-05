#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="gzdoom"
rp_module_desc="gzdoom - Modder-friendly source port based on the DOOM engine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/ZDoom/gzdoom/master/LICENSE"
rp_module_repo="git https://github.com/ZDoom/gzdoom :_get_version_gzdoom"
rp_module_section="opt"
rp_module_flags="sdl2 !armv6"

function _get_version_gzdoom() {
    local gzdoom_version="g4.10.0"
    # 32 bit is no longer supported since g4.8.1
    isPlatform "32bit" && gzdoom_version="g4.8.0"
    echo $gzdoom_version
}

function depends_gzdoom() {
    local depends=(
        libfluidsynth-dev libsdl2-dev libmpg123-dev libsndfile1-dev zlib1g-dev libbz2-dev libopenal1
        cmake libopenal-dev libjpeg-dev libgl1-mesa-dev libasound2-dev libmpg123-dev libsndfile1-dev libvpx-dev
    )
    isPlatform "x11" && depends+=(libgtk-3-dev)
    getDepends "${depends[@]}"
}

function sources_gzdoom() {
    gitPullOrClone
    # add 'zmusic' repo
    cd "$md_build"
    gitPullOrClone zmusic https://github.com/ZDoom/ZMusic
}

function build_gzdoom() {
    mkdir -p release

    # build 'zmusic' first
    pushd zmusic
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$md_build/release/zmusic" .
    make
    make install
    popd

    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DPK3_QUIET_ZIPDIR=ON -DCMAKE_BUILD_TYPE=Release -DDYN_OPENAL=ON -DCMAKE_PREFIX_PATH="$md_build/release/zmusic")
    ! hasFlags "vulkan" && params+=(-DHAVE_VULKAN=OFF)

    cmake "${params[@]}" ..
    make
    md_ret_require="$md_build/release/$md_id"
}

function install_gzdoom() {
    md_ret_files=(
        'release/brightmaps.pk3'
        'release/gzdoom'
        'release/gzdoom.pk3'
        'release/lights.pk3'
        'release/game_support.pk3'
        'release/game_widescreen_gfx.pk3'
        'release/soundfonts'
        "release/zmusic/lib/libzmusic.so.1"
        "release/zmusic/lib/libzmusic.so.1.1.11"
        'README.md'
    )
}

function add_games_gzdoom() {
    local params=("-fullscreen")
    local launcher_prefix="DOOMWADDIR=$romdir/ports/doom"

    # choose GLES2/Vulkan when available, default is OpenGL (3.3+)
    if isPlatform "gles2"; then
        params+=("+set vid_preferbackend 3")
    elif isPlatform "vulkan"; then
        params+=("+set vid_preferbackend 1")
    fi

    # FluidSynth is too memory/CPU intensive, use OPL emulation for MIDI
    if isPlatform "arm"; then
        params+=("+set snd_mididevice -3")
    fi

    if isPlatform "kms"; then
        params+=("+set vid_vsync 1" "-width %XRES%" "-height %YRES%")
    fi

    _add_games_lr-prboom "$launcher_prefix $md_inst/$md_id -iwad %ROM% ${params[*]}"
}

function configure_gzdoom() {
    mkRomDir "ports/doom"

    moveConfigDir "$home/.config/$md_id" "$md_conf_root/doom"

    [[ "$md_mode" == "install" ]] && game_data_lr-prboom

    add_games_${md_id}
}
