# Copyright (C) 2022 Paranoid Android
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Handle various build version information.
#
# Guarantees that the following are defined:
#     ZEPHYRUS_MAJOR_VERSION
#     ZEPHYRUS_MINOR_VERSION
#     ZEPHYRUS_BUILD_VARIANT
#

# This is the global ZEPHYRUS version flavor that determines the focal point
# behind our releases. This is bundled alongside $(ZEPHYRUS_MINOR_VERSION)
# and only changes per major Android releases.
ZEPHYRUS_MAJOR_VERSION := topaz

# The version code is the upgradable portion during the cycle of
# every major Android release. Each version code upgrade indicates
# our own major release during each lifecycle.
ifdef ZEPHYRUS_BUILDVERSION
    ZEPHYRUS_MINOR_VERSION := $(ZEPHYRUS_BUILDVERSION)
else
    ZEPHYRUS_MINOR_VERSION := 1
endif

# Build Variants
#
# Alpha: Development / Test releases
# Beta: Public releases with CI
# Release: Final Product | No Tagging
ifdef ZEPHYRUS_BUILDTYPE
  ifeq ($(ZEPHYRUS_BUILDTYPE), ALPHA)
      ZEPHYRUS_BUILD_VARIANT := alpha
  else ifeq ($(ZEPHYRUS_BUILDTYPE), BETA)
      ZEPHYRUS_BUILD_VARIANT := beta
  else ifeq ($(ZEPHYRUS_BUILDTYPE), RELEASE)
      ZEPHYRUS_BUILD_VARIANT := release
  endif
else
  ZEPHYRUS_BUILD_VARIANT := unofficial
endif

# Build Date
BUILD_DATE := $(shell date -u +%Y%m%d)

# ZEPHYRUS Version
TMP_ZEPHYRUS_VERSION := $(ZEPHYRUS_MAJOR_VERSION)-
ifeq ($(filter release,$(ZEPHYRUS_BUILD_VARIANT)),)
    TMP_ZEPHYRUS_VERSION += $(ZEPHYRUS_BUILD_VARIANT)-
endif
ifeq ($(filter unofficial,$(ZEPHYRUS_BUILD_VARIANT)),)
    TMP_ZEPHYRUS_VERSION += $(ZEPHYRUS_MINOR_VERSION)-
endif
TMP_ZEPHYRUS_VERSION += $(ZEPHYRUS_BUILD)-$(BUILD_DATE)
ZEPHYRUS_VERSION := $(shell echo $(TMP_ZEPHYRUS_VERSION) | tr -d '[:space:]')

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.zephyrus.version=$(ZEPHYRUS_VERSION)

# The properties will be uppercase for parse by Settings, etc.
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.zephyrus.version.major=$(shell V1=$(ZEPHYRUS_MAJOR_VERSION); echo $${V1^}) \
    ro.zephyrus.version.minor=$(ZEPHYRUS_MINOR_VERSION) \
    ro.zephyrus.build.variant=$(shell V2=$(ZEPHYRUS_BUILD_VARIANT); echo $${V2^})
