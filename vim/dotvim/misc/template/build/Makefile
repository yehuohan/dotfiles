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
# target
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


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CMake targets
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BUILD_DIR := _VOut
BUILD_TYPE := Debug
#BUILD_TYPE := Release
#BUILD_GEN := "Unix Makefiles"
#BUILD_GEN := "NMake Makefiles"
BUILD_GEN := "Ninja"
BUILD_JOB := -j4
NDK_ROOT := ${Android_SDK}/ndk-bundle
NDK_ABI := arm64-v8a
NDK_PLATFORM := android-27


.PHONY: all
all: src src_android
	cmake --build ${BUILD_DIR} ${BUILD_JOB}
	cmake --install ${BUILD_DIR}

.PHONY: src
src:
	cmake -G ${BUILD_GEN} -Wno-dev \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
		-S . -B ${BUILD_DIR}

.PHONY: src_android
src_android:
	cmake -G ${BUILD_GEN} -Wno-dev \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
		-DANDROID_NDK=${NDK_ROOT} \
		-DANDROID_ABI=${NDK_ABI} \
		-DANDROID_PLATFORM=${NDK_PLATFORM} \
		-DANDROID_TOOLCHAIN=clang \
		-DANDROID_STL=c++_static \
		-DCMAKE_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/android.toolchain.cmake \
		-S . -B ${BUILD_DIR}

.PHONY: cc
cc: src
	cp ${BUILD_DIR}/compile_commands.json ./

.PHONY: clean
clean:
	-rm -r ${BUILD_DIR}

.PHONY: tags
tags:
	cmake -G ${BUILD_GEN} -Wno-dev \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_INSTALL_PREFIX=${BUILD_DIR} \
		-S . -B ${BUILD_DIR}
	cmake --build ${BUILD_DIR} ${BUILD_JOB} --target tags
	cmake --install ${BUILD_DIR}
