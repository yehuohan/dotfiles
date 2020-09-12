#===============================================================================
# dir
#===============================================================================
DIR_INC := ./inc
DIR_SRC := ./src
DIR_OBJ := ./obj
DIR_BIN := .

#===============================================================================
# settings
#===============================================================================
define make_dir
	$(foreach str, \
		$(addprefix ${DIR_OBJ}/,${DIR_SRC}), \
		$(shell mkdir -p ${str}))
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

CC         := g++
CTAGS      := ctags
TARGET     := main
ifeq (${CC}, g++)
CC_SUF     := c cc cpp cxx
else
CC_SUF     := c cc
endif
BIN        := ${DIR_BIN}/${TARGET}
SRC        := $(call get_src,${DIR_SRC},${CC_SUF})
OBJ        := $(call get_suf,${DIR_OBJ},o,${SRC})
DEP        := $(call get_suf,${DIR_OBJ},d,${SRC})
LIBS       :=
#-lpthread \`pkg-config opencv --libs\`
PKGFLAGS   :=
#\`pkg-config opencv --cflags\`
CXXFLAGS   := -g -Wall
CXXFLAGS   += $(addprefix -I, $(DIR_INC))
CXXFLAGS   += ${PKGFLAGS}
LDFLAGS    := ${LIBS}

#===============================================================================
# target
#===============================================================================
${BIN}: ${OBJ}
	${CC} $^ -o $@ ${CXXFLAGS} ${LDFLAGS}

$(call create_obj_target,${DIR_OBJ},${SRC},${CXXFLAGS})

-include ${DEP}

tags:
	${CTAGS} -R ${SRC} ${DIR_INC}

.PHONY: clean
clean:
	-rm -r ${DIR_OBJ}
	-rm ${BIN}
