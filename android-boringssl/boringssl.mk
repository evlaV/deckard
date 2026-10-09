include ../sources.mk
include ../prettyprint.mk

############################################################################
# global
INCROOT := $(if $(VPATH),$(firstword $(subst :, ,$(VPATH))),.)
CC_ASSEMBLY = $(CC)

BASE_LDFLAGS  := $(LDFLAGS)
BASE_CFLAGS   := $(CFLAGS)
BASE_CPPFLAGS := $(CPPFLAGS)
BASE_CXXFLAGS := $(CXXFLAGS)

EXTRA_CFLAGS   += -fPIC -std=gnu17
EXTRA_CXXFLAGS += -fPIC -std=gnu++2a
EXTRA_LDFLAGS  += -fPIC
EXTRA_CPPFLAGS += \
  -DNDEBUG -UDEBUG \
  -DBORINGSSL_ANDROID_SYSTEM \
  -DBORINGSSL_IMPLEMENTATION \
  -DBORINGSSL_SHARED_LIBRARY \
  -DOPENSSL_SMALL \
  -fmessage-length=0 \
  -fno-exceptions \
  -fno-strict-aliasing \
  -no-canonical-prefixes

ifeq (,$(PKGNAME))
  PKGNAME = android-boringssl
endif

# Set up the build for clang, if it's available:
ifneq (, $(shell which clang))
  export CC = clang
  export CXX = clang++
  export EXTRA_CFLAGS += -gdwarf-4
  export EXTRA_CXXFLAGS += -gdwarf-4
  # clang complains about this flag:
  FIXED_CFLAGS   := $(filter-out -fstack-clash-protection,$(BASE_CFLAGS))
  FIXED_CXXFLAGS := $(filter-out -fstack-clash-protection,$(BASE_CXXFLAGS))
  BASE_CFLAGS    := $(FIXED_CFLAGS)
  BASE_CXXFLAGS  := $(FIXED_CXXFLAGS)
endif

# Use lld with SHA1 build hashes, if we have it:
ifneq (, $(shell which lld))
  export EXTRA_LDFLAGS += -fuse-ld=lld -Wl,--build-id=sha1
endif

# These assign objects to the correct generic build rule
C_OBJ   =
CC_OBJ  =
ASM_OBJ =

LIBRARIES := out/libcrypto.so out/libssl.so

all: $(LIBRARIES) out/test/bssl-tool

check: out/test/bssl-tool out/test/crypto_test out/test/ssl_test
	LD_LIBRARY_PATH=./out out/test/bssl-tool genrsa
	LD_LIBRARY_PATH=./out out/test/crypto_test
	LD_LIBRARY_PATH=./out out/test/ssl_test

install: install-lib install-bin install-doc install-inc

############################################################################
# installation details
CARCH_D := $(DESTDIR)/usr/lib/$(CARCH)/android
install-lib: $(LIBRARIES)
	install -D -t $(CARCH_D) $(patsubst %,%.0,$^)
	@for x in $^; do x=$$(basename $$x); ln -svf $$x.0 $(CARCH_D)/$$x; done

install-inc:
	install -d $(DESTDIR)/usr/include/android
	cp -av $(INCROOT)/src/include/openssl $(DESTDIR)/usr/include/android

install-bin: out/test/bssl-tool
	install -D -t $(DESTDIR)/usr/bin $^

install-doc: NOTICE src/INCORPORATING.md src/README.md
	install -m 0644 -D -t $(DESTDIR)/usr/share/doc/$(PKGNAME) $^
############################################################################
# This links the shipped libraries after their objects have been built:
out/lib%.so: | out/test/compiler_test
	@mkdir -p $(@D)
	$(COMPILER) $^ -o $@.0 -Wl,-soname,$(@F).0 $(LDFLAGS) $(EXTRA_LDFLAGS)
	@ln -sf $(@F).0 $@

