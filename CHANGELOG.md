# OpenRiichi Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Changelog file.
- Table texture selection option in options menu.
- Feature to persist window state between runs.
- Meson build scripts.
- More verbose debug log

### Changed
- Disabled background music by default.
- Moved Engine project into a subfolder as a git submodule.
- Statically build Engine into executable file.
- Move shaders from GLSL 120 to GLES 100 for better macOS support.

### Fixed
- Compilation and runtime for linux and macOS.
- Game scene lights over/under exposing tiles.

### Removed
- Makefile build scripts.

## [0.2.0.3] - 2020-04-11

### Fixed
- Decision time option being applied by remote server.

## 0.2.0.2 - 2020-04-11 [YANKED]

### Added
- Variable decision time option, between 2 and 120 seconds.

## [0.2.0.1] - 2020-04-11

### Changed
- Revision numbers no longer considered for version compatibility.

### Fixed
- Some broken debug code.

## 0.2.0.0 - 2020-04-10 [YANKED]

### Added
- An animation system for both 3D and 2D scenes.
- A new shader system for auto generating shaders.
- A wrapper framework for 3D scenes, which automates many 3D tasks.

### Changed
- Merged the development branch which contained many bug fixes and impromevents.
- Improved networking and serialization system.
- Split up Engine into its own proper library.
- Rewrite of game scenes and menus.

### Fixed
- Accumulation of many bugs and defects.

## [0.1.3.2] - 2018-03-31

### Fixed
- Yaku calculations with called tiles.

## [0.1.3.1] - 2017-06-11

### Fixed
- Bug which caused slow loading of the main game scene.

## [0.1.3.0] - 2016-12-05

### Added
- Initial release, branched from older project.

[unreleased]: https://github.com/FluffyStuff/OpenRiichi/compare/v0.2.0.3...HEAD
[0.2.0.3]:    https://github.com/FluffyStuff/OpenRiichi/releases/tag/v0.2.0.3
[0.2.0.1]:    https://github.com/FluffyStuff/OpenRiichi/releases/tag/v0.2.0.1
[0.1.3.2]:    https://github.com/FluffyStuff/OpenRiichi/releases/tag/v0.1.3.2
[0.1.3.1]:    https://github.com/FluffyStuff/OpenRiichi/releases/tag/v0.1.3.1
[0.1.3.0]:    https://github.com/FluffyStuff/OpenRiichi/releases/tag/v0.1.3