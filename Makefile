DIRS = \
	source/*.vala \
	source/Game/*.vala \
	source/Game/Logic/*.vala \
	source/Game/Rendering/*.vala \
	source/Game/Rendering/Menu/*.vala \
	source/GameServer/Bots/*.vala \
	source/GameServer/GameState/*.vala \
	source/GameServer/Server/*.vala \
	source/MainMenu/*.vala \
	source/MainMenu/Lobby/*.vala \
	source/Tests/*.vala

ENGINE_PATH = ../Engine
ENGINE_BIN  = $(ENGINE_PATH)/bin

PKGS = \
	--pkg gee-0.8 \
	--pkg gio-2.0 \
	--pkg win32 \
	--pkg libengine \
	-X -L$(ENGINE_BIN) \
	-X -I$(ENGINE_BIN) \
	-X -lengine

VALAC = valac
NAME  = OpenRiichi
OUT   = bin/$(NAME)
VAPI  = --vapidir=vapi --vapidir=$(ENGINE_BIN)
#-w = Supress C warnings (Since they stem from the vala code gen)
OTHER = -X -w -X -Ofast -X -Wl,-rpath,.
O     = -o $(OUT)
DEBUG = -v --save-temps --enable-checking -g -X -ggdb -X -O0 -D DEBUG

all: linuxRelease

engineLinuxDebug:
	$(MAKE) -C $(ENGINE_PATH) linuxDebug
	cp $(ENGINE_BIN)/libengine.so bin

engineLinuxRelease:
	$(MAKE) -C $(ENGINE_PATH) linuxRelease
	cp $(ENGINE_BIN)/libengine.so bin

engineWindowsDebug:
	$(MAKE) -C $(ENGINE_PATH) windowsDebug
	cp $(ENGINE_BIN)/libengine.dll bin

engineWindowsRelease:
	$(MAKE) -C $(ENGINE_PATH) windowsRelease
	cp $(ENGINE_BIN)/libengine.dll bin

linuxDebug: engineLinuxDebug
	$(VALAC) $(O) $(DIRS) $(PKGS) $(VAPI) $(OTHER) $(DEBUG) -D LINUX

linuxRelease: engineLinuxRelease
	$(VALAC) $(O) $(DIRS) $(PKGS) $(VAPI) $(OTHER) -D LINUX

macDebug: engine
	$(VALAC) $(O) $(DIRS) $(PKGS) $(MAC) $(VAPI) $(OTHER) $(DEBUG) -D MAC

macRelease: engine
	$(VALAC) $(O) $(DIRS) $(PKGS) $(MAC) $(VAPI) $(OTHER) -D MAC

windowsDebug: engineWindowsDebug
	$(VALAC) $(O) $(DIRS) $(PKGS) $(WINDOWS) $(VAPI) $(OTHER) $(DEBUG) -D WINDOWS

windowsRelease: engineWindowsRelease
	$(VALAC) $(O) $(DIRS) $(PKGS) $(WINDOWS) $(VAPI) $(OTHER) -D WINDOWS -X -mwindows

clean:
	rm -f $(OUT)* bin/libengine*
	/usr/bin/find . -type f -name '*.c' -exec rm {} +