debug-flags:
	@echo "CFLAGS   = $(BASE_CFLAGS)"   >  $@
	@echo "CPPFLAGS = $(BASE_CPPFLAGS)" >> $@
	@echo "LDFLAGS  = $(BASE_LDFLAGS)"  >> $@
	@echo "CXXFLAGS = $(BASE_CXXFLAGS)" >> $@

############################################################################
# libcrypto
CRYPTO_SOURCES   := $(crypto_sources) $(linux_$(CARCH)_sources)
CRYPTO_SOURCES_C := $(filter %.c,$(CRYPTO_SOURCES))
CRYPTO_OBJECTS_C := $(CRYPTO_SOURCES_C:.c=.o)
CRYPTO_SOURCES_ASSEMBLY := $(filter %.S,$(CRYPTO_SOURCES))
CRYPTO_OBJECTS_ASSEMBLY := $(CRYPTO_SOURCES_ASSEMBLY:.S=.o)

# noexecstack: fixes `shlib-with-executable-stack`,
# see: `src/util/BUILD.toplevel`
CRYPTO_CFLAGS   := -fvisibility=hidden -Wa,--noexecstack
CRYPTO_CPPFLAGS := -I$(INCROOT)/src/crypto -I$(INCROOT)/src/include
CRYPTO_LDFLAGS  := \
  -lpthread \
  -shared \
  -Wl,-z,notext

CRYPTO_C_OBJ := $(filter-out $(C_OBJ),$(CRYPTO_OBJECTS_C))
C_OBJ   += $(CRYPTO_C_OBJ)
ASM_OBJ += $(CRYPTO_OBJECTS_ASSEMBLY)

out/libcrypto.so: CFLAGS   := $(BASE_CFLAGS) $(CRYPTO_CFLAGS) $(EXTRA_CFLAGS)
out/libcrypto.so: CPPFLAGS := $(BASE_CPPFLAGS) $(CRYPTO_CPPFLAGS) $(EXTRA_CPPFLAGS)
out/libcrypto.so: LDFLAGS  := $(BASE_LDFLAGS) $(CRYPTO_LDFLAGS) $(EXTRA_LDFLAGS)
out/libcrypto.so: COMPILER  = $(V_LINK)$(CC)
out/libcrypto.so: $(CRYPTO_OBJECTS_C) $(CRYPTO_OBJECTS_ASSEMBLY)

############################################################################
# libssl
SSL_SOURCES  := $(ssl_sources)
SSL_OBJECTS  := $(SSL_SOURCES:.cc=.o)
SSL_CXXFLAGS := -fvisibility=hidden
SSL_CPPFLAGS := -I$(INCROOT)/src/include
SSL_LDFLAGS  := \
  -L ./out/ \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lcrypto \
  -shared

SSL_CC_OBJ := $(filter-out $(CC_OBJ),$(SSL_OBJECTS))
CC_OBJ += $(SSL_CC_OBJ)

out/libssl.so: CXXFLAGS := $(BASE_CXXFLAGS) $(SSL_CXXFLAGS) $(EXTRA_CXXFLAGS)
out/libssl.so: CPPFLAGS := $(BASE_CPPFLAGS) $(SSL_CPPFLAGS) $(EXTRA_CPPFLAGS)
out/libssl.so: LDFLAGS  := $(BASE_LDFLAGS)  $(SSL_LDFLAGS)  $(EXTRA_LDFLAGS)
out/libssl.so: COMPILER  = $(V_LINK)$(CXX)
out/libssl.so: $(SSL_OBJECTS) out/libcrypto.so

############################################################################
# compiler test (to be run _before_ building anything else)
CCTEST_SOURCES := \
  err_data.c \
  src/crypto/compiler_test.cc \
  src/crypto/err/err.c \
  src/crypto/mem.c \
  src/crypto/test/test_util.cc \
  src/crypto/thread_pthread.c

