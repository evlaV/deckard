-include ../trace-build-init.mk
############################################################################
# sources
LCPUF_SOURCES := \
  external/cpu_features/src/filesystem.c \
  external/cpu_features/src/stack_line_reader.c \
  external/cpu_features/src/string_view.c \
  external/cpu_features/src/hwcaps.c

ifeq ($(CARCH), x86_64)
  LCPUF_SOURCES += external/cpu_features/src/impl_x86_linux_or_android.c
endif
ifeq ($(CARCH), aarch64)
  LCPUF_SOURCES += external/cpu_features/src/impl_aarch64_linux_or_android.c
endif

LCPUF_SOURCES_C := $(filter %.c,$(LCPUF_SOURCES))
LCPUF_OBJECTS_C := $(LCPUF_SOURCES_C:.c=.o)

LCPUF_SO_MAJOR  := 0

############################################################################
# flags
LCPUF_CPPFLAGS := \
  -DHAVE_DLFCN_H \
  -DHAVE_STRONG_GETAUXVAL \
  -DSTACK_LINE_READER_BUFFER_SIZE=1024 \
  -I$(INCROOT)/external/cpu_features/include \

LCPUF_LDFLAGS := \
  -Wl,-soname,libcpu_features.so.$(LCPUF_SO_MAJOR) \
  -shared

############################################################################
# dependencies and build flags
o/external/libcpu_features.so: CFLAGS   := $(BASE_CFLAGS)   $(LCPUF_CFLAGS)   $(EXTRA_CFLAGS)
o/external/libcpu_features.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LCPUF_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/external/libcpu_features.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LCPUF_LDFLAGS)  $(EXTRA_LDFLAGS)
o/external/libcpu_features.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LCPUF_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/external/libcpu_features.so: SO_MAJOR := $(LCPUF_SO_MAJOR)
o/external/libcpu_features.so: $(LCPUF_OBJECTS_C)

OBJ_C   += $(LCPUF_OBJECTS_C)
BUILT   += o/external/libcpu_features.so

############################################################################
# clean
clean-libcpu_features.so:
	@rm -vf $(LCPUF_OBJECTS_C)
	@rm -vf o/external/libcpu_features.so{,.$(LCPUF_SO_MAJOR)}

clean: clean-libcpu_features.so

############################################################################
# install
LIBRARIES += o/external/libcpu_features.so
LIBRARIES += o/external/libcpu_features.so.$(LCPUF_SO_MAJOR)

############################################################################
-include ../trace-build-exit.mk
