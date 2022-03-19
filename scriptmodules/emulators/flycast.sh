#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="flycast"
rp_module_desc="Multi-platform Sega Dreamcast, Naomi and Atomiswave emulator derived from Reicast"
rp_module_help="Dreamcast ROM Extensions: .cdi .gdi .chd .m3u, Naomi/Atomiswave ROM Extension: .zip\n\nCopy your Dreamcast/Naomi roms to $romdir/dreamcast\n\nCopy the required Dreamcast BIOS file dc_boot.bin to $biosdir/dc\n\nCopy the required Naomi/Atomiswave BIOS files naomi.zip and awbios.zip to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/flyinghead/flycast/master/LICENSE"
rp_module_repo="git https://github.com/flyinghead/flycast.git master"
rp_module_section="opt"
rp_module_flags="!armv6"

function depends_flycast() {
    local depends=(cmake libasound2-dev libevdev-dev libsdl2-dev libudev-dev libzip-dev libminiupnpc-dev liblua5.3-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles-dev libgl-dev)
    isPlatform "x11" && depends+=(libpulse-dev)
    getDepends "${depends[@]}"
}

function sources_flycast() {
    gitPullOrClone
}

function build_flycast() {
    local params=("-DCMAKE_BUILD_TYPE=Release" "-DUSE_HOST_LIBZIP=On")
    local cxx_flags=()

    isPlatform "gles2" && params+=("-DUSE_GLES2=On")
    isPlatform "gles3" && params+=("-DUSE_GLES=On")
    if isPlatform "videocore"; then
        params+=("-DUSE_VIDEOCORE=On")
        cxx_flags+=("-DUSE_OMX")
    fi
    ! isPlatform "x86" && params+=("-DUSE_VULKAN=Off")
    mkdir -p build
    cd build
    CXXFLAGS="${cxx_flags[@]}" cmake "${params[@]}" ..
    make clean
    make
    md_ret_require="$md_build/build/flycast"
}

function install_flycast() {
    md_ret_files=(
        'build/flycast'
        'LICENSE'
    )
}

function configure_flycast() {
    mkRomDir "dreamcast"
    mkUserDir "$biosdir/dc"

    if isPlatform "videocore"; then
        addEmulator 1 "$md_id-omx" "dreamcast" "$md_inst/flycast --config audio:backend=omx"
    fi
    addEmulator 0 "$md_id" "dreamcast" "$md_inst/flycast --config audio:backend=auto"

    if [[ "$md_mode" == "install" ]]; then
        # Emulator configuration folder (default: $XDG_CONFIG_DIRS/flycast)
        moveConfigDir "$home/.config/flycast" "$md_conf_root/dreamcast"
        # Emulator data folder (default: $XDG_DATA_DIRS/flycast)
        moveConfigDir "$home/.local/share/flycast" "$biosdir/dc"

        local temp_conf="$(mktemp)"
        echo "Using temp conf $temp_conf"
        _generate_conf_flycast "$temp_conf"
        copyDefaultConfig "$temp_conf" "$md_conf_root/dreamcast/emu.cfg"
    fi
    addSystem "dreamcast"
}

# minimal configuration ('emu.cfg') for Flycast
function _generate_conf_flycast() {
    [ -z "$1" ] && return
    local frame_skip="off"
    local low_end="no"
    # disable video enhancements on low-end platforms
    isPlatform "armv7" || isPlatform "rpi3" && low_end="yes"

cat << EOF >> "$1"
[audio]
backend = sdl2

[config]
Dreamcast.ContentPath = $romdir/dreamcast
Dynarec.Enabled = yes
Dynarec.idleskip = yes
rend.ThreadedRendering = yes
rend.DelayFrameSwapping = no
rend.MipMaps = $low_end
rend.Fog = $low_end
rend.ModifierVolumes = $low_end

[window]
fullscreen = yes
maximized = yes
EOF
}
