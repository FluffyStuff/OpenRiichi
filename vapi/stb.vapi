[CCode (cheader_filename="stb_image_aug_c.h")]
namespace stb
{
	public static uchar* load(string filename, out int width, out int height)
	{
		int channels;
		return do_load(filename, out width, out height, out channels, 4);
	}
	
	[CCode (cname="stbi_load")]
	private static uchar* do_load(string filename, out int width, out int height, out int channels, uint flags);
}