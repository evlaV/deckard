-include ../prettyprint.mk

PLATFORM_TOOLS_VERSION := $(VERSION)
INCROOT := $(if $(VPATH),$(firstword $(subst :, ,$(VPATH))),.)
BUILT   :=

BASE_LDFLAGS  := $(LDFLAGS)
BASE_CFLAGS   := $(CFLAGS)
BASE_CPPFLAGS := $(CPPFLAGS)
BASE_CXXFLAGS := $(CXXFLAGS)

EXTRA_CFLAGS = -fPIC -std=gnu17
EXTRA_CXXFLAGS = -fPIC -std=gnu++2a
EXTRA_LDFLAGS = -fPIC
EXTRA_CPPFLAGS = \
  -DNDEBUG -UDEBUG \
  -fmessage-length=0 \
  -fno-exceptions \
  -fno-strict-aliasing \
  -no-canonical-prefixes

$(hrule)
-include ../toolchain-support.mk

ifeq (,$(CARCH))
  CARCH := $(shell uname -m)
endif

############################################################################
# what to install
TOOLS     :=
LIBRARIES :=
USR_BINS  :=
INCLUDES  :=
# special cases. Use "::" to divide source from destination
MISC_INST :=

############################################################################
$(hrule)
include ../adb.mk
include ../adbd.mk
include ../append2simg.mk
include ../etc1tool.mk
include ../fastboot.mk
include ../hprof-conv.mk
include ../img2simg.mk
include ../libETC1.mk
include ../libadb.mk
include ../libbacktrace.mk
include ../libbase.mk
include ../libcpu_features.mk
include ../libcrypto_utils.mk
include ../libcutils.mk
include ../libext4_utils.mk
include ../liblog.mk
include ../libsparse.mk
include ../libutils.mk
include ../libziparchive.mk
include ../simg2img.mk
include ../simg2simg.mk
include ../libnativehelper.mk

# strip any duplicates
OBJ_CPP := $(sort $(OBJ_CPP))
OBJ_CC  := $(sort $(OBJ_CC))
OBJ_C   := $(sort $(OBJ_C))

all: $(BUILT)
	@echo $$(date +'%Y-%m-%d %H:%M:%S %z'): Build complete

include ../check.mk
include ../install.mk
############################################################################
debug-build:
	$(info CC  is $(CC) ($(shell which $(CC))))
	$(info CXX is $(CXX) ($(shell which $(CXX))))
	$(info Architecture for DT_RPATH et al is '$(CARCH)' set from $(origin CARCH))
	$(hrule)
	$(info Any target-specific flags are added between BASE and EXTRA)
	$(info BASE_CPPFLAGS  $(BASE_CPPFLAGS))
	$(info BASE_CFLAGS    $(BASE_CFLAGS))
	$(info BASE_CXXFLAGS  $(BASE_CXXFLAGS))
	$(info BASE_LDFLAGS   $(BASE_LDFLAGS))
	$(hrule)
	$(info EXTRA_CPPFLAGS $(EXTRA_CPPFLAGS))
	$(info EXTRA_CFLAGS   $(EXTRA_CFLAGS))
	$(info EXTRA_CXXFLAGS $(EXTRA_CXXFLAGS))
	$(info EXTRA_LDFLAGS  $(EXTRA_LDFLAGS))
	$(hrule)
	$(info Building in $(realpath .))
ifneq (,$(VPATH))
	$(info External source in $(VPATH))
endif
############################################################################
# link or otherwise construct shipped objects:
o/%:
	@mkdir -p $(@D)
	$(V_LINK)EXT=$(SO_MAJOR);$(CXX) -o $@$${EXT:+.}$${EXT} \
	    $(filter %.o %.a,$^) $(LDFLAGS)
	@if [ -n "$(SO_MAJOR)" ]; then ln -sf $(@F).$(SO_MAJOR) $@; fi

o/%.a:
	@mkdir -p $(@D)
	$(V_AR)ar -rcs $@ $(filter %.o %.a,$^)
############################################################################
# generate protobuf files
define protogen =
@mkdir -p $(@D)
$(V_PROTOC)find $(INCROOT)/$(@D) -name '*.proto' -exec protoc -I$(INCROOT)/$(@D) --cpp_out=$(@D) {} \;
endef

packages/modules/adb/fastdeploy/proto/%:
	$(protogen)

packages/modules/adb/proto/%:
	$(protogen)

############################################################################
# intermediate object rules (except adbd: handled in its own makefile)
$(OBJ_CPP): %.o: %.cpp
	@mkdir -p $(@D)
	$(V_CXX)$(CXX) -c -o $@ $< $(CXXFLAGS) $(CPPFLAGS)

$(OBJ_CC): %.o: %.cc
	@mkdir -p $(@D)
	$(V_CXX)$(CXX) -c -o $@ $< $(CXXFLAGS) $(CPPFLAGS)

$(OBJ_C): %.o: %.c
	@mkdir -p $(@D)
	$(V_CC)$(CC) -c -o $@ $< $(CFLAGS) $(CPPFLAGS)

$(OBJ_ASM): %.o: %.S
	@mkdir -p $(@D)
	$(V_ASM)$(CC) -c -o $@ $< $(CFLAGS) $(CPPFLAGS) -D__ASSEMBLY__
