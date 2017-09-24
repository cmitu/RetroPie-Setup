#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#


# Lowecase the platform  
platform=$(echo $platform | tr [A-Z] [a-z])

# Import the cross compilation platforms
source "$xscriptdir/x-platform.sh"

# @fn Function to initialize the cross compile environment
function x_setup_env() {

    __ERRMSGS=()
    __INFMSGS=()
    
    local platform=$1

    # if no apt-get we need to fail
    [[ -z "$(which apt-get)" ]] && fatalError "Unsupported OS - No apt-get command found"

    __memory_phys=$(free -m | awk '/^Mem:/{print $2}')
    __memory_total=$(free -m -t | awk '/^Total:/{print $2}')

    __binary_host="files.retropie.org.uk"
    __binary_url="https://$__binary_host/binaries/$__os_codename/$__platform"

    __archive_url="https://files.retropie.org.uk/archives"

    # Check the platform given and if we're supporting it.
    if fnExists "x_platform_${platform}"; then
        echo "Platform $platform supported"
        x_platform_${platform}

    else 
        fatalError "Unknown platform - please manually set the platform variable to one of the following: $(compgen -A function x_platform_ | cut -f3 -d_ | paste -s -d' ')"

    fi
    
    # Set the __platform var, it's used by the RP functions to filter the available modules
    __platform=${platform}

    # -pipe is faster but will use more memory - so let's only add it if we have more thans 256M free ram.
    [[ $__memory_phys -ge 512 ]] && __default_cflags+=" -pipe"

    # Make flags - just parallel make flags
    export MAKEFLAGS="-j$(grep -c '^processor' /proc/cpuinfo)"

    # Show compilation flags
    export CFLAGS+=${__cross_cflags}
    export CXXFLAGS+=${__cross_cxxflags}
    export LDFLAGS+=${__cross_ldflags}

    [[ -z "${ASFLAGS}" ]] && export ASFLAGS="${__default_asflags}"
    [[ -z "${MAKEFLAGS}" ]] && export MAKEFLAGS="${__default_makeflags}${__cross_makeflags}"

    echo "CFLAGS: " $CFLAGS
    echo "CXXFLAGS: $CXXFLAGS"
    echo "LDFLAGS:  $LDFLAGS"
    echo "PKG_CONFIG_LIBDIR: $PKG_CONFIG_LIBDIR"
    echo "MAKEFLAGS: $MAKEFLAGS"
    echo "Platform flags: $__platform_flags"

}

# TODO: add documentation
function x_rp_printUsageinfo {

    echo
    echo -e "Usage:\n$0 <Index # or ID>\nThis will run the actions depends, sources and build automatically.\n"
    echo -e "Alternatively, $0 can be called as\n$0 <Index # or ID [depends|sources|build|clean]\n"
    echo    "Definitions:"
    echo    "depends:    install the dependencies for the module"
    echo    "sources:    install the sources for the module"
    echo    "build:      build/compile the module"
    echo    "clean:      remove the sources/build folder for the module"
    echo    "help:       get additional help on the module"
    echo -e "\nThis is a list of valid modules/packages and supported commands:\n"

    rp_listFunctions
}

# TODO: document this
# It's basically rp_callModule, but with just a subset of commands and executing extra commands
function x_rp_callModule {

    local req_id="$1"
    local mode="$2"
    # shift the function parameters left so $@ will contain any additional parameters which we can use in modules
    shift 2
    
	# if index get mod_id from array else we look it up
    local md_id
    local md_idx
    if [[ "$req_id" =~ ^[0-9]+$ ]]; then
        md_id="$(rp_getIdFromIdx $req_id)"
        md_idx="$req_id"
    else
        md_idx="$(rp_getIdxFromId $req_id)"
        md_id="$req_id"
    fi
    if [[ -z "$md_id" || -z "$md_idx" ]]; then
        printMsgs "console" "No module '$req_id' found for platform $__platform"
        return 2
    fi

    # CROSS Compile modification: source any specific overrides for the module's functions
    # It allows us to patch the build scripts for cross compilation.
 	if [[ -f "${xscriptdir}/override/${md_id}.sh" ]]; then
		source "${xscriptdir}/override/${md_id}.sh"
		echo "Using override file ${xscriptdir}/override/${md_id}.sh for additional definitions"
	fi

   
	# TODO: handle blacklisted modules and the $mode. We should exclude any install/uninstall $mode since we're running on a Host computer

	# Automatically run depends/sources/build module if no parameters are given
    if [[ -z "$mode" ]]; then
        for mode in depends sources build; do
            x_rp_callModule "$md_idx" "$mode" || return 1
        done
        return 0
    fi 

	# Call the RetroPie module functions
	rp_callModule "$md_idx" "$mode"

}
# Taken from https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
# Trim any leading and trailing spaces
function trim {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
   
    return $var 
}

