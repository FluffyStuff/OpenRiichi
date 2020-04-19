# OpenRiichi

OpenRiichi is an open source [Japanese Mahjong](https://en.wikipedia.org/wiki/Japanese_Mahjong)
client written in the [Vala](https://wiki.gnome.org/Projects/Vala) programming language.
The client is cross platform, with official builds for Windows, Linux, and MacOS. It supports singleplayer and multiplayer, with or without bots.
It features all the standard riichi rules, as well as some optional ones. It also supports game logging, so games can be viewed again.

Prebuilt binaries for windows can be found in the [release](https://github.com/FluffyStuff/OpenRiichi/releases) section.

<div style="text-align:center">
<img src ="https://raw.githubusercontent.com/FluffyStuff/riichi-data/master/screenshots/screenshot1.png" />
<img src ="https://raw.githubusercontent.com/FluffyStuff/riichi-data/master/screenshots/screenshot5.png" />
</div>

More screenshots can be found [here](https://github.com/FluffyStuff/riichi-data).

# Building

## Setup

### Windows

The easiest way to build the client on Windows is to use the MSYS2 environment with a MinGW toolchain.

You need to start off by installing [MSYS2](https://msys2.github.io).
Once that is done, open up your MSYS2-mingw64 shell and run the following commands:

```
pacman --noconfirm -S pacman
pacman --noconfirm -Syu
pacman --noconfirm -S \
git \
mingw64/mingw-w64-x86_64-vala \
mingw64/mingw-w64-x86_64-pkg-config \
mingw64/mingw-w64-x86_64-gcc \
mingw64/mingw-w64-x86_64-meson \
mingw64/mingw-w64-x86_64-libgee \
mingw64/mingw-w64-x86_64-gtk3 \
mingw64/mingw-w64-x86_64-glew \
mingw64/mingw-w64-x86_64-SDL2_image \
mingw64/mingw-w64-x86_64-pango \
mingw64/mingw-w64-x86_64-csfml \
mingw64/mingw-w64-x86_64-sfml
```

### MacOS

On MacOS the client can be built using [Command Line Tools for macOS](https://developer.apple.com/download/more),
[MacPorts](https://www.macports.org/install.php), [SFML](https://www.sfml-dev.org/files/SFML-2.4.2-osx-clang.tar.gz) and [CSFML](https://www.sfml-dev.org/files/CSFML-2.4-osx-clang.tar.gz).

Start by installing MacPorts and the developer tools. Afterwards extract your SFML and CSFML .dylib files into `/usr/local/lib`

Then run the following commands:
```
sudo port selfupdate
sudo port install \
git \
vala \
pkgconfig \
meson \
libgee \
gtk3 \
libsdl2 \
libsdl2_image \
glew \
pango \
sfml
```

### Linux (Debian based)

Run the following commands:
```
sudo aptitude install -y
git \
valac \
gcc \
meson \
libgee-0.8-dev \
libgtk-3-dev \
libglew-dev \
libpango1.0-dev \
libsdl2-image-dev \
libsdl2-dev \
libcsfml-dev \
libsfml-dev
```

## Build

Start by cloning the OpenRiichi repository with: ```git clone --recurse-submodules https://github.com/FluffyStuff/OpenRiichi.git```

Next, generate a build target with meson using `meson bin -Dbuildtype=release` or `meson bin -Dbuildtype=debug` depending on whether you want a release or debug build.

Build the target with ninja using: `ninja -C bin`

If the build succeeded, you should be able to launch the application from inside the `bin` directory.
If you prefer to use a different directory for building, be sure to copy the `Data` folder from the `bin` folder into the directory where the built `OpenRiichi` executable resides.

## IDE

The preferred editor to use is [Visual Studio Code](https://code.visualstudio.com).
It works on all operating systems which are supported for OpenRiichi, and has several extensions for Vala in the Visual Studio Marketplace.

### Windows

Setting up building and debugging for VSCode in windows requires a few tweaks. 

First we need to add these MSYS2 directories to our `path` environment variable (in case of the default MSYS2 install path): `C:\msys64\usr\bin` and `C:\msys64\mingw64\bin`

Create or edit your `tasks.json` file and add the following build command:
```
{
    "version": "2.0.0",
    "command": "bash",
    "args": [
        "-l",
        "-c",
        "ninja -C bin"
    ],
    "problemMatchers": [
        "$valac"
    ],
    "group": {
        "kind": "build",
        "isDefault": true
    }
}
```

This should allow you to run incremental builds from within VSCode.

For debugging you will need a MinGW-w64 version of GDB. A release package can be found [here](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds). Go to the latest release folder and download the `x64_64-posix-seh` package. Extract the containing `mingw64` folder to a location of your choice.

Your `launch.json` should look like the following:
```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceRoot}/bin/OpenRiichi.exe",
            "cwd": "${workspaceFolder}/bin",
            "MIMode": "gdb",
            "miDebuggerPath": "path_to_your_mingw64/bin/gdb.exe",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": false
                }
            ]
        }
    ]
}
```

Where you should replace `path_to_your_mingw64` with the path to the `mingw64` folder you extracted earlier. You should now be able to debug the application with features such as breakpoints, callstacks, threads, and, variable inspection.

# License

OpenRiichi is licensed under [GPLv3](https://www.gnu.org/licenses/quick-guide-gplv3.en.html).
Feel free to make any changes and submit a pull request.
