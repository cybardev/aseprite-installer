#!/usr/bin/env bash

# set installation directories
LIB="$HOME/.local/lib"
ASEPRITE_DIR="$LIB/aseprite"
SKIA_DIR="$ASEPRITE_DIR/skia"

# fail if installation directory is occupied
if [ -d "$ASEPRITE_DIR" ]; then
    echo -e "\e[1;31m[ERROR]\e[0m \"$ASEPRITE_DIR\" is not empty."
    echo -e "\e[1;33mPlease ensure there is no directory named \"aseprite\" in \"$LIB\" and try again.\e[0m"
    echo
    echo -e "\e[1;36m[HINT]\e[0m Run this to move the directory to a backup directory at the same location:"
    echo -e "\e[1;36m       mv $ASEPRITE_DIR $ASEPRITE_DIR.bak\e[0m"
    exit 1
fi

# install dependencies
sudo apt-get install -y g++ clang libc++-dev libc++abi-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev unzip

# save current working directory
CURRENT_DIR="$(pwd)"

# create and change to installation directory
mkdir -p "$LIB"
cd "$LIB"

# clone aseprite recursively (include submodules)
git clone --recursive https://github.com/aseprite/aseprite.git
cd aseprite

# download and unzip skia prebuilt for aseprite
curl -LO $(curl -s https://api.github.com/repos/aseprite/skia/releases/latest | grep "tag_name" | awk '{print "https://github.com/aseprite/skia/releases/download/" substr($2, 2, length($2)-3) "/Skia-Linux-Release-x64-libc++.zip"}')
unzip -q "Skia-Linux-Release-x64-libc++.zip" -d "skia"
rm "Skia-Linux-Release-x64-libc++.zip"

# compilation process
mkdir build
cd build
export CC=clang
export CXX=clang++
cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
    -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR=$SKIA_DIR \
    -DSKIA_LIBRARY_DIR=$SKIA_DIR/out/Release-x64 \
    -DSKIA_LIBRARY=$SKIA_DIR/out/Release-x64/libskia.a \
    -G Ninja \
    ..
ninja aseprite

# build complete message and further instructions
echo
echo -e "\e[1;32m[DONE]\e[1;33m Please add \"$ASEPRITE_DIR/build/bin/\" to PATH\e[0m"

# go back to saved working directory
cd "$CURRENT_DIR"
