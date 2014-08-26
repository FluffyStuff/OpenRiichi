VALAC = valac
DIRS  = source/*.vala source/Game/*.vala source/Game/Bot/*.vala source/Game/Interface/*.vala source/Helper/*.vala source/Menu/*.vala
#PKGS  = --thread --target-glib 2.32 --pkg gio-2.0 --pkg glew --pkg gee-1.0 --pkg gl --pkg SDL2-mixer --pkg SDL2-image --pkg SDL2 --pkg soil
PKGS  = --thread --target-glib 2.32 --pkg gio-2.0 --pkg glew --pkg gee-1.0 --pkg gl --pkg sdl2-mixer --pkg sdl2-image --pkg sdl2 --pkg SOIL
LIBS  = -X lib/SOIL/libSOIL.a -X lib/SDL/SDL2_net.lib -X lib/SDL/SDL2_image.lib -X lib/SDL/SDL2_mixer.lib -X lib/SDL/SDL2.lib -X lib/GLEW/glew32s.lib -X lib/GL/libopengl32.a
VAPI  = --vapidir=vapi
O     = -o bin/RiichiMahjong
DEBUG = --save-temps -g -D DEBUG

Linux:
	$(VALAC) -D LINUX --save-temps --pkg glib-2.0 $(DEBUG) $(O) $(DIRS) $(PKGS) $(VAPI) -X /usr/lib/libSOIL.so -X /usr/local/lib/libSDL2_image.a -X /usr/local/lib/libSDL2_mixer.a -X lib/SDL/SDL2.lib -X lib/GLEW/glew32s.lib -X lib/GL/libopengl32.a

cleanLinux:
	rm bin/RiichiMahjong
	rm -r *.c

Debug:
	$(VALAC) $(DEBUG) $(O) $(DIRS) $(PKGS) $(LIBS) $(VAPI)
	-RCEDIT /I bin\RiichiMahjong.exe RiichiMahjong.ico

Release:
	$(VALAC) -X -mwindows $(O) $(DIRS) $(PKGS) $(LIBS) $(VAPI)
	-RCEDIT /I bin\RiichiMahjong.exe RiichiMahjong.ico

	-robocopy bin rsc/archive/RiichiMahjong *.* /MIR
	-robocopy rsc/dlls/main rsc/archive/RiichiMahjong *.*
	-rm rsc/archive RiichiMahjong.rar
	-C:\Program Files\WinRAR\rar a -r0 rsc\archive\RiichiMahjong.rar rsc\archive\RiichiMahjong -ep1

cleanDebug: cleanWindows

cleanRelease: cleanWindows

cleanWindows:
	rm bin RiichiMahjong.exe
	rm source *.c
	rm source/Game *.c
	rm source/Game/Bot *.c
	rm source/Game/Interface *.c
	rm source/Helper *.c
	rm source/Menu *.c
