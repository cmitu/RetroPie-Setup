#!/usr/bin/env bash
# TODO: license

# Folder where the rootfs images are located
declare chroot_path="/srv/chroot"

# Default RPI platform is RPi 1
declare default_rpi="rpi1"


# Variables to be filled in by the platform initialization functions
# We'll need them in the build scripts and dependency installation
declare __cross_platform=""
declare __cross_rootfs=""
declare __cross_arch=""
declare __cross_cmake_toolchain_file=""

# TODO: document this
function x_platform_rpi {
    
    # Type of RPI system: rpi1, rpi2 or rpi3
    local platform=$1

    # If no arguments given, assume it's RPI1
    ! [[ -n "$platform" ]] && platform=$default_rpi

    # A chroot filesystem with the target environment
    local chroot_name="jessie-armhf-raspbian"
    local arch="arm-linux-gnueabihf"
    local sysroot="$chroot_path/$chroot_name"

    # Location of the cross-compile toolchain
    local toolchain="/home/pi/x-tools/raspbian-jessie"

    # Call the 'platform_...' function used by the normal compilation
    # this way we get the compile flags already and the platform flags and we don't duplicate code
    if fnExists "platform_${platform}"; then
        platform_${platform}
    fi

    # Cross compilation compiler settings
    __cross_cflags="${__default_cflags} --sysroot=$sysroot -I${sysroot}/opt/vc/include"

    # workaround for GCC ABI incompatibility with threaded armv7+ C++ apps built
    # on Raspbian's armv6 userland https://github.com/raspberrypi/firmware/issues/491
    __cross_cxxflags="${__cross_cflags} ${__default_cxxflags} -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 "
    __cross_ldflags="${__default_ldflags} --sysroot=${sysroot} -Wl,-rpath-link,${sysroot}/opt/vc/lib -Wl,-rpath-link,$sysroot/usr/lib/$arch -Wl,-rpath-link,${sysroot}/lib/${arch} -L${sysroot}/opt/vc/lib -L${sysroot}/usr/lib/${arch} -L${sysroot}/lib/${arch}"

    # Cross compilers declaration
    export CC=${toolchain}/bin/${arch}-gcc
    export CXX=${toolchain}/bin/${arch}-g++
    export LD=${toolchain}/bin/${arch}-ld
    export CPP=${toolchain}/bin/${arch}-cpp
    export AS=${toolchain}/bin/${arch}-as
    export AR=${toolchain}/bin/${arch}-ar
    export RANLIB=${toolchain}/bin/${arch}-ranlib
   
    # Some makefiles use CC_PREFIX to guess the toolchain path
    export CC_PREFIX="${toolchain}/bin/${arch}-" 

    # PKG Config variables
    export PKG_CONFIG_SYSROOT_DIR=${sysroot}
    export PKG_CONFIG_DIR=
    export PKG_CONFIG=${arch}-pkg-config # must exist on the host, installed with pkg-config
    export PKG_CONFIG_LIBDIR=${sysroot}/usr/lib/${arch}/pkgconfig:${sysroot}/usr/lib/pkgconfig:${sysroot}/usr/share/pkgconfig:${sysroot}/opt/vc/lib/pkgconfig

    # Prepend the path with the toolchain path. Some configure scripts expect the ${arch}-gcc, ${arch}-g++ to be available
    export PATH=${toolchain}/bin:$PATH
    
    # Set the CROSS_COMPILE variable, needed by configure based builds to recognize a cross compilation
    export CROSS_COMPILE=${arch}-

    # Some libretro makefiles expect the $platform to contain 'rpi'
    export platform="rpi"

    # CMake compilation needs a cross toolchain file (See https://cmake.org/Wiki/CMake_Cross_Compiling#The_toolchain_file)
    # We'll build one for this platform in a temporary file
    local cmake_toolchain_file="${__tmpdir}/${platform}-${arch}.cmake"

    echo "CMake toolchain file generated at $cmake_toolchain_file"
    cat <<- EOF > $cmake_toolchain_file 
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)
cmake_minimum_required(VERSION 3.7.0)

SET(MULTIARCH "${arch}")
SET(TOOLCHAIN_ROOT ${toolchain} )

