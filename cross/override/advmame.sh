# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function build_advmame() {

    ./configure --prefix="$md_inst" --host=${__cross_arch}
    make clean
    make

}
