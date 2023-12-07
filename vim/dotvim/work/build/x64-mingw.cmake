# Mixed x64-mingw
# Usage: vcpkg install --triplet=x64-mingw --overlay-triplets=<directory/of/x64-mingw.cmake>

cmake_minimum_required(VERSION 3.5)

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_ENV_PASSTHROUGH PATH)
set(VCPKG_CMAKE_SYSTEM_NAME MinGW)

set(DEPS_DYNAMIC assimp)
if((PORT IN_LIST DEPS_DYNAMIC) OR (PORT MATCHES "^qt-.*"))
    # Dynamic
    set(VCPKG_LIBRARY_LINKAGE dynamic)
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
else()
    # Static
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

