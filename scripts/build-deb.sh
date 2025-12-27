#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Download Source.

SRC_DIR="$(mktemp -d)"

git clone --depth 1 --branch "$AVIZO_BRANCH" https://github.com/heyjuvi/avizo.git "$SRC_DIR/avizo-src"

cd "$SRC_DIR/avizo-src"


# -- Configure Build.

meson setup .build --prefix=/usr --buildtype=release


# -- Compile Source.

ninja -C .build -k 0 -j "$(nproc)"


# -- Create a temporary DESTDIR.

DESTDIR="$(pwd)/pkg"

rm -rf "$DESTDIR"


# -- Install to DESTDIR.

DESTDIR="$DESTDIR" ninja -C .build install


# -- Create DEBIAN control file.

mkdir -p "$DESTDIR/DEBIAN"

PKGNAME="avizo"
MAINTAINER="uri_herrera@nxos.org"
ARCHITECTURE="$(dpkg --print-architecture)"
DESCRIPTION="Avizo is a simple notification daemon, mainly intended to be used for multimedia keys for example with Sway."

cat > "$DESTDIR/DEBIAN/control" <<EOF
Package: $PKGNAME
Version: $PACKAGE_VERSION
Section: utils
Priority: optional
Architecture: $ARCHITECTURE
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF


# -- Build the Debian package.

cd "$(dirname "$DESTDIR")"

dpkg-deb --build "$(basename "$DESTDIR")" "${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb"


# -- Move .deb to ./build/ for CI consistency.

mkdir -p "$GITHUB_WORKSPACE/build"

mv "${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb" "$GITHUB_WORKSPACE/build/"

echo "Debian package created: $(pwd)/build/${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb"
