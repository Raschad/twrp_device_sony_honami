#!/bin/bash
#
# Copyright (C) 2015-2016 The CyanogenMod Project
#           (C) 2017-2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

DEVICE=z3c
VENDOR=sony

# Load extractutils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..

HELPER="$LINEAGE_ROOT"/vendor/omni/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
source "$HELPER"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true
SECTION=
KANG=

while [ "$1" != "" ]; do
    case "$1" in
        -n | --no-cleanup )     CLEAN_VENDOR=false
                                ;;
        -k | --kang)            KANG="--kang"
                                ;;
        -s | --section )        shift
                                SECTION="$1"
                                CLEAN_VENDOR=false
                                ;;
        * )                     SRC="$1"
                                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC=adb
fi

function blob_fixup() {
    case "${1}" in
    recovery/root/sbin/android.hardware.keymaster@3.0-service)
        sed -i "s|/system/bin/linker|/sbin/linker\x0\x0\x0\x0\x0\x0|g" "${2}"
        sed -i "s|/system/bin/sh\x0|/sbin/sh\x0\x0\x0\x0\x0\x0\x0|g" "${2}"
        ;;
    recovery/root/sbin/hwservicemanager)
        sed -i "s|/system/bin/linker|/sbin/linker\x0\x0\x0\x0\x0\x0|g" "${2}"
        sed -i "s|/system/bin/sh\x0|/sbin/sh\x0\x0\x0\x0\x0\x0\x0|g" "${2}"
        ;;
    recovery/root/sbin/qseecomd)
        sed -i "s|/system/bin/linker|/sbin/linker\x0\x0\x0\x0\x0\x0|g" "${2}"
        sed -i "s|/system/bin/sh\x0|/sbin/sh\x0\x0\x0\x0\x0\x0\x0|g" "${2}"
        ;;
    esac
}


# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT" false "$CLEAN_VENDOR"

extract "$MY_DIR"/proprietary-files.txt "$SRC" "$SECTION"
