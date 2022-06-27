all::


FIND=find
PRINTF=printf
MKDIR=mkdir -p
AWK=awk
CP=cp
SED=sed
XARGS=xargs
GETVERSION=git describe

PREFIX=/usr/local

VERSION:=$(shell $(GETVERSION) 2> /dev/null)

## Provide a version of $(abspath) that can cope with spaces in the
## current directory.
myblank:=
myspace:=$(myblank) $(myblank)
MYCURDIR:=$(subst $(myspace),\$(myspace),$(CURDIR)/)
MYABSPATH=$(foreach f,$1,$(if $(patsubst /%,,$f),$(MYCURDIR)$f,$f))

-include $(call MYABSPATH,config.mk)
-include cswis-env.mk

HEADERS:=$(patsubst %.tab,%,$(shell $(FIND) tables -name "*.tab" -printf '%P\n'))

H_EXTRAS:=$(patsubst %.h,%,$(shell $(FIND) extras -name "*.h" -printf '%P\n'))

HDR_EXTRAS:=$(patsubst %.Hdr,%,$(shell $(FIND) extras -name "*.Hdr" -printf '%P\n'))

headers += $(HEADERS:%=riscos/%.h)
headers += $(HEADERS:%=riscos/%.Hdr)

riscos_zips += cswis
cswis_appname=!CSWIs
cswis_rof += !Boot,feb
cswis_rof += !Help,feb
cswis_rof += !Collect,fd7
cswis_rof += !Generate,feb
cswis_rof += Collect,ffb
cswis_rof += Generate,ffb
cswis_rof += Chunks,fff
cswis_rof += Docs/MANUAL,fff
cswis_rof += Docs/COPYING,fff
cswis_rof += Docs/README,fff
cswis_rof += Docs/VERSION,fff
cswis_rof += $(call riscos_hdr,$(headers))
cswis_rof += $(H_EXTRAS:%=Extras/%.h,fff)
cswis_rof += $(HDR_EXTRAS:%=Extras/%.Hdr,fff)
cswis_rof += $(HEADERS:%=Tables/%.tab,fff)


include binodeps.mk


tidy::
	-$(FIND) . -name "*~" -delete



all:: installed-libraries riscos-zips

tmp/obj/riscos/%.h: tables/%.tab
	@$(PRINTF) '[tab->C] <%s.h>\n' '$*' 
	@$(MKDIR) '$(@D)'
	@$(AWK) $(AWKFLAGS) -v NAME='$(subst /,_,$*)' -v INPUT='$*' \
		-f common.awk -f chdr.awk '$<' > '$@'

tmp/obj/riscos/%.Hdr: tables/%.tab
	@$(PRINTF) '[tab->ASM] %s.Hdr\n' '$*' 
	@$(MKDIR) '$(@D)'
	@$(AWK) $(AWKFLAGS) -v NAME='$(subst /,_,$*)' -v INPUT='$*' \
		-f common.awk -f asmhdr.awk '$<' > '$@'

$(HEADERS:%=tmp/obj/riscos/%.h) $(HEADERS:%=tmp/obj/riscos/%.Hdr): common.awk
$(HEADERS:%=tmp/obj/riscos/%.h): chdr.awk
$(HEADERS:%=tmp/obj/riscos/%.Hdr): asmhdr.awk

tmp/obj/riscos/swi/OS.h: extras/swi/OS.h


ifneq ($(VERSION),)
prepare-version::
	@$(MKDIR) tmp/
	@$(ECHO) $(VERSION) > tmp/VERSION

tmp/VERSION: | prepare-version
VERSION: tmp/VERSION
	@$(CMP) -s '$<' '$@' || $(CP) '$<' '$@'
endif


install:: install-headers install-riscos

update:
	-SRCDIR=$(PREFIX)/apps/!CSWIs/Tables ; \
	FILES=`$(FIND) $$SRCDIR -name '*,fff' -printf '%P\n'` ; \
	for F in $$FILES ; do \
		$(CP) "$$SRCDIR/$$F" "tables/$${F:0:$${#F}-4}" ; \
	done
	-SRCDIR=$(PREFIX)/apps/!CSWIs/Extras ; \
	FILES=`$(FIND) $$SRCDIR -name '*,fff' -printf '%P\n'` ; \
	for F in $$FILES ; do \
		$(CP) "$$SRCDIR/$$F" "extras/$${F:0:$${#F}-4}" ; \
	done
	-$(CP)	$(PREFIX)/apps/!CSWIs/!Generate,feb \
		$(PREFIX)/apps/!CSWIs/Generate,ffb \
		$(PREFIX)/apps/!CSWIs/!Collect,fd7 \
		$(PREFIX)/apps/!CSWIs/Collect,ffb \
		$(PREFIX)/apps/!CSWIs/Chunks,fff \
		src/riscos/cswis

$(BINODEPS_OUTDIR)/riscos/!CSWIs/Docs/README,fff: README.md
	$(MKDIR) "$(@D)"
	$(CP) "$<" "$@"

$(BINODEPS_OUTDIR)/riscos/!CSWIs/Docs/COPYING,fff: LICENSE.txt
	$(MKDIR) "$(@D)"
	$(CP) "$<" "$@"

$(BINODEPS_OUTDIR)/riscos/!CSWIs/Docs/VERSION,fff: VERSION
	$(MKDIR) "$(@D)"
	$(CP) "$<" "$@"

out/riscos/!CSWIs/Extras/%,fff: extras/%
	@$(PRINTF) '[Copy RISC OS extra] %s\n' '$*'
	@$(MKDIR) '$(@D)'
	@$(CP) '$<' '$@'

out/riscos/!CSWIs/Tables/%.tab,fff: tables/%.tab
	@$(PRINTF) '[Copy RISC OS table] %s\n' '$*'
	@$(MKDIR) '$(@D)'
	@$(CP) '$<' '$@'


# Set this to the comma-separated list of years that should appear in
# the licence.  Do not use characters other than [0-9,] - no spaces.
YEARS=2002-3,2006-7,2012

update-licence:
	$(FIND) . -name '.svn' -prune -or -type f -print0 | $(XARGS) -0 \
	$(SED) -i 's/Copyright (C) [0-9,-]\+  Steven Simpson/Copyright (C) $(YEARS)  Steven Simpson/g'
