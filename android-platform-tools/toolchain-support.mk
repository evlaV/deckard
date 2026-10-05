ifneq (, $(shell which clang))
  export CC = clang
  export CXX = clang++

  $(info Configuring for ($(CC) $(CXX)) build)

  OLDE_CFLAGS   := $(EXTRA_CFLAGS)
  OLDE_CXXFLAGS := $(EXTRA_CXXFLAGS)
  OLDE_CPPFLAGS := $(EXTRA_CPPFLAGS)

  EXTRA_CFLAGS += -gdwarf-4
  EXTRA_CXXFLAGS += -gdwarf-4
  EXTRA_CPPFLAGS += \
    -Wno-c99-designator \
    -Wno-gnu-designator \
    -Wno-gnu-folding-constant

  $(info - EXTRA_CFLAGS   += $(filter-out $(OLDE_CFLAGS),$(EXTRA_CFLAGS)))
  $(info - EXTRA_CXXFLAGS += $(filter-out $(OLDE_CXXFLAGS),$(EXTRA_CXXFLAGS)))
  $(info - EXTRA_CPPFLAGS += $(filter-out $(OLDE_CPPFLAGS),$(EXTRA_CPPFLAGS)))

  FIXED_CFLAGS   := $(filter-out -fstack-clash-protection,$(BASE_CFLAGS))
  ifneq ($(FIXED_CFLAGS),$(BASE_CFLAGS))
    $(info - Removed ($(filter-out $(FIXED_CFLAGS),$(BASE_CFLAGS))) from BASE_CFLAGS)
  endif

  FIXED_CXXFLAGS := $(filter-out -fstack-clash-protection,$(BASE_CXXFLAGS))
  ifneq ($(FIXED_CXXFLAGS),$(BASE_CXXFLAGS))
    $(info - Removed ($(filter-out $(FIXED_CXXFLAGS),$(BASE_CXXFLAGS))) from BASE_CXXFLAGS)
  endif

  BASE_CFLAGS    := $(FIXED_CFLAGS)
  BASE_CXXFLAGS  := $(FIXED_CXXFLAGS)
else
  $(info Using default configuration for ($(CC) $(CXX)) build)
endif

ifneq (, $(shell which lld))
  EXTRA_LDFLAGS += -fuse-ld=lld -Wl,--build-id=sha1
  $(info lld detected, adding -Wl,--build-id=sha1 to LDFLAGS)
endif
