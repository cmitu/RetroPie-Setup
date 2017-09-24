# TODO: Add header
# 
# This file contains override for functions used by the Retropie build scripts.
# It's needed in case we need to call our own build process or apply patches before compilation.
# 

function sources_retroarch() {
    echo "Overriden"
    gitPullOrClone "$md_build" https://github.com/libretro/RetroArch.git v1.6.7
    applyPatch "$md_data/01_hotkey_hack.diff"
    applyPatch "$md_data/02_disable_search.diff"

    # Cross-compile fix: libs detection fixes for RPI, fixed by 97d98b87cefa07bf72c7a09b944ecab8182506e1
    applyPatch ${xscriptdir}/override/${md_id}/01.config.libs-fix.diff

}
