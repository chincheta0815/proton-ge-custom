# parameters:
#   $(1): lowercase package name
#   $(2): uppercase package name
#   $(3): build target arch
#   $(4): build target os
#
define create-rules-winedll-in-tree
$(call create-rules-common,$(1),$(2),$(3),$(4))
ifneq ($(findstring $(3)-$(4),$(ARCHS)),)

WINEDLL_MAKEFILE_NAME=Makefile-winedll-in-tree.in

ifeq ($(3),i386)
$(2)_WINEDLL_BITFLAG=-m32
else ifeq ($(3),x86_64)
$(2)_WINEDLL_BITFLAG=-m64
endif

$$(OBJ)/.$(1)-$(3)-configure:
	@echo ":: configuring $(1)-$(3)..." >&2
	rsync --filter=:C --include '*.h' --include '*.c' --include '*.spec' --include '*.rc' --info=name -Oarx --delete "$$($(2)_SRC)/" "$$($(2)_$(3)_OBJ)" $(--quiet?)
	+cp $(SRC)/make/$$(WINEDLL_MAKEFILE_NAME) $$($(2)_$(3)_OBJ)

	touch $$@

$$(OBJ)/.$(1)-$(3)-build:
	@echo ":: building $(1)-$(3)..." >&2
	+cd "$$($(2)_$(3)_OBJ)" && env $$($(2)_$(3)_ENV) \
	$$(BEAR) \
	WINEDLL_NAME_PREFIX="$(1)" \
	WINEDLL_NAME_PREFIX="$$($(2)_$(3)_DLL_NAME_PREFIX)" \
	WINEDLL_WINEBUILD=$$(WINE_$$(HOST_ARCH)_OBJ)/tools/winebuild/winebuild \
	WINEDLL_WINEGCC=$$(WINE_$$(HOST_ARCH)_OBJ)/tools/winegcc/winegcc \
	WINEDLL_BITFLAG=$$($(2)_WINEDLL_BITFLAG) \
	WINEDLL_EXTRA_CFLAGS="$$($(3)_CFLAGS) $$($(2)_EXTRA_CFLAGS)" \
	WINEDLL_EXTRA_INCLUDES="-I$$(WINE_SRC)/include -I$$(WINE_SRC)/include/wine \
		-I$$(WINE_$(HOST_ARCH)_DST)/include -I$$(WINE_$(HOST_ARCH)_DST)/include/wine -I$$(WINE_$(HOST_ARCH)_DST)/include/wine/windows" \
	WINEDLL_EXTRA_LDFLAGS="$$($3)_LDFLAGS) -L$$(WINE_$(HOST_ARCH)_LIBDIR)/wine \
		-L$$(WINE_$(HOST_ARCH)_LIBDIR)/wine/$(3)-unix -L$$(WINE_$(HOST_ARCH)_LIBDIR)/wine/$(3)-windows \
		$$($(2)_WINEGCC_LDFLAGS)" \
	$$(MAKE) -f $$(WINEDLL_MAKEFILE_NAME) winedll 

	+cd "$$($(2)_$(3)_OBJ)" && env $$($(2)_$(3)_ENV) \
	WINEDLL_NAME_PREFIX="$(1)" \
	WINEDLL_NAME_PREFIX="$$($(2)_$(3)_DLL_NAME_PREFIX)" \
	WINEDLL_INST_DLL_DIR=$$(WINE_$(HOST_ARCH)_LIBDIR)/wine/$(3)-windows \
	WINEDLL_INST_SO_DIR=$$(WINE_$(HOST_ARCH)_LIBDIR)/wine/$(3)-unix \
	$$(MAKE) -f $$(WINEDLL_MAKEFILE_NAME) install-winedll

	touch $$@
endif
endef

rules-winedll-in-tree = $(call create-rules-winedll-in-tree,$(1),$(call toupper,$(1)),$(2),$(3))
