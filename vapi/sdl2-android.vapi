//FOR: SDL2.0 - This is not official, to be futurely changed for the official binding
//Maintainer: PedroHLC

namespace SDL {
	///
	/// Android
	///
	[CCode (cheader="SDL2/SDL_system.h")]
	[Compact]
	public class Android  {
		[CCode (cname="SDL_AndroidGetJNIEnv")]
		public static void* get_jnienv();
		
		[CCode (cname="SDL_AndroidGetActivity")]
		public static void* get_activity();
		
		[CCode (cname="SDL_AndroidGetInternalStoragePath")]
		public static string get_internal_storage_path();
		
		[CCode (cname="SDL_AndroidGetExternalStorageState")]
		public static string get_external_storage_path();
		
		[CCode (cname="SDL_AndroidGetExternalStorageState")]
		public static int get_external_storage_state();
		
		[CCode (cname="SDL_ANDROID_EXTERNAL_STORAGE_READ")]
		public static const int EXTERNAL_STORAGE_READ;
		
		[CCode (cname="SDL_ANDROID_EXTERNAL_STORAGE_WRITE")]
		public static const int EXTERNAL_STORAGE_WRITE;
	}// Android
	
	
}