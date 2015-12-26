VALAC = valac
NAME  = RiichiMahjong
DIRS  = \
	source/*.vala \
	source/Engine/Audio/*.vala \
	source/Engine/Files/*.vala \
	source/Engine/Helper/*.vala \
	source/Engine/Properties/*.vala \
	source/Engine/Rendering/*.vala \
	source/Engine/Rendering/OpenGLRenderer/*.vala \
	source/Engine/Window/*.vala \
	source/Engine/Window/Controls/*.vala \
	source/Game/*.vala \
	source/Game/Logic/*.vala \
	source/Game/Rendering/*.vala \
	source/Game/Rendering/Menu/*.vala \
	source/GameServer/Bots/*.vala \
	source/GameServer/GameState/*.vala \
	source/GameServer/Server/*.vala \
	source/MainMenu/*.vala \
	source/MainMenu/Lobby/*.vala
PKGS  = --thread --target-glib 2.32 --pkg gio-2.0 --pkg glew --pkg gee-0.8 --pkg gl --pkg sdl2-mixer --pkg sdl2-image --pkg sdl2 --pkg SOIL --pkg aubio --pkg pango --pkg cairo --pkg pangocairo --pkg sfml-audio-2 --pkg sfml-system-2
WLIBS = -X lib/SOIL/libSOIL.a -X lib/SDL/SDL2_net.lib -X lib/SDL/SDL2_image.lib -X lib/SDL/SDL2.lib -X lib/GLEW/libglew32.a -X lib/GL/libopengl32.a -X lib/GEE/libgee.dll.a -X lib/SFML/libcsfml-audio.a -X lib/SFML/libcsfml-system.a
LLIBS = -X /usr/lib/libSOIL.so -X lib/SDL/SDL2.lib -X lib/GLEW/glew32s.lib -X lib/GL/libopengl32.a -X -lm
LL64  = -X /usr/lib/x86_64-linux-gnu/libSDL2_image.so -X /usr/lib/x86_64-linux-gnu/libcsfml-audio.so -X /usr/lib/x86_64-linux-gnu/libcsfml-system.so -X /usr/lib/x86_64-linux-gnu/libsfml-audio.so -X /usr/lib/x86_64-linux-gnu/libsfml-system.so
LL32  = -X /usr/local/lib/libSDL2_image.a -X lib/SFML/linux32/libcsfml-audio.so -X lib/SFML/linux32/libcsfml-system.so
VAPI  = --vapidir=vapi
#-w = Supress C warnings (Since they stem from the vala code gen)
OTHER = -X -w -X -DGLEW_STATIC -X -Iinclude
O     = -o bin/$(NAME)
DEBUG = --save-temps --enable-checking -g

all: debug

debug:
	$(VALAC) $(DEBUG) $(O) $(DIRS) $(PKGS) $(LLIBS) $(LL64) $(VAPI) $(OTHER)

release:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(LLIBS) $(LL64) $(VAPI) $(OTHER)

clean:
	rm bin/$(NAME)
	rm -r *.c

WindowsDebug:
	$(eval SHELL = C:/Windows/System32/cmd.exe)
	$(VALAC) $(DEBUG) $(O) $(DIRS) $(PKGS) $(WLIBS) $(VAPI) $(OTHER)

WindowsRelease:
	$(eval SHELL = C:/Windows/System32/cmd.exe)
	$(VALAC) -X -mwindows $(O) $(DIRS) $(PKGS) $(WLIBS) $(VAPI) $(OTHER)
	-RCEDIT /I bin\$(NAME).exe Icon.ico

	-robocopy bin rsc/archive/$(NAME) *.* /MIR
	-robocopy rsc/dlls/main rsc/archive/$(NAME) *.*
	-rm rsc/archive $(NAME).rar
	-C:\Program Files\WinRAR\rar a -r0 rsc\archive\$(NAME).rar rsc\archive\$(NAME) -ep1

cleanWindowsDebug: cleanWindows

cleanWindowsRelease: cleanWindows

cleanWindows:
	rm bin $(NAME).exe
	rm source *.c
	rm source/Engine/Audio *.c
	rm source/Engine/Files *.c
	rm source/Engine/Helper *.c
	rm source/Engine/Properties *.c
	rm source/Engine/Rendering *.c
	rm source/Engine/Rendering/OpenGLRenderer *.c
	rm source/Engine/Window *.c
	rm source/Engine/Window/Controls *.c
	rm source/Game *.c
	rm source/Game/Logic *.c
	rm source/Game/Rendering *.c
	rm source/Game/Rendering/Menu *.c
	rm source/GameServer *.c
	rm source/GameServer/Bots *.c
	rm source/GameServer/GameState *.c
	rm source/GameServer/Server *.c
	rm source/MainMenu *.c
	rm source/MainMenu/Lobby *.c
