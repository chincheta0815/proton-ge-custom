# parameters:
#   $(1): lowercase package name
#   $(2): uppercase package name
#   $(3): build target arch
#
define create-rules-wine-dll
$(call create-rules-common,$(1),$(2),$(3))
ifneq ($(findstring $(3)-unix,$(ARCHS)),)

$(2)_WINEDLL_MAKEFILE_NAME ?= Makefile.wine11

$$(OBJ)/.$(1)-$(3)-configure:
	@echo ":: configuring $(1)-$(3)..." >&2
	rsync --filter=:C --info=name -Oarx --delete "$$($(2)_SRC)/" "$$($(2)_$(3)_OBJ)" $(--quiet?)

	touch $$@

$$(OBJ)/.$(1)-$(3)-build:
	@echo ":: building $(1)-$(3)..." >&2
	+cd "$$($(2)_$(3)_OBJ)" && env $$($(2)_$(3)_ENV) \
	$$(BEAR) \
	WINE_PREFIX=$$(WINE_$(HOST_ARCH)_DST) \
	WINEBUILD=$$(WINE_$$(HOST_ARCH)_OBJ)/tools/winebuild/winebuild \
	BUILD_DIR=$$($(2)_$(3)_OBJ)/build-$(1)-$(3) \
	UNIX_EXTRA_CFLAGS="-I$$(WINE_SRC)/include \
		-I$$(WINE_SRC)/include/wine -I$$(WINE_$(3)_DST)/include/wine" \
	MINGW$$($(2)_BITFLAG)=$$($(3)-windows_TARGET)-gcc \
	DLLTOOL$$($(2)_BITFLAG)=$$($(3)-windows_TARGET)-dlltool \
	GCC=$$(CC) \
	$$(MAKE) -f $$($(2)_WINEDLL_MAKEFILE_NAME) $(3)

	@echo ":: installing $(1)-$(3)..." >&2
ifeq ($(3),i386)
	+cp $$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio.dll $$(WINE_$(3)_LIBDIR)/wine/$(3)-windows/
	+cp $$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio.so $$(WINE_$(3)_LIBDIR)/wine/$(3)-unix/
	$(call install-strip,$$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio.dll,$$(DST_LIBDIR)/wine/$(3)-windows)
	$(call install-strip,$$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio.so,$$(DST_LIBDIR)/wine/$(3)-unix)
	$(call install-strip,$$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio.so,$$(DST_LIBDIR)/wine/x86_64-unix)
	$$(WINE_$$(HOST_ARCH)_OBJ)/tools/winebuild/winebuild --builtin $$(DST_LIBDIR)/wine/$(3)-windows/wineasio.dll
	@echo "wineasio 32-bit installation complete"
endif

ifeq ($(3),x86_64)
	+cp $$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio64.dll $$(WINE_$(3)_LIBDIR)/wine/$(3)-windows/
	+cp $$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio64.so $$(WINE_$(3)_LIBDIR)/wine/$(3)-unix/
	$(call install-strip,$$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio64.dll,$$(DST_LIBDIR)/wine/$(3)-windows)
	$(call install-strip,$$($(2)_$(3)_OBJ)/build-$(1)-$(3)/wineasio64.so,$$(DST_LIBDIR)/wine/$(3)-unix)
	$$(WINE_$$(HOST_ARCH)_OBJ)/tools/winebuild/winebuild --builtin $$(DST_LIBDIR)/wine/$(3)-windows/wineasio64.dll
	@echo "wineasio 64-bit installation complete"
endif
	touch $$@
endif
endef

rules-wine-dll = $(call create-rules-wine-dll,$(1),$(call toupper,$(1)),$(2))
