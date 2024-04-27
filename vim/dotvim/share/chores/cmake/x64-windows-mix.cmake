# x64-windows-mix
# Usage: vcpkg install --triplet=x64-windows-mix --overlay-triplets=<directory/of/x64-windows-mix.cmake>

cmake_minimum_required(VERSION 3.5)

set(VCPKG_TARGET_ARCHITECTURE x64)

# Make sure `vcpkg install` can access what from $PATH (like `bash` and `cmd` of VCPKG_XSCRIPT)
# Prefer 'UNTRACKED' that won't cause rebuild on ENV change
# set(VCPKG_ENV_PASSTHROUGH PATH)
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED PATH)
# Disable track compiler which will cause rebuild when compiler changed
# set(VCPKG_DISABLE_COMPILER_TRACKING ON)

set(DEPS_DYNAMIC assimp)
if((PORT IN_LIST DEPS_DYNAMIC) OR (PORT MATCHES "^qt-.*"))
    # Dynamic
    set(VCPKG_CRT_LINKAGE dynamic)
    set(VCPKG_LIBRARY_LINKAGE dynamic)
else()
    # Static
    set(VCPKG_CRT_LINKAGE static)
    set(VCPKG_LIBRARY_LINKAGE static)
endif()


