t/%.pkm: o/development/etc1tool
t/%.pkm: %.png
	@mkdir -p $(@D)
	@echo ETC1 ENCODE $(notdir $<)
	@o/development/etc1tool $< --encode -o $@

check-etc1tool: t/development/tools/templates/ic_launcher_ldpi.pkm
	@echo ETC1 DECODE $(notdir $<)	
	@o/development/etc1tool $< --decode

check-fastboot-%: o/system/fastboot
	@echo $(notdir $<) $*; $< $*

check-adb-%: o/system/adb
	@echo $(notdir $<) $*; $< $*

check-adb-keygen: ARGS := keygen t/key.txt
check-adb-keygen: o/system/adb
	@mkdir -p t/
	@echo $(notdir $<) $(ARGS); $< $(ARGS)
	@ls -l t/key.txt*
	@rm -f t/key.txt*
	@echo ADB KEYGEN OK

check: export LD_LIBRARY_PATH=o/system
check: check-etc1tool
check: check-fastboot---version
check: check-fastboot-devices
check: check-adb-version
check: check-adb-help
check: check-adb-keygen
check: clean-check

clean-check:
	@rm -rvf t/

clean: clean-check
