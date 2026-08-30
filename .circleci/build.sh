#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 -b nexus-14  https://gitlab.com/Project-Nexus/nexus-clang.git clang
git clone --depth=1 https://github.com/Projects-aRise/AnyKernel3 AnyKernel
echo "Done"
echo "KernelSU"
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
echo "Curl Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
# Date and Time
DATE=$(TZ=Asia/Kolkata date +"%Y%m%d-%T")
START=$(date +"%s")
TANGGAL=$(date +"%F%S")
KERNEL_DIR=$(pwd)
PATH="${KERNEL_DIR}/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_USER=Zone-D543

# Compile plox
function compile() {
    make O=out ARCH=arm64 lavender_defconfig
    make -j$(nproc --all) O=out \
				ARCH=arm64 \
				CC=clang \
				CROSS_COMPILE=aarch64-linux-gnu- \
				CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
				LLVM=1 \
				LLVM_IAS=1 \
				LD=ld.lld \
				AR=llvm-ar \
				NM=llvm-nm \
				OBJCOPY=llvm-objcopy \
				OBJDUMP=llvm-objdump \
				STRIP=llvm-strip \
				READELF=llvm-readelf \
				OBJSIZE=llvm-size  2>&1 | tee log.txt

    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
	mkdir -p zone
	ZIPNAME="lavender.zip"
       cd AnyKernel
        zip -r9 "../$ZIPNAME" * 
        cd ..
        #Pindah Zip
        mv "$ZIPNAME" zone/
}
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))

