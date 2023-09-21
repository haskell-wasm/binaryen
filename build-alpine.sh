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

cmake \
  -Bbuild \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=$PWD/clang++.py \
  -DCMAKE_INSTALL_PREFIX=$PWD/binaryen-version_116 \
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
  -cJf binaryen-version_116-x86_64-linux-musl.tar.xz binaryen-version_116
