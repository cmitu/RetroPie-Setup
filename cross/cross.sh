#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

__version="0.1"

# Debugging the script
[[ "$__debug" -eq 1 ]] && set -x

# main retropie install location
rootdir="/opt/retropie"

user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"

home="$(eval echo ~$user)"
datadir="$home/RetroPie"
biosdir="$datadir/BIOS"
romdir="$datadir/roms"
emudir="$rootdir/emulators"
configdir="$rootdir/configs"

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" & cd .. && pwd)"

# Cross compile scripts and configurations are assumed to be in a sub-folder of the mail scriptdir
xscriptdir="$scriptdir/cross"

__logdir="$scriptdir/logs"
__tmpdir="$scriptdir/tmp"
__builddir="$__tmpdir/build"
__swapdir="$__tmpdir"


# TODO: we should be running as regular user, but we need root access to for dependency grabbing.
# check if sudo is used
#if [[ "$(id -u)" -ne 0 ]]; then
#    echo "Script must be run under sudo from the user you want to install for. Try 'sudo $0'"
#    exit 1
#fi


__backtitle="retropie.org.uk - RetroPie Cross-compilation helper. "

source "$scriptdir/scriptmodules/system.sh"
source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/inifuncs.sh"
source "$scriptdir/scriptmodules/packages.sh"

source "$xscriptdir/x-system.sh"
source "$xscriptdir/x-overrides.sh"

# Platform must be explicitely set when running this script.
if [[ -z "$cross" ]]; then
	fatalError "Please set the \$cross variable before running this script or just add \$cross=MYPLATFORM before running"
fi


x_setup_env $cross

# TODO: call the cross-platform functions to initialize the build environment
rp_registerAllModules
# x_rp_registerAllModules

rp_ret=0
if [[ $# -gt 0 ]]; then
    x_rp_callModule "$@"
    rp_ret=$?
else
    x_rp_printUsageinfo
fi

# Remove the CMake toolchain file, if one exists
# [[ -f "${__cross_cmake_toolchain_file}" ]] && rm -f "${__cross_cmake_toolchain_file}" 

printMsgs "console" "${__INFMSGS[@]}"
exit $rp_ret
