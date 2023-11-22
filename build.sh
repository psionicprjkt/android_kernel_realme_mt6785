#!/bin/bash

function psionic_compile()
{
source ~/.bashrc && source ~/.profile
export ARCH=arm64
[ -d "out" ] && rm -rf AnyKernel && rm -rf out || mkdir -p out
make O=out ARCH=arm64 RM6785_defconfig
PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      LD=ld.lld \
		      AR=llvm-ar \
		      NM=llvm-nm \
		      OBJCOPY=llvm-objcopy \
		      OBJDUMP=llvm-objdump \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log
}

function psionic_zip()
{
rm -rf AK3* && rm -rf AnyKernel
wget https://psionicprjkt.my.id/assets/files/AK3-RM6785.zip && unzip AK3-RM6785
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel && cd AnyKernel
date=$(date "+%d%m%Y")
zip -r9 psionicKSU-RM6785-$date-TEST.zip *
}

psionic_compile
psionic_zip
