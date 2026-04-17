# parameters:
#   $(1): lowercase package name
#   $(2): uppercase package name
#   $(3): build target arch
#   $(4): build target os
#
define create-rules-waf
$(call create-rules-common,$(1),$(2),$(3),$(4))
ifneq ($(findstring $(3)-$(4),$(ARCHS)),)

$$(OBJ)/.$(1)-$(3)-configure: $$($(2)_SRC/wafbuild)
	@echo ":: configuring $(1)-$(3)..." >&2

	cd "$$($(2)_$(3)_OBJ)" && env $$($(2)_$(3)_ENV) \
	python3 $$($(2)_SRC)/waf configure \
	    --prefix="$$($(2)_$(3)_DST)" \
	    --libdir="$$($(2)_$(3)_LIBDIR)/$$($(3)-$(4)_LIBDIR)" \
	    $$($(2)_$(3)-$(4)_WAF_ARGS) \
	    $$($(2)_WAF_ARGS) \
	    $$($(2)_$(3)_WAF_ARGS)

	touch $$@

$$(OBJ)/.$(1)-$(3)-build:
	@echo ":: building $(1)-$(3)..." >&2
	+cd "$$($(2)_$(3)_OBJ)" && env $$($(2)_$(3)_ENV) \
	python3 $$($(2)_SRC)/waf -v build  \
	cd "$$($(2)_$(3)_OBJ)" && env $$($(2)_$(3)_ENV) \
	python3 $$($(2)_SRC)/waf -v install 
	touch $$@
endef

rules-waf = $(call create-rules-waf,$(1),$(call toupper,$(1)),$(2),$(3))
