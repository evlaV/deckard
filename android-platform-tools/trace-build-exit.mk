NEW_CPP := $(filter-out $(OLD_OBJ_CPP),$(OBJ_CPP) $(EXTRA_OBJ_CPP))
NEW_CC  := $(filter-out $(OLD_OBJ_CC),$(OBJ_CC))
NEW_C   := $(filter-out $(OLD_OBJ_C),$(OBJ_C))
NEW_ASM := $(filter-out $(OLD_OBJ_ASM),$(OBJ_ASM))
NEW_BIN := $(filter-out $(OLD_BUILT),$(BUILT))

NEW_TOOL := $(filter-out $(OLD_TOOLS),$(TOOLS))
NEW_LIBS := $(filter-out $(OLD_LIBRARIES),$(LIBRARIES))
NEW_BINS := $(filter-out $(OLD_USR_BINS),$(USR_BINS))
NEW_INCS := $(filter-out $(OLD_INCLUDES),$(INCLUDES))

$(if $(NEW_CPP)$(NEW_CC)$(NEW_C)$(NEW_ASM),,\
  $(warning $(MKF) added no intermediate objects))
$(if $(NEW_BIN),,\
  $(warning $(MKF) added no shipped artefacts))
ifneq (,$(TRACE_BUILTSYSTEM))
$(info $(MKF):)
$(if $(NEW_CPP),$(info + .cpp objects $(NEW_CPP)))
$(if $(NEW_CC), $(info + .cc  objects $(NEW_CC)))  
$(if $(NEW_C),  $(info + .c   objects $(NEW_C)))   
$(if $(NEW_ASM),$(info + .S   objects $(NEW_ASM))) 
$(if $(NEW_BIN),$(info + artefacts $(NEW_BIN)))
endif
ifneq (,$(TRACE_INSTALLATION))
$(if $(NEW_TOOL)$(NEW_LIBS)$(NEW_BINS)$(NEW_INCS),,\
  $(warning $(MKF) added no installation items))
$(info $(MKF):)
$(if $(NEW_TOOL),$(info INST += $(NEW_TOOL)))
$(if $(NEW_LIBS),$(info LIBS += $(NEW_LIBS)))
$(if $(NEW_BINS),$(info BINS += $(NEW_BINS)))
$(if $(NEW_INCS),$(info INCS += $(NEW_INCS)))
endif

