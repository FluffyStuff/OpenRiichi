# OpenRiichi

OpenRiichi is an open source [Japanese Mahjong](https://en.wikipedia.org/wiki/Japanese_Mahjong)
client written in the [Vala](https://wiki.gnome.org/Projects/Vala) programming language.
The client is cross platform, with official builds for Windows, Linux, and MacOS. It supports singleplayer and multiplayer, with or without bots.
It features all the standard riichi rules, as well as some optional ones. It also supports game logging, so games can be viewed again.

Prebuilt binaries can be found in the [release](https://github.com/FluffyStuff/OpenRiichi/releases) section.

<div style="text-align:center">
<img src ="https://raw.githubusercontent.com/FluffyStuff/riichi-data/master/screenshots/screenshot1.png" />
<img src ="https://raw.githubusercontent.com/FluffyStuff/riichi-data/master/screenshots/screenshot5.png" />
</div>

More screenshots can be found [here](https://github.com/FluffyStuff/riichi-data).

## Building

### Windows

The easiest way to build the client on Windows is to use the MSYS2 environment with a MinGW toolchain.

You need to start off by installing [MSYS2](https://msys2.github.io).
Once that is done, open up your MSYS2 shell and run the following commands:

```
pacman --noconfirm -S pacman
pacman --noconfirm -Syu
pacman --noconfirm -S \
git \
make \
mingw32/mingw-w64-i686-vala \
mingw64/mingw-w64-x86_64-vala \
mingw32/mingw-w64-i686-pkg-config \
mingw64/mingw-w64-x86_64-pkg-config \
mingw32/mingw-w64-i686-gcc \
mingw64/mingw-w64-x86_64-gcc \
mingw32/mingw-w64-i686-libgee \
mingw64/mingw-w64-x86_64-libgee \
mingw32/mingw-w64-i686-glew \
mingw64/mingw-w64-x86_64-glew \
mingw32/mingw-w64-i686-SDL2_image \
mingw64/mingw-w64-x86_64-SDL2_image \
mingw32/mingw-w64-i686-pango \
mingw64/mingw-w64-x86_64-pango \
mingw32/mingw-w64-i686-csfml \
mingw64/mingw-w64-x86_64-csfml \
mingw32/mingw-w64-i686-sfml \
mingw64/mingw-w64-x86_64-sfml
git clone https://github.com/FluffyStuff/OpenRiichi.git
git clone https://github.com/FluffyStuff/Engine.git
```

Build by opening up your mingw32 or mingw64 shell, depending on whether you want to compile for 32 or 64 bits, and run:
```cd OpenRiichi && make windows```

### MacOS

On MacOS the client can be built using [Command Line Tools for macOS](https://developer.apple.com/download/more),
[MacPorts](https://www.macports.org/install.php), and [CSFML](http://www.sfml-dev.org/download/csfml).

Start by installing MacPorts and the developer tools. Afterwards extract your CSFML .dylib files into `/usr/local/lib`

Then run the following commands:
```
sudo port selfupdate
sudo port install \
git \
vala \
libgee \
pkgconfig \
libsdl2 \
libsdl2_image \
glew \
pango \
sfml
git clone https://github.com/FluffyStuff/OpenRiichi.git
git clone https://github.com/FluffyStuff/Engine.git
```

Build by running `cd OpenRiichi && make mac`

### Linux (Debian based)

Run the following commands:
```
sudo aptitude install -y
git \
make \
valac \
gcc \
libgee-0.8-dev \
libglew-dev \
libpango1.0-dev \
libsdl2-image-dev \
libsdl2-dev \
libcsfml-dev \
libsfml-dev
git clone https://github.com/FluffyStuff/OpenRiichi.git
git clone https://github.com/FluffyStuff/Engine.git
```

Build by running `cd OpenRiichi && make release`

## License

OpenRiichi is licensed under [GPLv3](https://www.gnu.org/licenses/quick-guide-gplv3.en.html).
Feel free to make any changes and submit a pull request.
