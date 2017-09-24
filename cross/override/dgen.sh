# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 


function build_mupen64plus() {
    rpSwap on 750

    local dir
    local params=()
    for dir in *; do
        if [[ -f "$dir/projects/unix/Makefile" ]]; then
            make -C "$dir/projects/unix" clean
            params=()
            isPlatform "rpi1" && params+=("VFP=1" "VFP_HARD=1" "HOST_CPU=armv6")
            isPlatform "rpi" && params+=("VC=1")
            isPlatform "neon" && params+=("NEON=1")
            isPlatform "x11" && params+=("OSD=1" "PIE=1")
            isPlatform "x86" && params+=("SSE=SSSE3")
            [[ "$dir" == "mupen64plus-ui-console" ]] && params+=("COREDIR=$md_inst/lib/" "PLUGINDIR=$md_inst/lib/mupen64plus/")
            # MAKEFLAGS replace removes any distcc from path, as it segfaults with cross compiler and lto
            MAKEFLAGS="${MAKEFLAGS/\/usr\/lib\/distcc:/}" make -C "$dir/projects/unix" all "${params[@]}" OPTFLAGS="$CFLAGS -O3 -flto"
        fi
    done

    # build GLideN64
    "$md_build/GLideN64/src/getRevision.sh"
    pushd "$md_build/GLideN64/projects/cmake"
    params=("-DMUPENPLUSAPI=On" "-DUSE_SYSTEM_LIBS=On" "-DVEC4_OPT=On")
    isPlatform "neon" && params+=("-DNEON_OPT=On")
    if isPlatform "rpi3"; then 
        params+=("-DCRC_ARMV8=On")
    else
        params+=("-DCRC_OPT=On")
    fi
    params+=("-DCMAKE_TOOLCHAIN_FILE=${__cross_cmake_toolchain_file}")
    cmake "${params[@]}" ../../src/
    make
    popd

    rpSwap off
    md_ret_require=(
        'mupen64plus-ui-console/projects/unix/mupen64plus'
        'mupen64plus-core/projects/unix/libmupen64plus.so.2.0.0'
        'mupen64plus-audio-sdl/projects/unix/mupen64plus-audio-sdl.so'
        'mupen64plus-input-sdl/projects/unix/mupen64plus-input-sdl.so'
        'mupen64plus-rsp-hle/projects/unix/mupen64plus-rsp-hle.so'
        'GLideN64/projects/cmake/plugin/release/mupen64plus-video-GLideN64.so'
    )
    if isPlatform "rpi"; then
        md_ret_require+=(
            'mupen64plus-video-gles2rice/projects/unix/mupen64plus-video-rice.so'
            'mupen64plus-video-gles2n64/projects/unix/mupen64plus-video-n64.so'
            'mupen64plus-audio-omx/projects/unix/mupen64plus-audio-omx.so'
        )
    else
        md_ret_require+=(
            'mupen64plus-video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so'
            'mupen64plus-rsp-z64/projects/unix/mupen64plus-rsp-z64.so'
        )
        if isPlatform "x86"; then
            md_ret_require+=('mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4-ssse3.so')
        else
            md_ret_require+=('mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4.so')
        fi
    fi
}

