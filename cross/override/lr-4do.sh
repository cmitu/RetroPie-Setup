# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function sources_lr-4do() {
    gitPullOrClone "$md_build" https://github.com/libretro/4do-libretro.git
    echo "Applying patches"
    applyPatch "$xscriptdir/override/${md_id}/01-fix-compilers.diff"

}