CCTEST_SOURCES_C  := $(filter %.c,$(CCTEST_SOURCES))
CCTEST_OBJECTS_C  := $(foreach x,$(CCTEST_SOURCES_C:.c=.o),test/$x)
CCTEST_SOURCES_CC := $(filter %.cc,$(CCTEST_SOURCES))
CCTEST_OBJECTS_CC := $(foreach x,$(CCTEST_SOURCES_CC:.cc=.o),test/$x)

CCTEST_CPPFLAGS = -I$(INCROOT)/src/include
CCTEST_LDFLAGS  = -lgtest -pie -Wl,-z,notext

out/test/compiler_test: CPPFLAGS := $(BASE_CPPFLAGS) $(CCTEST_CPPFLAGS) $(EXTRA_CPPFLAGS)
out/test/compiler_test: LDFLAGS  := $(BASE_LDFLAGS)  $(CCTEST_LDFLAGS)  $(EXTRA_LDFLAGS)
out/test/compiler_test: CFLAGS   := $(BASE_CFLAGS)   $(CCTEST_CFLAGS)   $(EXTRA_CFLAGS)
out/test/compiler_test: CXXFLAGS := $(BASE_CXXFLAGS) $(EXTRA_CXXFLAGS)
out/test/compiler_test: /usr/lib/libgtest_main.so
out/test/compiler_test: $(CCTEST_OBJECTS_C) $(CCTEST_OBJECTS_CC)
	@mkdir -p $(@D)
	$(V_LINK)$(CXX) $^ -o $@ $(LDFLAGS)
	$@

# We could use the standard recipes at the end for these
# but they need to be pushed into their own separate directory
# as they're the same objects as for the shipped binaries
# but built with different flags, and we don't want to mix
# them in with the others:
$(CCTEST_OBJECTS_C): test/%.o: %.c
	@mkdir -p $(@D)
	$(V_CC)$(CC) -c -o $@ $< $(CFLAGS) $(CPPFLAGS)

$(CCTEST_OBJECTS_CC): test/%.o: %.cc
	@mkdir -p $(@D)
	$(V_CXX)$(CXX) -c -o $@ $< $(CXXFLAGS) $(CPPFLAGS)
############################################################################
# test binaries
out/test/%:
	@mkdir -p $(@D)
	$(V_LINK)$(CXX) $^ -o $@ $(LDFLAGS)

#===========================================================================
# libtest_support
LTS_SOURCES  :=  $(test_support_sources)
LTS_OBJECTS  :=  $(LTS_SOURCES:.cc=.o)
LTS_CPPFLAGS := -I$(INCROOT)/src/include
LTS_LDFLAGS  := -shared

LTS_CC_OBJ := $(filter-out $(CC_OBJ),$(LTS_OBJECTS))
CC_OBJ     += $(LTS_CC_OBJ)

out/libtest_support.so: CXXFLAGS := $(BASE_CXXFLAGS) $(EXTRA_CXXFLAGS)
out/libtest_support.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LTS_CPPFLAGS) $(EXTRA_CPPFLAGS)
out/libtest_support.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LTS_LDFLAGS)  $(EXTRA_LDFLAGS)
out/libtest_support.so: COMPILER  = $(V_LINK)$(CXX)
out/libtest_support.so: $(LTS_OBJECTS)
#===========================================================================
# crypto test
CRTEST_SOURCES  := $(crypto_test_sources)
CRTEST_OBJECTS  := $(CRTEST_SOURCES:.cc=.o)
CRTEST_CPPFLAGS := -I$(INCROOT)/src/include
CRTEST_LDFLAGS  := \
  -L ./out/ \
  -lcrypto \
  -lgtest \
  -lpthread \
  -lssl \
  -ltest_support \
  -pie \
  -Wl,-z,notext

CRTEST_CC_OBJ := $(filter-out $(CC_OBJ),$(CRTEST_OBJECTS))
CC_OBJ += $(CRTEST_CC_OBJ)

