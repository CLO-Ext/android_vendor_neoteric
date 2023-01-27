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

# Overlays
$(call inherit-product, vendor/zephyrus/overlay/overlay.mk)
$(call inherit-product, vendor/zephyrus/rro_overlays/rro_overlays.mk)

# Bootanimation
$(call inherit-product, vendor/zephyrus/bootanimation/bootanimation.mk)

# Don't dexpreopt prebuilts. (For GMS).
DONT_DEXPREOPT_PREBUILTS := true

# Fonts
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/zephyrus/prebuilts/fonts/,$(TARGET_COPY_OUT_PRODUCT)/fonts) \
    vendor/zephyrus/target/config/fonts_customization.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/fonts_customization.xml

$(call inherit-product, external/google-fonts/lato/fonts.mk)

# Include Common Qualcomm Device Tree.
$(call inherit-product, device/qcom/common/common.mk)

# Include definitions for Snapdragon Clang
$(call inherit-product, vendor/qcom/sdclang/config/SnapdragonClang.mk)

# Include Packages makefile.
$(call inherit-product, vendor/zephyrus/target/product/packages.mk)

# Include Properties makefile.
$(call inherit-product, vendor/zephyrus/target/product/properties.mk)

# Include APNs
$(call inherit-product, vendor/zephyrus/telephony/telephony.mk)

# Version
$(call inherit-product, vendor/zephyrus/target/product/version.mk)

# Include GMS, Modules, and Pixel features.
$(call inherit-product, vendor/google/gms/config.mk)

# Theme overlays
$(call inherit-product, vendor/themes/common.mk)

ifneq ($(TARGET_FLATTEN_APEX), true)
$(call inherit-product-if-exists, vendor/google/modules/build/mainline_modules.mk)
else
$(call inherit-product-if-exists, vendor/google/modules/build/mainline_modules_flatten_apex.mk)
endif

# Move Wi-Fi modules to vendor.
PRODUCT_VENDOR_MOVE_ENABLED := true

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml \
    vendor/zephyrus/target/config/permissions/default_permissions_com.google.android.deskclock.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default_permissions_com.google.android.deskclock.xml \
    vendor/zephyrus/target/config/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml \
    vendor/zephyrus/target/config/permissions/lily_experience.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/lily_experience.xml

# Compile SystemUI on device with `speed`.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.systemuicompilerfilter=speed

# Sensitive phone numbers and APN configurations
PRODUCT_COPY_FILES += \
    vendor/zephyrus/target/config/apns-conf.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/apns-conf.xml \
    vendor/zephyrus/target/config/sensitive_pn.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sensitive_pn.xml

# Skip boot JAR checks.
SKIP_BOOT_JARS_CHECK := true

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA ?= true
SYSTEMUI_OPTIMIZE_JAVA ?= true
