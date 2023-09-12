CUSTOM_ROM_VERSION := 1.0
NEOTERIC_BUILD_DATE := $(shell date +%s)

PRODUCT_SYSTEM_PROPERTIES += \
    ro.neoteric.version=$(CUSTOM_ROM_VERSION) \
    org.neoteric.build_type=Official \
    ro.neoteric.date.utc=$(shell date -d @$(NEOTERIC_BUILD_DATE) +%s)