out/test/crypto_test: CPPFLAGS := $(BASE_CPPFLAGS) $(CRTEST_CPPFLAGS) $(EXTRA_CPPFLAGS)
out/test/crypto_test: LDFLAGS  := $(BASE_LDFLAGS)  $(CRTEST_LDFLAGS)  $(EXTRA_LDFLAGS)
out/test/crypto_test: CXXFLAGS := $(BASE_CXXFLAGS) $(EXTRA_CXXFLAGS)
out/test/crypto_test: out/libtest_support.so out/libcrypto.so out/libssl.so
out/test/crypto_test: $(CRTEST_OBJECTS)
#===========================================================================
# bssl-tool
BSSL_SOURCES  := $(tool_sources)
BSSL_OBJECTS  := $(BSSL_SOURCES:.cc=.o)
BSSL_CPPFLAGS := -I$(INCROOT)/src/include
BSSL_LDFLAGS  := \
  -L ./out/ \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lcrypto \
  -lssl \
  -pie

BSSL_CC_OBJ := $(filter-out $(CC_OBJ),$(BSSL_OBJECTS))
CC_OBJ += $(BSSL_CC_OBJ)

out/test/bssl-tool: CPPFLAGS := $(BASE_CPPFLAGS) $(BSSL_CPPFLAGS) $(EXTRA_CPPFLAGS)
out/test/bssl-tool: LDFLAGS  := $(BASE_LDFLAGS)  $(BSSL_LDFLAGS)  $(EXTRA_LDFLAGS)
out/test/bssl-tool: CXXFLAGS := $(BASE_CXXFLAGS) $(EXTRA_CXXFLAGS)
out/test/bssl-tool: out/libcrypto.so out/libssl.so
out/test/bssl-tool: $(BSSL_OBJECTS)
#===========================================================================
# ssl_test
STEST_SOURCES    := $(ssl_test_sources)
STEST_SOURCES_C  := $(filter %.c,$(STEST_SOURCES))
STEST_OBJECTS_C  := $(STEST_SOURCES_C:.c=.o)
STEST_SOURCES_CC := $(filter %.cc,$(STEST_SOURCES))
STEST_OBJECTS_CC := $(STEST_SOURCES_CC:.cc=.o)

STEST_CPPFLAGS = -I$(INCROOT)/src/include
STEST_LDFLAGS  = $(CRTEST_LDFLAGS)

STEST_C_OBJ  := $(filter-out $(C_OBJ),$(STEST_OBJECTS_C))
STEST_CC_OBJ := $(filter-out $(CC_OBJ),$(STEST_OBJECTS_CC))
C_OBJ  += $(STEST_C_OBJ)
CC_OBJ += $(STEST_CC_OBJ)

out/test/ssl_test: CPPFLAGS := $(BASE_CPPFLAGS) $(STEST_CPPFLAGS) $(EXTRA_CPPFLAGS)
out/test/ssl_test: LDFLAGS  := $(BASE_LDFLAGS)  $(STEST_LDFLAGS)  $(EXTRA_LDFLAGS)
out/test/ssl_test: CXXFLAGS := $(BASE_CXXFLAGS) $(EXTRA_CXXFLAGS)
out/test/ssl_test: CFLAGS   := $(BASE_CXXFLAGS) $(EXTRA_CFLAGS)
out/test/ssl_test: out/libtest_support.so out/libcrypto.so out/libssl.so
out/test/ssl_test: $(STEST_OBJECTS_C) $(STEST_OBJECTS_CC)

############################################################################
# intermediate object recipes:
$(C_OBJ): %.o: %.c
	@mkdir -p $(@D)
	$(V_CC)$(CC) -c -o $@ $< $(CFLAGS) $(CPPFLAGS)

$(ASM_OBJ): %.o: %.S
	@mkdir -p $(@D)
	$(V_ASM)$(CC_ASSEMBLY) -c -o $@ $< $(CFLAGS) $(CPPFLAGS)

$(CC_OBJ): %.o: %.cc
	@mkdir -p $(@D)
	$(V_CXX)$(CXX) -c -o $@ $< $(CXXFLAGS) $(CPPFLAGS)
