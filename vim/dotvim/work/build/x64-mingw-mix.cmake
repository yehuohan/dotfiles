# x64-mingw-mix
# Usage: vcpkg install --triplet=x64-mingw-mix --overlay-triplets=<directory/of/x64-mingw-mix.cmake>

cmake_minimum_required(VERSION 3.5)

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_CMAKE_SYSTEM_NAME MinGW)

# Make sure `vcpkg install` can access what from $PATH (like `bash` and `cmd` of VCPKG_XSCRIPT)
# Prefer 'UNTRACKED' that won't cause rebuilds on ENV change
# set(VCPKG_ENV_PASSTHROUGH PATH)
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED PATH)

set(DEPS_DYNAMIC assimp)
if((PORT IN_LIST DEPS_DYNAMIC) OR (PORT MATCHES "^qt-.*"))
    # Dynamic
    set(VCPKG_LIBRARY_LINKAGE dynamic)
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
else()
    # Static
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

