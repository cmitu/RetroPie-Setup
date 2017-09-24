# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function build_fuse() {
    pushd libspectrum
    ./configure --disable-shared --host=${__cross_arch}
    make clean
    make
    popd
    ./configure --host=${__cross_arch} --prefix="$md_inst" --without-libao --without-gpm --without-gtk --without-libxml2 --with-sdl LIBSPECTRUM_CFLAGS="-I$md_build/libspectrum" LIBSPECTRUM_LIBS="-L$md_build/libspectrum/.libs -lspectrum"
    make clean
    make
    md_ret_require="$md_build/fuse"
}
