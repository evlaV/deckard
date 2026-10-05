#############################################################################
# where to install things:
PKGINCROOT    := $(DESTDIR)/usr/include/android
PKGTOOLDIR    := $(DESTDIR)/usr/lib/android-sdk/platform-tools
PKGLIBROOT    := $(DESTDIR)/usr/lib/$(CARCH)/android
PKGBINDIR     := $(DESTDIR)/usr/bin

############################################################################
# include files that don't belong with any particular subpackage:
INCLUDES += $(INCROOT)/frameworks/native/include/android
INCLUDES += $(INCROOT)/frameworks/native/libs/binder/include/binder
INCLUDES += $(INCROOT)/frameworks/native/libs/permission/include/binder
INCLUDES += $(INCROOT)/frameworks/native/libs/binder/include_activitymanager/binder
INCLUDES += $(INCROOT)/frameworks/native/libs/binder/include_activitymanager
INCLUDES += $(INCROOT)/system/core/libsystem/include/system
INCLUDES += $(INCROOT)/system/core/libcutils/include/private
INCLUDES += $(INCROOT)/system/core/libutils/include/utils
INCLUDES += $(INCROOT)/system/incremental_delivery/incfs/util/include/util
INCLUDES += $(INCROOT)/system/unwinding/libunwindstack/include/unwindstack
INCLUDES += $(wildcard $(INCROOT)/system/unwinding/libunwindstack/include/*)

############################################################################
# how to install things:
define recursive-install =
echo RECURSIVE $@ into $(firstword $|);         \
for s in $^;					\
do						\
  if [ -d $$s ];				\
  then						\
    dest=$(firstword $|)/$$(basename $$s);	\
    install -d $$dest;				\
    install -m 0644 -D -t $$dest $$s/*;		\
  else						\
    install -m 0644 -D -t $(firstword $|) $$s;	\
  fi						\
done
endef

############################################################################
$(PKGTOOLDIR) $(PKGBINDIR) $(PKGINCROOT) $(PKGLIBROOT):
	@install -d $@

$(PKGINCROOT)/%/:
	@install -d $@

install-libs: | $(PKGLIBROOT)
install-libs: $(filter-out %.so,$(LIBRARIES))
	@install -D -t $| $^
	@(cd $| && for so in $(notdir $^); do ln -sf $${so} $${so%.*}; done)

install-tools: | $(PKGTOOLDIR)
install-tools: $(TOOLS)
	@install -D -t $| $^

install-binscripts: | $(PKGBINDIR)
install-binscripts: $(INCROOT)/system/core/libsparse/simg_dump.py
install-binscripts: $(INCROOT)/system/tools/mkbootimg/mkbootimg.py
install-binscripts: $(INCROOT)/system/tools/mkbootimg/unpack_bootimg.py
	@for s in $^; do b=$$(basename $$s); install -T $$s $|/$${b%.*}; done

install-bin: | $(PKGBINDIR) install-binscripts
install-bin: $(USR_BINS)
	@install -D -t $(firstword $|) $^

install-inc-lzma: $(wildcard $(INCROOT)/external/lzma/C/*.h)
install-inc-cpu_features: $(wildcard $(INCROOT)/external/cpu_features/include/*)

install-inc-%: | $(PKGINCROOT)/%/
	@$(recursive-install)

install-inc-binder: | $(PKGINCROOT)/binder/
install-inc-binder: $(wildcard $(INCROOT)/frameworks/native/libs/binder/include_batterystats/batterystats/*)
	install -D -t $| $^

install-inc: | $(PKGINCROOT) install-inc-cpu_features install-inc-lzma install-inc-binder
install-inc: $(INCLUDES)
	@$(recursive-install)

install-misc:
	@for x in $(MISC_INST); \
	 do \
	   src=$${x%::*}; \
       dst=$(DESTDIR)/$${x#*::}; \
       dir=$$(dirname $$dst); \
	   install -d $$dir; \
	   install -T -m644 $${src} $${dst}; \
	 done

install: install-tools install-bin install-inc install-libs install-misc
