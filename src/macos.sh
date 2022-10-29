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
    PLATFORM=$(get_platform)
    cd "~/.local/lib/"
    git clone --recursive https://github.com/aseprite/aseprite.git
    cd aseprite
    curl -LO $(curl -s https://api.github.com/repos/aseprite/skia/releases/latest | grep "tag_name" | awk '{print "https://github.com/aseprite/skia/releases/download/" substr($2, 2, length($2)-3) "/Skia-macOS-Release-$PLATFORM.zip"}')
    unzip -q "Skia-macOS-Release-$PLATFORM.zip" -d "skia"
    rm "Skia-macOS-Release-$PLATFORM.zip"
    mkdir build
    cd build
    cmake_platform $PLATFORM
    ninja aseprite

    echo "Compilation Done."
    echo "Please add '$ASEPRITE_DIR/build/bin/' to PATH"
}

get_platform() {
    echo "Which CPU do you have?"
    echo
    echo "1) Apple Silicon (arm64)"
    echo "2) Intel         (x86_64)"
    echo
    read -n 1 -p "Enter a number: "
    case $REPLY in
    1)
        return "arm64"
        ;;
    2)
        return "x64"
        ;;
    *) # invalid option
        echo "Unrecognized option. Please try again."
        get_platform
        ;;
    esac
}

cmake_platform() {
    case $1 in
    arm64)
        ARCH="arm64"
        EXTRA="-DPNG_ARM_NEON:STRING=on"
        ;;
    x64)
        ARCH="x86_64"
        EXTRA=""
        ;;
    esac
    cmake \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DCMAKE_OSX_ARCHITECTURES=$ARCH \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
        -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
        -DLAF_BACKEND=skia \
        -DSKIA_DIR=$HOME/deps/skia \
        -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-$1 \
        -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-$1/libskia.a \
        $EXTRA \
        -G Ninja \
        ..
}
