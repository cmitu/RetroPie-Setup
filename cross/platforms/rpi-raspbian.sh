#!/usr/bin/env bash
# TODO: license


# Cross Compile environment for Raspbian Jessie on the Raspberry Pi

x_platform_id="rpi-raspbian-jessie"
x_platform_desc="Raspbian OS running on Raspberry PI (0/1/2/3)"
x_platform_arch="arm-linux-gnueabihf"
x_platform_release="jessie"
x_platform_flags="rpi rpi1 rpi2 rpi3"


# Compilation flags are determined by functions, which have 1 parameter:
#  the path of the root filesystem (sysroot) of such a system. 

# Returns the C flags
function rpi-raspbian-jessie_cflags {
	local sysroot=$1
	
	return "-sysroot=$sysroot -I$sysroot/usr/include/$arch -I$sysroot/opt/vc/include"
}

# Returns the C++ compilation flags
function rpi-raspbian-jessie_cxxflags {
	local sysroot=$1
	
	return "-sysroot=$sysroot -I$sysroot/usr/include/$arch -I$sysroot/opt/vc/include"
}

# Returns the linker (LD) flags
function rpi-raspbian-jessie_ldflags {

	local sysroot=$1

	return "--sysroot="$sysroot" -Wl,--rpath-link,$sysroot/opt/vc/lib -Wl,--rpath-link,$sysroot/usr/lib/$x_platform_arch"
}

# Builds a CMake cross-compile toolchain file and returns the name of the file
# TODO: add parameter to output
function rpi-raspbian-jessie_cmakeFile {

    local output_dir=$1
    local arch=$2
    local toolchain_dir=$3

    local cmake_file=$(mktemp t -d -p ${output_dir})

    # TODO: check output folders
    echo 'CMAKE_VERSION(1)' >> "${cmake_file}" 
}
