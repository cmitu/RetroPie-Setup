# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function sources_lr-armsnes() {

    gitPullOrClone "$md_build" https://github.com/RetroPie/ARMSNES-libretro
    applyPatch "$xscriptdir/override/${md_id}/01.fix-compiler.diff"

}