SET(CMAKE_C_COMPILER \${TOOLCHAIN_ROOT}/bin/${arch}-gcc)
SET(CMAKE_LINKER \${TOOLCHAIN_ROOT}/bin/${arch}-ld)
SET(CMAKE_CXX_COMPILER \${TOOLCHAIN_ROOT}/bin/${arch}-g++)

SET(ROOTFS ${sysroot})
SET(CMAKE_SYSROOT "\${ROOTFS}")

INCLUDE_DIRECTORIES(SYSTEM
        "\${ROOTFS}/usr/include"
        "\${ROOTFS}/usr/include/${MULTIARCH}"
        "\${ROOTFS}/opt/vc/include"
)


SET(ENV{LDFLAGS} "-Wl,-rpath-link,\${ROOTFS}/lib/\${MULTIARCH} -Wl,-rpath-link,\${ROOTFS}/usr/lib/\${MULTIARCH} -Wl,-rpath-link,\${ROOTFS}/opt/vc/lib -L\${ROOTFS}/lib/\${MULTIARCH} -L\${ROOTFS}/usr/lib/\${MULTIARCH} -L\${ROOTFS}/opt/vc/lib")

# pkg-config 
SET(ENV{PKG_CONFIG_PATH} "")
SET(ENV{PKG_CONFIG_LIBDIR} "\${ROOTFS}/usr/lib/${arch}/pkgconfig:\${ROOTFS}/usr/lib/pkgconfig:\${ROOTFS}/usr/share/pkgconfig")
SET(ENV{PKG_CONFIG_SYSROOT_DIR} "\${ROOTFS}")

SET(CMAKE_CXX_FLAGS "${__default_cflags} ${__default_cxxflags} -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 " CACHE STRING "" FORCE)
SET(CMAKE_C_FLAGS "${__default_cflags}" CACHE STRING "" FORCE)

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF

    # Export the cross compile settings globally 
    export __cross_cmake_toolchain_file=${cmake_toolchain_file} 
    export __cross_arch=${arch}
    export __cross_rootfs=${sysroot}
    export __cross_platform=${platform}
    export __cross_chroot=${chroot_name}
    
}

# Platform 'rpi1' is an alias for 'rpi'
function x_platform_rpi1 {
    x_platform_rpi "rpi1"
}

# Platform 'rpi2' is just a 'rpi' with different compilation flags
function x_platform_rpi2 {
    x_platform_rpi "rpi2"
}

# Platform 'rpi3' is just a 'rpi' with different compilation flags
function x_platform_rpi3 {
    x_platform_rpi "rpi3"
}


