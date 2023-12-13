#!/bin/bash

# Copyright (C) 2023 psionicprjkt

function psionic_compile()
{
    # setup_environment
    source ~/.bashrc
    source ~/.profile

    # cleanup_directories
    rm -rf out AnyKernel AK3-* && mkdir -p out

    # compile_kernel
    export ARCH=arm64
    make O=out ARCH=arm64 RM6785_defconfig
    PATH="${PWD}/clang/bin:${PWD}/arm64:${PWD}/arm32:${PATH}" \
        make -j$(nproc --all) O=out \
        LLVM=1 \
        LLVM_IAS=1 \
        ARCH=arm64 \
        CC="clang" \
        LD=ld.lld \
        STRIP=llvm-strip \
        AS=llvm-as \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE="${PWD}/arm64/aarch64-linux-android-" \
        CROSS_COMPILE_COMPAT="${PWD}/arm32/arm-linux-androideabi-" \
        CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log
}


function psionic_zip()
{
    # download_ak3
    wget https://psionicprjkt.my.id/assets/files/AK3-RM6785.zip && unzip AK3-RM6785

    # setup_kernel_release
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel && cd AnyKernel
    date=$(date "+%d%m%Y")
    zip -r9 psionic-kernel-RM6785-$date-release-ksu-oc.zip *
}

psionic_compile
psionic_zip

