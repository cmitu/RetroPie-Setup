# TODO: Add header
#
# This file contains redefinitions for functions in the Retropie setup script.
# We need to redefine some core functions that assume the build host is the build target

## @fn getDepends()
## @param packages package / space separated list of packages to install
## @brief Installs packages in a RootFS (chroot) using sbuild-shell if they are not installed.
## @retval 0 on success
## @retval 1 on failure
function getDepends {

    local package_list="$@"

    # List of packages that we should exclude from installing in the host system
    local excluded_packages=("automake cmake libtool scons build-essential mercurial svn git autotool flex bison pkg-config ")

    # exclude build tools from installation into the target chroot
    for e in $excluded_packages; do
        package_list=${package_list/"$e"/}
    done
    

    ! [[ -n "$__cross_chroot" ]] && { echo "ERROR: RootFS not found for $__cross_arch !" && exit 1; }

    echo "Installing $package_list in $__cross_chroot"
    echo "apt-get -y install --no-install-recommends ${package_list}" | sudo sbuild-shell $__cross_chroot
    
}

# Overriden because we're not setting up/installing anything on the host system
# Since we're trying to run the builds scripts as a regular user, we cannot change permissions for files /opt/retropie
function mkUserDir {
    true
}

# Overriden  - we don't set up any udev rules on the host system
function addUdevInputRules {
    true
}
