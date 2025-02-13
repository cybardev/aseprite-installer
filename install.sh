#!/usr/bin/env bash -e

# set installation directories
APP="$HOME/.local/share/applications"
BIN="$HOME/.local/bin"
LIB="$HOME/.local/lib"
ASEPRITE_DIR="$LIB/aseprite"
ASEPRITE_BIN_DIR="$ASEPRITE_DIR/build/bin"

# save current working directory
CURRENT_DIR="$(pwd)"

# check platform (OS, arch)
cpu=x64
if [[ "$(uname)" == "Linux" ]]; then
    is_linux=1
elif [[ "$(uname)" =~ "Darwin" ]]; then
    is_macos=1
    if [[ "$(uname -m)" == "arm64" ]]; then
        cpu=arm64
    fi
fi

# create and change to installation directory
if [ ! -d "$LIB" ]; then
    mkdir -p "$LIB"
fi
cd "$LIB"

# clone aseprite repository (include submodules) or update it if it exists
if [ -d "$ASEPRITE_DIR" ]; then
    cd aseprite
    if git rev-parse --git-dir > /dev/null 2>&1; then
        UPSTREAM=${1:-'@{u}'}
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse "$UPSTREAM")
        BASE=$(git merge-base @ "$UPSTREAM")

        if [ $LOCAL = $REMOTE ]; then
            echo -e "\n\e[1;36m[INFO]\e[0m Aseprite is already up-to-date. No action necessary."
            cd "$CURRENT_DIR"
            exit 0
        fi
        if [ $LOCAL != $BASE ]; then
            echo -e "\n\e[1;33m[WARNING]\e[0m Repository has diverged from remote origin/main.\n"
            read -p "Reset to origin/main and continue? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git reset --hard HEAD
            else
                echo -e "\n\e[1;36m[INFO]\e[0m Quitting..."
                cd "$CURRENT_DIR"
                exit 1
            fi
        fi
        echo -e "\n\e[1;36m[INFO]\e[0m Updating Aseprite source files...\n"
        git pull
        git submodule update --init --recursive
    else
        echo -e "\n\e[1;31m[ERROR]\e[0m $ASEPRITE_DIR is not a git repository. Move the directory elsewhere and re-run this script to install Aseprite properly."
        cd "$CURRENT_DIR"
        exit 1
    fi
else
    echo -e "\n\e[1;36m[INFO]\e[0m Downloading Aseprite source files...\n"
    git clone --recursive https://github.com/aseprite/aseprite.git aseprite
    cd aseprite
fi

# main build process
echo -e "\n\e[1;36m[INFO]\e[0m Starting build process...\n"
bash build.sh --auto --norun

echo -e "\n\e[1;36m[INFO]\e[0m Integrating Aseprite with the system...\n"

# symlink the binary to a location on PATH for CLI access
if [ -d "$BIN" ]; then
    rm -f "$BIN/aseprite"
else
    mkdir -p "$BIN"
fi
ln -s "$ASEPRITE_BIN_DIR/aseprite" "$BIN/aseprite"

# add entry to app menu for GUI access
if [ $is_linux ]; then
    [ ! -d "$APP" ] && mkdir -p "$APP"
    printf "%s\n" > "$APP/aseprite.desktop" \
        "[Desktop Entry]" \
        "Type=Application" \
        "Name=Aseprite" \
        "GenericName=Sprite Editor" \
        "Comment=Animated sprite editor & pixel art tool" \
        "Icon=$ASEPRITE_BIN_DIR/data/icons/ase.ico" \
        "Categories=Graphics;2DGraphics;RasterGraphics" \
        "Exec=$ASEPRITE_BIN_DIR/aseprite %U" \
        "TryExec=$ASEPRITE_BIN_DIR/aseprite" \
        "Terminal=false" \
        "StartupNotify=false" \
        "StartupWMClass=Aseprite" \
        "MimeType=image/bmp;image/gif;image/jpeg;image/png;image/x-pcx;image/x-tga;image/vnd.microsoft.icon;video/x-flic;image/webp;image/x-aseprite;"
elif [ $is_macos ]; then
    curl -O "https://aseprite.cybar.dev/Aseprite.app"
    cp -fR "$ASEPRITE_BIN_DIR/aseprite" "Aseprite.app/Contents/MacOS/"
    cp -fR "$ASEPRITE_BIN_DIR/data" "Aseprite.app/Contents/Resources/"
    mv "Aseprite.app" "/Applications/"
fi

# installation complete message
echo -e "\e[1;32m[DONE]\e[1;33m Aseprite is now installed. Enjoy~ :3\e[0m"

# go back to saved working directory
cd "$CURRENT_DIR"