### Odroid
function x_platform_odroid-xu {

    
    # A chroot filesystem with the target environment
    local chroot_name="xenial-armhf-odroid-xu4"
    local arch="arm-linux-gnueabihf"
    local sysroot="$chroot_path/$chroot_name"

    # Location of the cross-compile toolchain
    local toolchain="/home/pi/odroid/xu4/"

    # Call the 'platform_...' function used by the normal compilation
    # this way we get the compile flags already and the platform flags and we don't duplicate code
    if fnExists "platform_${platform}"; then
        platform_${platform}
    fi

    # Cross compilation compiler settings
    __cross_cflags="${__default_cflags} --sysroot=$sysroot -I${sysroot}/opt/vc/include"

    # workaround for GCC ABI incompatibility with threaded armv7+ C++ apps built
    # on Raspbian's armv6 userland https://github.com/raspberrypi/firmware/issues/491
    __cross_cxxflags="${__cross_cflags} ${__default_cxxflags} -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2"
    __cross_ldflags="${__default_ldflags} --sysroot=${sysroot} -Wl,-rpath-link,${sysroot}/opt/vc/lib -Wl,-rpath-link,$sysroot/usr/lib/$arch -Wl,-rpath-link,${sysroot}/lib/${arch} -L${sysroot}/opt/vc/lib -L${sysroot}/usr/lib/${arch} -L${sysroot}/lib/${arch}"

    # Cross compilers declaration
    export CC=${toolchain}/bin/${arch}-gcc
    export CXX=${toolchain}/bin/${arch}-g++
    export LD=${toolchain}/bin/${arch}-ld
    export CPP=${toolchain}/bin/${arch}-cpp
    export AS=${toolchain}/bin/${arch}-as
    export AR=${toolchain}/bin/${arch}-ar
    export RANLIB=${toolchain}/bin/${arch}-ranlib
   
    # Some makefiles use CC_PREFIX to guess the toolchain path
    export CC_PREFIX="${toolchain}/bin/${arch}-" 

    # PKG Config variables
    export PKG_CONFIG_SYSROOT_DIR=${sysroot}
    export PKG_CONFIG_DIR=
    export PKG_CONFIG=${arch}-pkg-config # must exist on the host, installed with pkg-config
    export PKG_CONFIG_LIBDIR=${sysroot}/usr/lib/${arch}/pkgconfig:${sysroot}/usr/lib/pkgconfig:${sysroot}/usr/share/pkgconfig:${sysroot}/opt/vc/lib/pkgconfig

    # Prepend the path with the toolchain path. Some configure scripts expect the ${arch}-gcc, ${arch}-g++ to be available
    export PATH=${toolchain}/bin:$PATH
    
    # Set the CROSS_COMPILE variable, needed by configure based builds to recognize a cross compilation
    export CROSS_COMPILE=${arch}-

    # Some libretro makefiles expect the $platform to contain 'rpi'
    export platform="odroid-xu4"

    # CMake compilation needs a cross toolchain file (See https://cmake.org/Wiki/CMake_Cross_Compiling#The_toolchain_file)
    # We'll build one for this platform in a temporary file
    local cmake_toolchain_file="${__tmpdir}/${platform}-${arch}.cmake"

    echo "CMake toolchain file generated at $cmake_toolchain_file"
    cat <<- EOF > $cmake_toolchain_file 
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)
cmake_minimum_required(VERSION 3.7.0)

SET(MULTIARCH "${arch}")
SET(TOOLCHAIN_ROOT ${toolchain} )

SET(CMAKE_C_COMPILER \${TOOLCHAIN_ROOT}/bin/${arch}-gcc)
SET(CMAKE_LINKER \${TOOLCHAIN_ROOT}/bin/${arch}-ld)
SET(CMAKE_CXX_COMPILER \${TOOLCHAIN_ROOT}/bin/${arch}-g++)

SET(ROOTFS ${sysroot})
SET(CMAKE_SYSROOT "\${ROOTFS}")

INCLUDE_DIRECTORIES(SYSTEM
        "\${ROOTFS}/usr/include"
        "\${ROOTFS}/usr/include/${MULTIARCH}"
        "\${ROOTFS}/opt/vc/include"
)


SET(ENV{LDFLAGS} "-Wl,-rpath-link,\${ROOTFS}/lib/\${MULTIARCH} -Wl,-rpath-link,\${ROOTFS}/usr/lib/\${MULTIARCH} -Wl,-rpath-link,\${ROOTFS}/opt/vc/lib -L\${ROOTFS}/lib/\${MULTIARCH} -L\${ROOTFS}/usr/lib/\${MULTIARCH} -L\${ROOTFS}/opt/vc/lib")

# pkg-config 
SET(ENV{PKG_CONFIG_PATH} "")
SET(ENV{PKG_CONFIG_LIBDIR} "\${ROOTFS}/usr/lib/${arch}/pkgconfig:\${ROOTFS}/usr/lib/pkgconfig:\${ROOTFS}/usr/share/pkgconfig")
SET(ENV{PKG_CONFIG_SYSROOT_DIR} "\${ROOTFS}")

SET(CMAKE_CXX_FLAGS "${__default_cflags} ${__default_cxxflags} -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 " CACHE STRING "" FORCE)
SET(CMAKE_C_FLAGS "${__default_cflags}" CACHE STRING "" FORCE)

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF

    # Export the cross compile settings globally 
    export __cross_cmake_toolchain_file=${cmake_toolchain_file} 
    export __cross_arch=${arch}
    export __cross_rootfs=${sysroot}
    export __cross_platform=${platform}
    export __cross_chroot=${chroot_name}
    
}

