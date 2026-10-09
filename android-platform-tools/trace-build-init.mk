MKF := $(notdir \
         $(lastword \
           $(filter-out $(lastword $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))
OLD_OBJ_CPP := $(OBJ_CPP)
OLD_OBJ_CC  := $(OBJ_CC)
OLD_OBJ_C   := $(OBJ_C)
OLD_OBJ_ASM := $(OBJ_ASM)
OLD_BUILT := $(BUILT)

OLD_TOOLS     := $(TOOLS)
OLD_LIBRARIES := $(LIBRARIES)
OLD_USR_BINS  := $(USR_BINS)
OLD_INCLUDES  := $(INCLUDES)
