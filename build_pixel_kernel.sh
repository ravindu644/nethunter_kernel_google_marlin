#!/bin/bash

echo -e "\n[INFO]: BUILD STARTED..!\n"

#init submodules
git submodule init && git submodule update

export KERNEL_ROOT="$(pwd)"
export ARCH=arm64
export KBUILD_BUILD_USER="@ravindu644"

mkdir -p "${KERNEL_ROOT}/out" "${KERNEL_ROOT}/build" "${HOME}/toolchains"

# Init clang-r450784e
if [ ! -d "${HOME}/toolchains/clang-r450784e" ]; then
    echo -e "\n[INFO] Cloning clang-r450784e Toolchain\n"
    mkdir -p "${HOME}/toolchains/clang-r450784e" && cd "${HOME}/toolchains/clang-r450784e"
    curl -LO "https://android.googlesource.com/platform//prebuilts/clang/host/linux-x86/+archive/722c840a8e4d58b5ebdab62ce78eacdafd301208/clang-r450784e.tar.gz"
    tar -xf clang-r450784e.tar.gz && rm clang-r450784e.tar.gz
    cd "${KERNEL_ROOT}"
fi

# Init arm gnu toolchain
if [ ! -d "${HOME}/toolchains/gcc" ]; then
    echo -e "\n[INFO] Cloning ARM GNU Toolchain\n"
    mkdir -p "${HOME}/toolchains/gcc" && cd "${HOME}/toolchains/gcc"
    curl -LO "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz"
    tar -xf arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
    cd "${KERNEL_ROOT}"
fi

# Export toolchain paths
export PATH="${HOME}/toolchains/clang-r450784e/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/toolchains/clang-r450784e/lib64:${LD_LIBRARY_PATH}"

# Set cross-compile environment variables
export BUILD_CROSS_COMPILE="${HOME}/toolchains/gcc/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-"
export BUILD_CC="${HOME}/toolchains/clang-r450784e/bin/clang"

# Build options for the kernel
export BUILD_OPTIONS=(
    -C "${KERNEL_ROOT}"
    O="${KERNEL_ROOT}/out"
    -j"$(nproc)"
    ARCH=arm64
    LLVM=1
    LLVM_IAS=1
    CROSS_COMPILE="${BUILD_CROSS_COMPILE}"
    CC="${BUILD_CC}"
    CLANG_TRIPLE=aarch64-linux-gnu-
)

build_kernel(){
    # Make default configuration.
    make "${BUILD_OPTIONS[@]}" pixel_marlin_defconfig

    # Configure the kernel (GUI)
    make "${BUILD_OPTIONS[@]}" menuconfig

    # Build the kernel
    make "${BUILD_OPTIONS[@]}" Image || exit 1

    # Copy the built kernel to the build directory
    cp "${KERNEL_ROOT}/out/arch/arm64/boot/Image" "${KERNEL_ROOT}/build"

    echo -e "\n[INFO]: BUILD FINISHED..!"
}
build_kernel
