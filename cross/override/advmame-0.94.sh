# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function build_advmame-0.94() {
    ./configure --host=${__cross_arch} CFLAGS="$CFLAGS -fsigned-char" LDFLAGS="$LDFLAGS -s -lm -Wl,--no-as-needed" --prefix="$md_inst"
    make clean
    make
}
