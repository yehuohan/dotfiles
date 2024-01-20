#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# cmake targets
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DIR_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILD_TYPE ?= Debug
#BUILD_TYPE ?= RelWithDebInfo
#BUILD_TYPE ?= Release
#BUILD_GEN ?= "Unix Makefiles"
#BUILD_GEN ?= "NMake Makefiles"
BUILD_GEN ?= "Ninja"
BUILD_JOB ?= -j4
DIR_BUILD ?= ${DIR_ROOT}/_VOut/${BUILD_TYPE}
DIR_INSTALL ?= ${DIR_ROOT}/install/${BUILD_TYPE}

NDK_ROOT ?= ${Android_SDK}/ndk-bundle
NDK_ABI ?= arm64-v8a
NDK_PLATFORM ?= android-27
export ANDROID_NDK_HOME := ${NDK_ROOT}

VCPKG_ROOT ?= ${APPS_HOME}/vcpkg
VCPKG_TRIPLET ?= x64-mingw-mix # x64-windows-mix, arm64-android
VCPKG_XSCRIPT := 'clear;x-script,bash ${DIR_ROOT}/scripts/vcpkg_xscript.sh {url} {dst};x-block-origin'
# VCPKG_XSCRIPT := 'clear;x-script,cmd /k ${DIR_ROOT}/scripts/vcpkg_xscript.bat {url} {dst};x-block-origin'
DEPS ?= vulkan-headers volk
DEPS_DIR ?= ${DIR_ROOT}/deps


.PHONY: all
all: src src_android
	cmake --build ${DIR_BUILD} ${BUILD_JOB}
	# cmake --install ${DIR_BUILD} --component <comp>
	cmake --install ${DIR_BUILD}

.PHONY: src
src:
	cmake -G ${BUILD_GEN} -Wno-dev \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
		-DPROJECT_BUILD_DIR=${DIR_BUILD} \
		# With vcpkg:
		# -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake
		# -DVCPKG_TARGET_TRIPLET=${VCPKG_TRIPLET}
		# -DVCPKG_OVERLAY_TRIPLETS=${DIR_ROOT}/cmake
		# -DVCPKG_INSTALLED_DIR=${DEPS_DIR}
		# -DVCPKG_MANIFEST_INSTALL=OFF
		-S . -B ${DIR_BUILD}

# Release for android need to remove '-g' from android-legacy.toolchain.cmake
# See https://github.com/android/ndk/issues/243
# Or strip manually:
#   objcopy --only-keep-debug <target> <target.sym>
#   objcopy --strip-unneeded <target>
.PHONY: src-android
src-android:
	# ANDROID_NDK_HOME=${NDK_ROOT}
	cmake -G ${BUILD_GEN} -Wno-dev \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
		-DPROJECT_BUILD_DIR=${DIR_BUILD} \
		-DANDROID_NDK=${NDK_ROOT} \
		-DANDROID_ABI=${NDK_ABI} \
		-DANDROID_PLATFORM=${NDK_PLATFORM} \
		-DANDROID_TOOLCHAIN=clang \
		-DANDROID_STL=c++_static \
		# With vcpkg:
		# -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake
		# -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/android.toolchain.cmake
		# -DVCPKG_TARGET_TRIPLET=${VCPKG_TRIPLET}
		# -DVCPKG_OVERLAY_TRIPLETS=${DIR_ROOT}/cmake
		# -DVCPKG_INSTALLED_DIR=${DEPS_DIR}
		# -DVCPKG_MANIFEST_INSTALL=OFF
		-S . -B ${DIR_BUILD}

.PHONY: deps
deps:
	# ANDROID_NDK_HOME=${NDK_ROOT}
	vcpkg install ${DEPS} --recurse --no-binarycaching \
		--triplet=${VCPKG_TRIPLET} \
		--overlay-triplets=${DIR_ROOT}/cmake \
		--x-install-root=${DEPS_DIR} \
		--x-asset-sources=${VCPKG_XSCRIPT}

.PHONY: clean
clean:
	-rm -rf ${DIR_BUILD}
	-rm -rf ${DIR_INSTALL}

.PHONY: src
tags:
	cmake --build ${DIR_BUILD} ${BUILD_JOB} --target tags
	cmake --install ${DIR_BUILD}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# dirs
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DIR_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DIR_OUT := ./_VOut
DIR_OBJ := ${DIR_OUT}/obj
DIR_INC := ./inc
DIR_SRC := ./src

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# settings
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
define make_dir
	$(foreach str, \
		$(addprefix ${DIR_OBJ}/,${DIR_SRC}), \
		$(shell mkdir -p ${str}))
	$(shell mkdir -p ${DIR_OUT})
endef
$(call make_dir)

## get src files from dirs with suffixs: (#dirs, #suffixs)
get_src = $(filter $(addprefix %.,$(2)),$(wildcard $(addsuffix /*,$(1))))

## get suffix files in dir from files: (#dir, #suffix, #files)
get_suf = $(addprefix $(1)/,$(addsuffix .$(2),$(basename $(3))))

## create obj target: (#obj_dir, #src_files, #cxxflags)
define do_create_obj_target
$(1)/$(basename $(2)).o: $(2)
	$(CC) -c $$< $(3) -o $$@ -MD -MP -MT $$@ -MT $$*.d -MF $$*.d
endef
create_obj_target = $(foreach line,$(2),$(eval $(call do_create_obj_target,$(1),$(line),$(3))))

CC          := g++
CTAGS       := ctags
TARGET      := main
ifeq (${CC}, g++)
CC_SUF      := c cc cpp cxx
else
CC_SUF      := c cc
endif
BIN         := ${DIR_OUT}/${TARGET}
SRC         := $(call get_src,${DIR_SRC},${CC_SUF})
OBJ         := $(call get_suf,${DIR_OBJ},o,${SRC})
DEP         := $(call get_suf,${DIR_OBJ},d,${SRC})
LIBS        :=
#-lpthread \`pkg-config opencv --libs\`
PKGFLAGS    :=
#\`pkg-config opencv --cflags\`
CXXFLAGS    := -g -Wall
CXXFLAGS    += $(addprefix -I, $(DIR_INC))
CXXFLAGS    += ${PKGFLAGS}
LDFLAGS     := ${LIBS}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# targets
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
${BIN}: ${OBJ}
	${CC} $^ -o $@ ${CXXFLAGS} ${LDFLAGS}

$(call create_obj_target,${DIR_OBJ},${SRC},${CXXFLAGS})

-include ${DEP}

.PHONY: clean
clean:
	-rm -r ${DIR_OUT}

.PHONY: tags
tags:
	${CTAGS} -R ${DIR_INC} ${DIR_SRC}
