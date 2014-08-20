[CCode (cprefix="SOIL_", cheader_filename="SOIL/SOIL.h")]
namespace SOIL
{	
	[Flags, CCode (/*cname="SOIL_LOAD_",*/ cprefix="SOIL_LOAD_")]
	public enum LoadFlags
	{
		AUTO = 0,
		L = 1,
		LA = 2,
		RGB = 3,
		RGBA = 4
	}
	
	[Flags, CCode (cprefix="SOIL_CREATE_")]
	public enum CreateFlags
	{
		NEW_ID = 0
	}
	
	[CCode (cname="SOIL_load_OGL_texture")]
	public static uint load_OGL_texture(string filename, int force_channels, uint reuse_texture_ID, uint flags);
	
	
	[CCode (cname="SOIL_free_image_data")]
	public static void free_image_data(void *image);
}