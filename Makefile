DIRS  = \
	../Engine/*.vala \
	../Engine/Audio/*.vala \
	../Engine/Files/*.vala \
	../Engine/Helper/*.vala \
	../Engine/Properties/*.vala \
	../Engine/Rendering/*.vala \
	../Engine/Rendering/OpenGLRenderer/*.vala \
	../Engine/Window/*.vala \
	../Engine/Window/Controls/*.vala \
	source/*.vala \
	source/Game/*.vala \
	source/Game/Logic/*.vala \
	source/Game/Rendering/*.vala \
	source/Game/Rendering/Menu/*.vala \
	source/GameServer/Bots/*.vala \
	source/GameServer/GameState/*.vala \
	source/GameServer/Server/*.vala \
	source/MainMenu/*.vala \
	source/MainMenu/Lobby/*.vala

PKGS  = \
	--thread \
	--target-glib 2.32 \
	--pkg gio-2.0 \
	--pkg glew \
	--pkg gee-0.8 \
	--pkg gl \
	--pkg SDL2_image \
	--pkg sdl2 \
	--pkg stb \
	--pkg pangoft2 \
	--pkg sfml-audio \
	--pkg sfml-system \
	--pkg zlib \
	--pkg win32 \
	-X -lcsfml-audio \
	-X -lcsfml-system \
	-X -Iinclude \
	-X -lm

WINDOWS = \
	-X -lopengl32

MAC = \
	-X -framework -X OpenGL \
	-X -framework -X CoreFoundation

VALAC = valac
NAME  = OpenRiichi
VAPI  = --vapidir=vapi
#-w = Supress C warnings (Since they stem from the vala code gen)
OTHER = -X -w -X -DGLEW_NO_GLU
O     = -o bin/$(NAME)
DEBUG = -v --save-temps --enable-checking -g -X -ggdb -X -O0 -D DEBUG

all: release

debug:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(VAPI) $(OTHER) $(DEBUG) -D LINUX

release:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(VAPI) $(OTHER) -D LINUX

macDebug:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(MAC) $(VAPI) $(OTHER) $(DEBUG) -D MAC

mac:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(MAC) $(VAPI) $(OTHER) -D MAC

winowsDebug:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(WINDOWS) $(VAPI) $(OTHER) $(DEBUG) -D WINDOWS

windows:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(WINDOWS) $(VAPI) $(OTHER) -D WINDOWS -X -mwindows

clean:
	rm bin/$(NAME)*
	find . -type f -name '*.c' -exec rm {} +