#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=walleye
VENDOR=google

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_FIRMWARE=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-firmware )
                ONLY_FIRMWARE=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    # Fix typo in qcrilmsgtunnel whitelist
    product/etc/sysconfig/nexus.xml)
        sed -i 's/qulacomm/qualcomm/' "${2}"
        ;;
    # Fix missing symbols for IMS/Camera
    lib/lib-imsvideocodec.so | lib/libimsmedia_jni.so | lib64/lib-imsvideocodec.so | lib64/libimsmedia_jni.so)
        for LIBGUI_SHIM in $(grep -L "libgui_shim.so" "${2}"); do
            "${PATCHELF}" --add-needed "libgui_shim.so" "${LIBGUI_SHIM}"
        done
        ;;
    vendor/bin/pm-service)
        grep -q libutils-v33.so "${2}" || "${PATCHELF}" --add-needed "libutils-v33.so" "${2}"
        ;;
    # Fix missing symbol _ZN7android8hardware7details17gBnConstructorMapE
    lib*/com.qualcomm.qti.imsrtpservice@1.0.so | vendor/bin/cnd | vendor/bin/ims_rtp_daemon | vendor/bin/imsrcsd | vendor/bin/netmgrd | vendor/lib*/com.quicinc.cne.api@1.0.so)
        "${PATCHELF}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
        ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

if [ -z "${ONLY_FIRMWARE}" ]; then
  extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
  extract "${MY_DIR}/proprietary-files-vendor.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${SECTION}" ]; then
    extract_firmware "${MY_DIR}/proprietary-firmware.txt" "${SRC}"
fi

"${MY_DIR}/setup-makefiles.sh"
