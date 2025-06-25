#!/bin/bash
set -euxo pipefail

DEPS=$(pwd)/deps
SYSROOT=$SYSROOT

export CC="$CC"
export AR="$AR"
export RANLIB="$RANLIB"
export STRIP="$STRIP"
export CPPFLAGS="-I$DEPS/include"
export LDFLAGS="-L$DEPS/lib"
export PKG_CONFIG_PATH="$DEPS/lib/pkgconfig"

mkdir -p "$DEPS"

build_autoconf_lib() {
  NAME=$1
  URL=$2
  DIR=$3
  EXTRA_CONF=$4

  echo "📥 Downloading $NAME from $URL..."
  curl -L --retry 3 -O "$URL"
  tar --auto-compress -xf "$(basename "$URL")"
  cd "$DIR"

  echo "⚙️ Configuring $NAME..."
  ./configure \
    --host=$TARGET \
    --prefix=$DEPS \
    --with-sysroot=$SYSROOT \
    --disable-shared \
    --enable-static \
    $EXTRA_CONF

  echo "🔨 Building $NAME..."
  make -j$(nproc)
  make install
  cd ..
}

# zlib (no --host support)
build_zlib() {
  curl -L --retry 3 -O https://zlib.net/fossils/zlib-1.2.13.tar.gz
  tar -xf zlib-1.2.13.tar.gz
  cd zlib-1.2.13

  ./configure --static --prefix=$DEPS
  make -j$(nproc)
  make install
  cd ..
}

# openssl (uses ./Configure instead of ./configure)
build_openssl() {
  curl -L --retry 3 -O https://www.openssl.org/source/openssl-3.2.1.tar.gz
  tar -xf openssl-3.2.1.tar.gz
  cd openssl-3.2.1

  ./Configure linux-armv4 no-shared --prefix=$DEPS --cross-compile-prefix=arm-linux-androideabi-
  make -j$(nproc)
  make install_sw
  cd ..
}

echo "📦 Starting dependency builds..."

build_zlib

build_autoconf_lib "libiconv" \
  https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz \
  libiconv-1.17 ""

build_autoconf_lib "libxml2" \
  https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.6.tar.xz \
  libxml2-2.12.6 "--without-python"

build_autoconf_lib "oniguruma" \
  https://github.com/kkos/oniguruma/releases/download/v6.9.8/onig-6.9.8.tar.gz \
  onig-6.9.8 ""

build_autoconf_lib "libjpeg-turbo" \
  https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-2.1.5.tar.gz \
  libjpeg-turbo-2.1.5 ""

build_autoconf_lib "libpng" \
  https://download.sourceforge.net/libpng/libpng-1.6.40.tar.gz \
  libpng-1.6.40 ""

build_autoconf_lib "freetype" \
  https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz \
  freetype-2.13.2 ""

build_openssl

build_autoconf_lib "curl" \
  https://curl.se/download/curl-8.8.0.tar.gz \
  curl-8.8.0 "--with-ssl=$DEPS --with-zlib=$DEPS"

echo "✅ All dependencies built successfully."
