-include ../trace-build-init.mk
############################################################################
# sources
LIBBT_SRC := \
  AndroidUnwinder.cpp \
  ArmExidx.cpp \
  DexFiles.cpp \
  DwarfCfa.cpp \
  DwarfEhFrameWithHdr.cpp \
  DwarfMemory.cpp \
  DwarfOp.cpp \
  DwarfSection.cpp \
  Elf.cpp \
  ElfInterface.cpp \
  ElfInterfaceArm.cpp \
  Global.cpp \
  JitDebug.cpp \
  MapInfo.cpp \
  Maps.cpp \
  Memory.cpp \
  MemoryMte.cpp \
  MemoryXz.cpp \
  Regs.cpp \
  RegsArm.cpp \
  RegsArm64.cpp \
  RegsX86.cpp \
  RegsX86_64.cpp \
  RegsRiscv64.cpp \
  RegsMips.cpp \
  RegsMips64.cpp \
  Symbols.cpp \
  ThreadEntry.cpp \
  ThreadUnwinder.cpp \
  Unwinder.cpp \
  LogStdout.cpp

LIBBT_SOURCES := $(patsubst %,system/unwinding/libunwindstack/%,$(LIBBT_SRC))

LIBBT_SOURCES_CPP := $(filter %.cpp,$(LIBBT_SOURCES))
LIBBT_OBJECTS_CPP := $(LIBBT_SOURCES_CPP:.cpp=.o)

LIBBT_SOURCES_ASM :=
ifeq ($(CARCH), x86_64)
  LIBBT_SOURCES_ASM += system/unwinding/libunwindstack/AsmGetRegsX86_64.S
else ifeq ($(CARCH), i386)
  LIBBT_SOURCES_ASM += system/unwinding/libunwindstack/AsmGetRegsX86.S
endif
LIBBT_OBJECTS_ASM := $(LIBBT_SOURCES_CC:.S=.o)

LIBBT_SO_MAJOR := 0

############################################################################
# flags
LIBBT_CXXFLAGS := -fno-omit-frame-pointer
LIBBT_CPPFLAGS := \
  -I$(INCROOT)/external/lzma/C \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/libprocinfo/include \
  -I$(INCROOT)/system/logging/liblog/include \
  -I$(INCROOT)/system/unwinding/libunwindstack/include

LIBBT_LDFLAGS := \
  -L/usr/lib/7zip \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -Wl,-rpath=/usr/lib/7zip \
  -Wl,-soname,libbacktrace.so.$(LIBBT_SO_MAJOR) \
  -lbase \
  -llog \
  -l:7z.so \
  -lpthread \
  -shared

############################################################################
# dependencies and build flags
o/system/libbacktrace.so: CFLAGS   := $(BASE_CFLAGS)   $(LIBBT_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libbacktrace.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LIBBT_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libbacktrace.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LIBBT_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libbacktrace.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LIBBT_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libbacktrace.so: SO_MAJOR := $(LIBBT_SO_MAJOR)
o/system/libbacktrace.so: | o/system/libbase.so o/system/liblog.so
o/system/libbacktrace.so: $(LIBBT_OBJECTS_CPP) $(LIBBT_OBJECTS_ASM)

OBJ_CPP += $(LIBBT_OBJECTS_CPP)
OBJ_ASM += $(LIBBT_OBJECTS_ASM)
BUILT   += o/system/libbacktrace.so

############################################################################
# clean
clean-libbacktrace.so:
	@rm -vf $(LIBBT_OBJECTS_CPP) $(LIBBT_OBJECTS_ASM)
	@rm -vf o/system/libbacktrace.so{,.$(LIBBT_SO_MAJOR)}

clean: clean-libbacktrace.so

############################################################################
# install
LIBRARIES += o/system/libbacktrace.so
LIBRARIES += o/system/libbacktrace.so.$(LIBBT_SO_MAJOR)

############################################################################
-include ../trace-build-exit.mk
