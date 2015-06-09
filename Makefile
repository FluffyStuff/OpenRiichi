VALAC = valac
NAME  = RiichiMahjong
DIRS  = source/*.vala source/Engine/Controls/*.vala source/Engine/Files/*.vala source/Engine/Properties/*.vala source/Engine/Rendering/*.vala source/Game/*.vala source/Game/Rendering/*.vala source/Helper/*.vala source/Engine/Audio/*.vala
#PKGS  = --thread --target-glib 2.32 --pkg gio-2.0 --pkg glew --pkg gee-1.0 --pkg gl --pkg SDL2-mixer --pkg SDL2-image --pkg SDL2 --pkg soil
PKGS  = --thread --target-glib 2.32 --pkg gio-2.0 --pkg glew --pkg gee-1.0 --pkg gl --pkg sdl2-mixer --pkg sdl2-image --pkg sdl2 --pkg SOIL --pkg aubio
LIBS  = -X lib/SOIL/libSOIL.a -X lib/SDL/SDL2_net.lib -X lib/SDL/SDL2_image.lib -X lib/SDL/SDL2_mixer.lib -X lib/SDL/SDL2.lib -X lib/GLEW/glew32s.lib -X lib/GL/libopengl32.a -X lib/AUBIO/libaubio.dll.a -X lib/GEE/libgee.dll.a
VAPI  = --vapidir=vapi
O     = -o bin/$(NAME)
DEBUG = --save-temps -g -D DEBUG

Linux:
#	$(VALAC) -D LINUX --save-temps --pkg glib-2.0 $(DEBUG) $(O) $(DIRS) $(PKGS) $(VAPI) -X /usr/lib/libSOIL.so -X /usr/local/lib/libSDL2_image.a -X /usr/local/lib/libSDL2_mixer.a -X lib/SDL/SDL2.lib -X lib/GLEW/glew32s.lib -X lib/GL/libopengl32.a

	$(VALAC) -D LINUX --save-temps --pkg glib-2.0 $(DEBUG) $(O) $(DIRS) $(PKGS) $(VAPI) -X /usr/lib/libSOIL.so -X /usr/lib/x86_64-linux-gnu/libSDL2_image.so -X /usr/lib/x86_64-linux-gnu/libSDL2_mixer.so -X lib/SDL/SDL2.lib -X lib/GLEW/glew32s.lib -X lib/GL/libopengl32.a --Xcc=-lm

cleanLinux:
	rm bin/$(NAME)
	rm -r *.c

Debug:
	$(eval SHELL = C:/Windows/System32/cmd.exe)
	$(VALAC) $(DEBUG) $(O) $(DIRS) $(PKGS) $(LIBS) $(VAPI)
	-RCEDIT /I bin\$(NAME).exe Icon.ico

Release:
	$(eval SHELL = C:/Windows/System32/cmd.exe)
	$(VALAC) -X -mwindows $(O) $(DIRS) $(PKGS) $(LIBS) $(VAPI)
	-RCEDIT /I bin\$(NAME).exe Icon.ico

	-robocopy bin rsc/archive/$(NAME) *.* /MIR
	-robocopy rsc/dlls/main rsc/archive/$(NAME) *.*
	-rm rsc/archive $(NAME).rar
	-C:\Program Files\WinRAR\rar a -r0 rsc\archive\$(NAME).rar rsc\archive\$(NAME) -ep1

cleanDebug: cleanWindows

cleanRelease: cleanWindows

cleanWindows:
	rm bin $(NAME).exe
	rm source *.c
	rm source/Engine/Audio *.c
	rm source/Engine/Files *.c
	rm source/Engine/Rendering *.c
	rm source/Game *.c
	rm source/Helper *.c
