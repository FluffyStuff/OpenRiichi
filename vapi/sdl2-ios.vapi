//FOR: SDL2.0 - This is not official, to be futurely changed for the official binding
//Maintainer: PedroHLC

namespace SDL {
	///
	/// iOS
	///
	[CCode (cheader="SDL2/SDL_system.h")]
	[Compact]
	public class iPhone  {
		[CCode (cname="SDL_iPhoneSetAnimationCallback")]
		public static int set_animation_callback(SDL.Window window, int interval, void (*callback)(void*), void *callback_param);
		
		[CCode (cname="SDL_iPhoneSetEventPump")]
		public static void set_event_pump(boolean enable);
	}// iPhone
	
	
}