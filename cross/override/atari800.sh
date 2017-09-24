# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function sources_atari800() {

    downloadAndExtract "$__archive_url/atari800-3.1.0.tar.gz" "$md_build" 1

    if isPlatform "rpi"; then
        applyPatch rpi_fixes.diff <<\_EOF_
--- a/src/configure.ac  2014-04-12 13:58:16.000000000 +0000
+++ b/src/configure.ac  2015-02-14 22:39:42.000000000 +0000
@@ -309,6 +310,7 @@
         AC_DEFINE(SUPPORTS_PLATFORM_CONFIGURE,1,[Additional config file options.])
         AC_DEFINE(SUPPORTS_PLATFORM_CONFIGSAVE,1,[Save additional config file options.])
         AC_DEFINE(SUPPORTS_PLATFORM_PALETTEUPDATE,1,[Update the Palette if it changed.])
+        AC_DEFINE(PLATFORM_MAP_PALETTE,1,[Platform-specific mapping of RGB palette to display surface.])
         A8_NEED_LIB(GLESv2)
         A8_NEED_LIB(EGL)
         A8_NEED_LIB(SDL)
_EOF_


    fi 

}

function build_atari800() {
    cd src
    autoreconf -v
    params=()
    isPlatform "rpi" && params+=(--target=rpi)
    ./configure --prefix="$md_inst" ${params[@]} --host=${__cros_arch}
    make clean
    make
    md_ret_require="$md_build/src/atari800"

}
