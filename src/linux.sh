#!/usr/bin/env sh

install_deps
install_aseprite
exit 0

# --- script code --- #

install_deps() {
echo "Installing dependencies for compilation..."
echo "Which package manager do you have?"
echo
echo "0) skip (dependencies already installed)"
echo "1) apt"
echo "2) dnf"
echo "3) pacman"
echo "4) none of the above"
echo
echo "q) exit script"
echo
read -n 1 -p "Enter a number: "

case $REPLY in
    q|Q) # exit the script
        exit 0
        ;;
    0) # dependencies installed
        continue
        ;;
    1) # debian
        sudo apt-get install -y g++ clang-10 libc++-10-dev libc++abi-10-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev unzip
        ;;
    2) # fedora
        sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel unzip
        ;;
    3) # arch
        sudo pacman -S gcc clang libc++ cmake ninja libx11 libxcursor mesa-libgl fontconfig unzip
        ;;
    *) # unsupported package manager
        echo "Sorry, we cannot install dependencies using your package manager yet."
        echo "Please install the dependencies and select the appropriate option from the previous menu."
        ;;
esac
}

install_aseprite() {
# aseprite installation directory
ASEPRITE_DIR="$HOME/.local/lib/aseprite"

# compilation process
cd "~/.local/lib/"
git clone --recursive https://github.com/aseprite/aseprite.git
cd aseprite
curl "https://github.com/aseprite/skia/releases/download/latest/Skia-Linux-Release-x64-libc++.zip" | unzip -q
mkdir build
cd build
export CC=clang
export CXX=clang++
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$ASEPRITE_DIR/skia \
  -DSKIA_LIBRARY_DIR=$ASEPRITE_DIR/skia/out/Release-x64 \
  -DSKIA_LIBRARY=$ASEPRITE_DIR/skia/out/Release-x64/libskia.a \
  -G Ninja \
  ..
ninja aseprite

echo "Compilation Done."
echo "Please add '$ASEPRITE_DIR/build/bin/' to PATH"
}
