#!/usr/bin/env bash -e

# set installation directories
APP="$HOME/.local/share/applications"
BIN="$HOME/.local/bin"
LIB="$HOME/.local/lib"
ASEPRITE_DIR="$LIB/aseprite"
SKIA_DIR="$ASEPRITE_DIR/skia"

# fail if installation directory is occupied
if [ -d "$ASEPRITE_DIR" ]; then
    echo -e "\e[1;31m[ERROR]\e[0m \"$ASEPRITE_DIR\" already exists."
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
[ ! -d "$LIB" ] && mkdir -p "$LIB"
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

# symlink the binary to a location on PATH for CLI access
[ ! -d "$BIN" ] && mkdir -p "$BIN"
ln -s "$ASEPRITE_DIR/build/bin/aseprite" "$BIN/aseprite"

# add entry to app menu for GUI access
[ ! -d "$APP" ] && mkdir -p "$APP"
printf "%s\n" > "$APP/aseprite.desktop" \
    "[Desktop Entry]" \
    "Type=Application" \
    "Name=Aseprite" \
    "GenericName=Sprite Editor" \
    "Comment=Animated sprite editor & pixel art tool" \
    "Icon=$ASEPRITE_DIR/build/bin/data/icons/ase.ico" \
    "Categories=Graphics;2DGraphics;RasterGraphics" \
    "Exec=$ASEPRITE_DIR/build/bin/aseprite %U" \
    "TryExec=$ASEPRITE_DIR/build/bin/aseprite" \
    "Terminal=false" \
    "StartupNotify=false" \
    "StartupWMClass=Aseprite" \
    "MimeType=image/bmp;image/gif;image/jpeg;image/png;image/x-pcx;image/x-tga;image/vnd.microsoft.icon;video/x-flic;image/webp;image/x-aseprite;"

# installation complete message
echo
echo -e "\e[1;32m[DONE]\e[1;33m Aseprite is now installed. Enjoy~ :3\e[0m"

# go back to saved working directory
cd "$CURRENT_DIR"
