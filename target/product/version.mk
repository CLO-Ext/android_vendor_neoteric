NEOTERIC_VERSION := 3.0
NEOTERIC_BUILD_DATE := $(shell date +%s)

PRODUCT_SYSTEM_PROPERTIES += \
    ro.neoteric.version=$(NEOTERIC_VERSION) \
    ro.neoteric.date.utc=$(shell date -d @$(NEOTERIC_BUILD_DATE) +%s)
