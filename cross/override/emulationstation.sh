# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function sources_emulationstation() {
    local repo="$1"
    local branch="$2"
    [[ -z "$repo" ]] && repo="https://github.com/RetroPie/EmulationStation"
    [[ -z "$branch" ]] && branch="master"
    gitPullOrClone "$md_build" "$repo" "$branch"
    echo "Running from `pwd`"
    applyPatch "$xscriptdir/override/${md_id}/01.sysroot-add.diff"
}


function build_emulationstation() {

    echo "Using Cross compile file at ${__cross_cmake_toolchain_file}"
    cmake -DCMAKE_TOOLCHAIN_FILE=${__cross_cmake_toolchain_file} .
    make clean
    make
    
    md_ret_require="$md_build/emulationstation"

}
