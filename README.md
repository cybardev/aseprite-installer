# Aseprite Installer Script

Shell script to download and build Aseprite from source for \*nix systems

## Dependencies

Check [the dependency list in the official Aseprite documentation][deps].

## Usage

Run the following commands to install Aseprite (replace `bash -e` with `cat` to inspect the script)

```sh
curl -sS "https://aseprite.cybar.dev/install.sh" | bash -e
```

The above command can also be used to update the Aseprite installation as required. Will only work if Aseprite was installed using this script.

## Credits

-   [Aseprite](https://github.com/aseprite/aseprite/)

> [!NOTE]
> The Trial Version of Aseprite for macOS is included here to make Launchpad integration easier. This is in concordance with [Section `2(b)` of the Aseprite EULA][eula], which states that "Evaluation versions available for download from the Licensor's websites may be freely distributed."

[deps]: https://github.com/aseprite/aseprite/blob/102624cad3c433e8c09fe1cae9f8ccfea344a9db/INSTALL.md#dependencies
[eula]: https://github.com/aseprite/aseprite/blob/3e3dd2a653a6741aeaed18cd8327ec7c396d4b7b/EULA.txt#L20
