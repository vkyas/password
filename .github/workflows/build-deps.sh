#!/bin/bash

set -e
DEPS=$(pwd)/deps
SYSROOT=$TOOLCHAIN/sysroot

build_lib() {
  NAME=$1
  URL=$2
  CONFIGURE_OPTS=$3
  DIR=$4

  curl -LO $URL
  tar -xf *.tar.*
  cd $DIR || exit 1

  ./configure \
    --host=$TARGET \
    --prefix=$DEPS \
    --with-sysroot=$SYSROOT \
    $CONFIGURE_OPTS

  make -j$(nproc)
  make install
  cd ..
}

export CC=$TOOLCHAIN/bin/${TARGET}${API_LEVEL}-clang
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
export CPPFLAGS="-I$DEPS/include"
export LDFLAGS="-L$DEPS/lib"

# Build libraries
build_lib "zlib" https://zlib.net/zlib-1.2.13.tar.gz "" zlib-1.2.13
build_lib "libiconv" https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz "" libiconv-1.17
build_lib "libxml2" https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.12.6/libxml2-v2.12.6.tar.gz "" libxml2-v2.12.6
build_lib "oniguruma" https://github.com/kkos/oniguruma/releases/download/v6.9.8/onig-6.9.8.tar.gz "" onig-6.9.8
build_lib "libjpeg-turbo" https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-2.1.5.tar.gz "" libjpeg-turbo-2.1.5
build_lib "libpng" https://download.sourceforge.net/libpng/libpng-1.6.40.tar.gz "" libpng-1.6.40
build_lib "freetype" https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz "" freetype-2.13.2
build_lib "openssl" https://www.openssl.org/source/openssl-3.2.1.tar.gz "" openssl-3.2.1
build_lib "curl" https://curl.se/download/curl-8.8.0.tar.gz "" curl-8.8.0
