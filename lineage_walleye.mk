#
# Copyright 2016 The Android Open Source Project
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

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit some common EvolutionX stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# EvolutionX Specific Flags
EVO_BUILD_TYPE := Official
WITH_GMS := true

# Inherit BCR
BUILD_BCR := false

# EPPE
TARGET_DISABLE_EPPE := true

# Boot animation
TARGET_SCREEN_HEIGHT := 1920
TARGET_SCREEN_WIDTH := 1080

# Inherit device configuration
$(call inherit-product, device/google/walleye/device.mk)
$(call inherit-product, vendor/google/walleye/walleye-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/walleye/proprietary/device-vendor-walleye.mk)

PRODUCT_PACKAGES += \
    vndk_package

PRODUCT_COPY_FILES += \
    device/google/walleye/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

PRODUCT_PACKAGES += com.android.vndk.current.on_vendor

## Device identifier. This must come after all inclusions
PRODUCT_MANUFACTURER := Google
PRODUCT_BRAND := google
PRODUCT_NAME := lineage_walleye
PRODUCT_DEVICE := walleye
PRODUCT_MODEL := Pixel 2

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=walleye \
    PRIVATE_BUILD_DESC="walleye-user 11 RP1A.201005.004.A1 6934943 release-keys"

BUILD_FINGERPRINT := google/walleye/walleye:11/RP1A.201005.004.A1/6934943:user/release-keys
