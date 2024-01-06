# Aseprite Installer Script

Shell script to download and build Aseprite from source for Debian/Ubuntu and derivative systems

## Dependencies

Install required packages using the following command before running the script for the first time:

```sh
sudo apt-get install -y g++ clang libc++-dev libc++abi-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev unzip
```

## Usage

Run the following commands to install Aseprite (replace `bash -e` with `cat` to inspect the script)

```sh
curl -sS "https://aseprite.cybar.dev/install.sh" | bash -e
```

The above command can also be used to update the Aseprite installation as required. Will only work if Aseprite was installed using this script.

## Credits

-   [Aseprite](https://github.com/aseprite/aseprite/)
-   [ellisonoswalt/aseprite_builder](https://github.com/ellisonoswalt/aseprite_builder)
