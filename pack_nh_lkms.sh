#!/bin/bash

# fresh directories
DIRS=(
    "${KERNEL_ROOT}/build/nh_lkms"
    "${KERNEL_ROOT}/prebuilts_marlin/lkm-magisk-module/system/vendor/lib/modules"
)

for dir in "${DIRS[@]}"; do
    rm -rf "${dir}"
    mkdir -p "${dir}"
done

# Copy the LKMs to the build directory
find "${KERNEL_ROOT}/out" -name "*.ko" -exec cp {} "${KERNEL_ROOT}/build/nh_lkms" \;

# Check the nh_lkms directory is not empty
if [ -z "$(ls -A "${KERNEL_ROOT}/build/nh_lkms")" ]; then
    echo -e "\n[ERROR]: NO LKMS FOUND..!"
    exit 1
fi

# Base Variables for LKM tools
LKM_TOOLS_DIR="${KERNEL_ROOT}/prebuilts_marlin/LKM_Tools"
PKG_NH_MODULES="${LKM_TOOLS_DIR}/04.prepare_only_nethunter_modules.sh"
NH_MODULES_DIR="${KERNEL_ROOT}/build/nh_lkms"
STAGING_DIR="${NH_MODULES_DIR}"
SYSTEM_MAP="${KERNEL_ROOT}/out/System.map"
OUTPUT_DIR="${KERNEL_ROOT}/prebuilts_marlin/lkm-magisk-module/system/vendor/lib/modules"
STRIP_TOOL="$(dirname ${BUILD_CC})/llvm-strip"

# Run LKM tools
# Documentation: ./04.prepare_only_nethunter_modules.sh <nh_modules_dir> <staging_dir> <vendor_boot_list> <vendor_dlkm_list> <system_map> <output_dir> [strip_tool] [blacklist_file]
{
    ${PKG_NH_MODULES} \
        "${NH_MODULES_DIR}" \
        "${STAGING_DIR}" \
        "" \
        "" \
        "${SYSTEM_MAP}" \
        "${OUTPUT_DIR}" \
        "${STRIP_TOOL}" \
        ""
} || {
    echo -e "\n[ERROR]: LKM TOOLS FAILED..!"
    exit 1
}
