CUSTOM_ROM_VERSION := 13.3
ZEPH_BUILD_DATE := $(shell date +%s)

PRODUCT_SYSTEM_PROPERTIES += \
    ro.zeph.version=$(CUSTOM_ROM_VERSION) \
    org.zephyrus.build_type=Official \
    ro.zeph.date.utc=$(shell date -d @$(ZEPH_BUILD_DATE) +%s)
