# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 


function build_zdoom() {
    rm -rf release
    mkdir -p release
    cd release
    local params=(-DCMAKE_INSTALL_PREFIX="$md_inst" -DCMAKE_BUILD_TYPE=Release)
    cmake -DCMAKE_TOOLCHAIN_FILE=${__cross_cmake_toolchain_file} "${params[@]}" ..
    make
    md_ret_require="$md_build/release/zdoom"    

}
