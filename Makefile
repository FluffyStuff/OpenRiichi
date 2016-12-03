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

all: debug

debug:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(VAPI) $(OTHER) $(DEBUG) -D LINUX

release:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(VAPI) $(OTHER) -D LINUX

macDebug:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(MAC) $(VAPI) $(OTHER) $(DEBUG) -D MAC

macRelease:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(MAC) $(VAPI) $(OTHER) -D MAC
	-mkdir rsc/archive/$(NAME).app
	-cp bin/$(NAME) rsc/archive/$(NAME).app/
	-cp -r bin/Data rsc/archive/$(NAME).app/
	-cp Icon.icns rsc/archive/$(NAME).app/
	-cp rsc/other/Info.plist rsc/archive/$(NAME).app/
	-zip -r rsc/archive/$(NAME).mac.zip rsc/archive/$(NAME).app

clean:
	rm bin/$(NAME)
	find . -type f -name '*.c' -exec rm {} +

WindowsDebug:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(WINDOWS) $(VAPI) $(OTHER) $(DEBUG)

WindowsRelease:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(WINDOWS) $(VAPI) $(OTHER) -D WINDOWS -X -mwindows
	-RCEDIT /I bin\$(NAME).exe Icon.ico

	-robocopy bin rsc/archive/$(NAME) *.* /MIR
	-robocopy rsc/dlls/main rsc/archive/$(NAME) *.*
	-rm rsc/archive $(NAME).rar
	-C:\Program Files\WinRAR\rar a -r0 rsc\archive\$(NAME).rar rsc\archive\$(NAME) -ep1

cleanWindowsDebug: cleanWindows

cleanWindowsRelease: cleanWindows

cleanWindows:
	rm bin $(NAME).exe
	rm ../Engine/Audio *.c
	rm ../Engine/Files *.c
	rm ../Engine/Helper *.c
	rm ../Engine/Properties *.c
	rm ../Engine/Rendering *.c
	rm ../Engine/Rendering/OpenGLRenderer *.c
	rm ../Engine/Window *.c
	rm ../Engine/Window/Controls *.c
	rm source *.c
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
