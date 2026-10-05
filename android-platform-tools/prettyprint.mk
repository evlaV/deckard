V_CC_0 = @echo "CC     $@";
V_CC_1 = 
V_CC_  = $(V_CC_0)
V_CC   = $(V_CC_$(V))

V_AR_0 = @echo "AR     $@";
V_AR_1 = 
V_AR_  = $(V_AR_0)
V_AR   = $(V_AR_$(V))

V_CXX_0 = @echo "CXX    $@";
V_CXX_1 = 
V_CXX_  = $(V_CXX_0)
V_CXX   = $(V_CXX_$(V))

V_ASM_0 = @echo "ASM    $@";
V_ASM_1 = 
V_ASM_  = $(V_ASM_0)
V_ASM   = $(V_ASM_$(V))

V_GEN_0 = @echo "GEN   $@";
V_GEN_1 = 
V_GEN_  = $(V_GEN_0)
V_GEN   = $(V_GEN_$(V))

V_LINK_0 = @echo "LINK   $@";
V_LINK_1 = 
V_LINK_  = $(V_LINK_0)
V_LINK   = $(V_LINK_$(V))

V_PROTOC_0 = @echo "PROTOC $(@D) $(notdir $(wildcard $(INCROOT)/$(@D)/*.proto))";
V_PROTOC_1 = 
V_PROTOC_  = $(V_PROTOC_0)
V_PROTOC   = $(V_PROTOC_$(V))

define hrule =
$(info --------------------------------------------------------------------)
endef
