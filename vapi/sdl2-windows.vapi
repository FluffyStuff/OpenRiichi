//FOR: SDL2.0 - This is not official, to be futurely changed for the official binding
//Maintainer: PedroHLC

namespace SDL {
	///
	/// Windows
	///
	[CCode (cname="IDirect3DDevice9", cheader="d3d9.h")]
	[Compact]
	public struct IDirect3DDevice9 {}
	
	[CCode (cheader="SDL2/SDL_system.h")]
	[Compact]
	public class Direct3D9  {
		[CCode (cname="SDL_Direct3D9GetAdapterIndex")]
		public static int get_adapter_index(int display_index);
		
		[CCode (cname="SDL_RenderGetD3D9Device")]
		public static IDirect3DDevice9* get_render_device(SDL.Renderer renderer);
	}// Direct3D9
	
	
}