#!/usr/bin/env sh

install_deps
install_aseprite
exit 0

# --- script code --- #

install_deps() {
# install dependencies for macos
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install clang cmake ninja unzip
}

install_aseprite() {
# aseprite installation directory
ASEPRITE_DIR="$HOME/.local/lib/aseprite"

# compilation process
cd "~/.local/lib/"
git clone --recursive https://github.com/aseprite/aseprite.git
cd aseprite
curl "https://github.com/aseprite/skia/releases/download/latest/Skia-Linux-Release-x64-libc%2B%2B.zip" | unzip -q
mkdir build
cd build
cmake_platform
ninja aseprite

echo "Compilation Done."
echo "Please add '$ASEPRITE_DIR/build/bin/' to PATH"
}

cmake_platform() {

echo "Which CPU do you have?"
echo
echo "1) Apple Silicon (arm64)"
echo "2) Intel         (x86_64)"
echo
read -n 1 -p "Enter a number: "

case $REPLY in
    1) # arm
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$HOME/deps/skia \
  -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-arm64 \
  -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-arm64/libskia.a \
  -DPNG_ARM_NEON:STRING=on \
  -G Ninja \
  ..
    ;;
    2) # intel
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$HOME/deps/skia \
  -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-arm64 \
  -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-arm64/libskia.a \
  -DPNG_ARM_NEON:STRING=on \
  -G Ninja \
  ..
    ;;
    *) # invalid option
        echo "Unrecognized option. Please try again."
        cmake_platform
esac
}