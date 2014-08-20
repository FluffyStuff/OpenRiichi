Linux:
	valac -D LINUX --save-temps -g --thread --pkg glew --pkg gee-1.0 --pkg gl --pkg sdl2-mixer --pkg sdl2-image --pkg sdl2 *.vala bot/*.vala --pkg SOIL -o bin/RiichiMahjong --vapidir=vapi -X /usr/lib/libSOIL.so -X /usr/local/lib/libSDL2_image.a -X /usr/local/lib/libSDL2_mixer.a -X lib/SDL/SDL2.lib -X lib/GLEW/glew32s.lib -X lib/GL/libopengl32.a

Debug:
	valac -D DEBUG -g --thread --pkg glew --pkg gee-1.0 --pkg gl --pkg SDL2-mixer --pkg SDL2-image --pkg SDL2 *.vala bot/*.vala --pkg soil -o bin\RiichiMahjong --vapidir=vapi -X lib\SOIL\libSOIL.a -X lib\SDL\SDL2_image.lib -X lib\SDL\SDL2_mixer.lib -X lib\SDL\SDL2.lib -X lib\GLEW\glew32s.lib -X lib\GL\libopengl32.a
	RCEDIT /I bin\RiichiMahjong.exe RiichiMahjong.ico

Release:
	valac --thread --pkg glew --pkg gee-1.0 --pkg gl --pkg SDL2-mixer --pkg SDL2-image --pkg SDL2 *.vala bot/*.vala --pkg soil -o bin\RiichiMahjong --vapidir=vapi -X lib\SOIL\libSOIL.a -X lib\SDL\SDL2_image.lib -X lib\SDL\SDL2_mixer.lib -X lib\SDL\SDL2.lib -X lib\GLEW\glew32s.lib -X lib\GL\libopengl32.a -X -mwindows
	RCEDIT /I bin\RiichiMahjong.exe RiichiMahjong.ico

	-robocopy bin rsc/archive/RiichiMahjong *.* /MIR
	-robocopy rsc/dlls/main rsc/archive/RiichiMahjong *.*
	rm rsc/archive RiichiMahjong.rar
	C:\Program Files\WinRAR\rar a -r0 rsc\archive\RiichiMahjong.rar rsc\archive\RiichiMahjong -ep1

cleanDebug:
	rm . bin\RiichiMahjong.exe
	rm . *.c
	rm bot *.c

cleanRelease:
	rm . bin\RiichiMahjong.exe
	rm . *.c
	rm bot *.c
