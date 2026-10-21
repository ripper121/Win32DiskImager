#!/usr/bin/env bash
# Cross-compile Win32DiskImager-cli.exe for Windows (x86-64) on Linux using MinGW-w64.
# Requirements: mingw-w64  (apt-get install mingw-w64)
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$ROOT/bin"
BUILD_DIR="$BIN_DIR/cli-build"

mkdir -p "$BUILD_DIR"

# ---- compile resource file (icon + version info + manifest) ----
cat > "$BUILD_DIR/cli_res.rc" << 'RC'
#include <winresrc.h>

#define IDI_APP_ICON 101
IDI_APP_ICON ICON "__SRCDIR__/images/Win32DiskImager.ico"
1 RT_MANIFEST "__SRCDIR__/DiskImagerCli.manifest"

VS_VERSION_INFO VERSIONINFO
 FILEVERSION 2,0,0,0
 PRODUCTVERSION 2,0,0,0
 FILEFLAGSMASK 0x17L
 FILEFLAGS 0x0L
 FILEOS 0x4L
 FILETYPE 0x1L
 FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904b0"
        BEGIN
            VALUE "FileDescription", "Win32DiskImager CLI"
            VALUE "FileVersion", "2.0.0"
            VALUE "InternalName", "Win32DiskImager-cli"
            VALUE "OriginalFilename", "Win32DiskImager-cli.exe"
            VALUE "ProductName", "Win32 Image Writer CLI"
            VALUE "ProductVersion", "2.0.0"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 1200
    END
END
RC

# Substitute actual source path
sed -i "s|__SRCDIR__|$ROOT/src|g" "$BUILD_DIR/cli_res.rc"

x86_64-w64-mingw32-windres "$BUILD_DIR/cli_res.rc" -o "$BUILD_DIR/cli_res.o"

# ---- compile and link ----
x86_64-w64-mingw32-g++ \
  -std=c++17 \
  -O2 \
  -DWINVER=0x0A00 \
  -D_WIN32_WINNT=0x0A00 \
  -DUNICODE \
  -D_UNICODE \
  -mconsole \
  -static \
  -static-libgcc \
  -static-libstdc++ \
  "$ROOT/src/cli_main.cpp" \
  "$BUILD_DIR/cli_res.o" \
  -o "$BIN_DIR/Win32DiskImager-cli.exe" \
  -lkernel32 -luser32 -ladvapi32

echo "Build successful: $BIN_DIR/Win32DiskImager-cli.exe"
