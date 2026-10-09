V_CC_0 = @echo "CC   $@";
V_CC_1 = 
V_CC_  = $(V_CC_0)
V_CC   = $(V_CC_$(V))

V_CXX_0 = @echo "CXX  $@";
V_CXX_1 = 
V_CXX_  = $(V_CXX_0)
V_CXX   = $(V_CXX_$(V))

V_ASM_0 = @echo "ASM  $@";
V_ASM_1 = 
V_ASM_  = $(V_ASM_0)
V_ASM   = $(V_ASM_$(V))

V_LINK_0 = @echo "LINK $@";
V_LINK_1 = 
V_LINK_  = $(V_LINK_0)
V_LINK   = $(V_LINK_$(V))

