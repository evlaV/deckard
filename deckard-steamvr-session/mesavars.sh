# This file contains global switches we apply to essentially all processes
# to ensure that mesa/zink/turnip are trotting down the happy path

# Ensure we are using GL v4.3
MESA_GL_VERSION_OVERRIDE=4.3
MESA_GLSL_VERSION_OVERRIDE=430

# Ensure vulkan loader finds turnip
# NOTE: The x86_64 and i686 variants exist wtihin the fex rootfs, it shims them in.
# Further note: it's possible we may be able to drop the fex variants, as pressure vessel supposedly will do something to this variable.
#VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/freedreno_icd.x86_64.json:/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json:/usr/share/vulkan/icd.d/freedreno_icd.x86.json"

# Use zink
#MESA_LOADER_DRIVER_OVERRIDE=zink

# Tell vrcompositor to use these parameters
VRCOMPOSITOR_TU_DEBUG=sysmem,preempt
