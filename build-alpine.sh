#!/bin/sh

set -eu

apk upgrade
apk add \
  alpine-sdk \
  clang \
  cmake \
  coreutils \
  git \
  lld \
  llvm \
  nodejs \
  py3-pip \
  samurai \
  xz

pip3 install -r requirements-dev.txt

cd third_party/mimalloc
git apply ../mimalloc.diff
cd ../..

cmake \
  -Bthird_party/mimalloc/out \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DMI_BUILD_SHARED=OFF \
  -DMI_BUILD_OBJECT=OFF \
  -DMI_BUILD_TESTS=OFF \
  third_party/mimalloc

cmake --build third_party/mimalloc/out -- -v

LIBC_PATH=/usr/lib/libc.a

{
  echo "CREATE libc.a"
  echo "ADDLIB $LIBC_PATH"
  echo "DELETE aligned_alloc.lo"
  echo "DELETE calloc.lo"
  echo "DELETE donate.lo"
  echo "DELETE free.lo"
  echo "DELETE libc_calloc.lo"
  echo "DELETE lite_malloc.lo"
  echo "DELETE malloc.lo"
  echo "DELETE malloc_usable_size.lo"
  echo "DELETE memalign.lo"
  echo "DELETE posix_memalign.lo"
  echo "DELETE realloc.lo"
  echo "DELETE reallocarray.lo"
  echo "ADDLIB third_party/mimalloc/out/libmimalloc.a"
  echo "SAVE"
} | llvm-ar -M

mv libc.a $LIBC_PATH

cmake \
  -Bbuild \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=$PWD/clang++.py \
  -DCMAKE_INSTALL_PREFIX=$PWD/binaryen-version_114 \
  -DCMAKE_JOB_POOLS="linking=1" \
  -DCMAKE_JOB_POOL_LINK=linking \
  -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld -s -static" \
  -DBUILD_STATIC_LIB=ON \
  -DENABLE_WERROR=OFF \
  -DINSTALL_LIBS=OFF

cmake --build build --target install -- -v

CC=clang CXX=clang++ COMPILER_FLAGS="-Wno-unused-command-line-argument -fuse-ld=lld -s -static" ./check.py --binaryen-bin build/bin --binaryen-lib build/lib

XZ_OPT="-T0 -9" \
  tar \
  --sort=name \
  --mtime=1970-01-01T00:00:00Z \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -cJf binaryen-version_114-x86_64-linux-musl.tar.xz binaryen-version_114
