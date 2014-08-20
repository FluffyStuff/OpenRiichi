/*
The MIT License (MIT)

Copyright (c) <2013> <SDL2.0 vapi>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

//FOR: SDL2.0 - This is not official, to be futurely changed for the official binding
//Maintainer: PedroHLC and Txasatonga

[CCode (cheader_filename="SDL2/SDL_ttf.h")]
namespace SDLTTF {
	[CCode (cname="TTF_Linked_Version")]
	public static unowned SDL.Version linked();

	[CCode (cname="TTF_ByteSwappedUNICODE")]
	public static void byteswap_unicode(int swapped);

	[CCode (cname="TTF_Init")]
	public static int init();

	[CCode (cname="TTF_WasInit")]
	public static int get_initialized();

	[CCode (cname="TTF_Quit")]
	public static void quit();

	[CCode (cname="int", cprefix="TTF_STYLE_")]
	public enum FontStyle {
		NORMAL, BOLD, ITALIC, UNDERLINE
	}// FontStyle

	[CCode (cname="TTF_Font", free_function="TTF_CloseFont")]
	[Compact]
	public class Font {
		[CCode (cname="TTF_OpenFont")]
		public Font(string file, int ptsize);

		[CCode (cname="TTF_OpenFontIndex")]
		public Font.index(string file, int ptsize, long index);

		[CCode (cname="TTF_OpenFontRW")]
		public Font.RW(SDL.RWops src, int freesrc=0, int ptsize);

		[CCode (cname="TTF_OpenFontIndexRW")]
		public Font.RWindex(SDL.RWops src, int freesrc=0, int ptsize, long index);

		[CCode (cname="TTF_GetFontStyle")]
		public FontStyle get_style();

		[CCode (cname="TTF_SetFontStyle")]
		public FontStyle set_style(FontStyle style);

		[CCode (cname="TTF_FontHeight")]
		public int get_height();

		[CCode (cname="TTF_FontAscent")]
		public int get_ascent();

		[CCode (cname="TTF_FontDescent")]
		public int get_descent();

		[CCode (cname="TTF_FontLineSkip")]
		public int get_lineskip();

		[CCode (cname="TTF_FontFaces")]
		public long get_faces();

		[CCode (cname="TTF_FontFaceIsFixedWidth")]
		public int is_fixed_width();

		[CCode (cname="TTF_FontFaceFamilyName")]
		public string get_family();

		[CCode (cname="TTF_FontFaceStyleName")]
		public string get_style_name();

		[CCode (cname="TTF_GlyphMetrics")]
		public int get_metrics(uint16 ch, ref int minx, ref int maxx, 
			ref int miny, ref int maxy, ref int advance);

		[CCode (cname="TTF_SizeText")]
		public int get_size(string text, ref int w, ref int h);

		[CCode (cname="TTF_SizeUTF8")]
		public int get_size_utf8(string text, ref int w, ref int h);

		[CCode (cname="TTF_SizeUNICODE")]
		public int get_size_unicode([CCode (array_length = false)] uint16[] text, ref int w, ref int h);

		[CCode (cname="TTF_RenderText_Solid")]
		public SDL.Surface? render(string text, SDL.Color fg);

		[CCode (cname="TTF_RenderUTF8_Solid")]
		public SDL.Surface? render_utf8(string text, SDL.Color fg);

		[CCode (cname="TTF_RenderUNICODE_Solid")]
		public SDL.Surface? render_unicode([CCode (array_length = false)] uint16[] text, SDL.Color fg);

		[CCode (cname="TTF_RenderText_Shaded")]
		public SDL.Surface? render_shaded(string text, SDL.Color fg, SDL.Color bg);

		[CCode (cname="TTF_RenderUTF8_Shaded")]
		public SDL.Surface? render_shaded_utf8(string text, SDL.Color fg, SDL.Color bg);

		[CCode (cname="TTF_RenderUNICODE_Shaded")]
		public SDL.Surface? render_shaded_unicode([CCode (array_length = false)] uint16[] text, SDL.Color? fg, SDL.Color bg);

		[CCode (cname="TTF_RenderText_Blended")]
		public SDL.Surface? render_blended(string text, SDL.Color fg);

		[CCode (cname="TTF_RenderUTF8_Blended")]
		public SDL.Surface? render_blended_utf8(string text, SDL.Color fg);

		[CCode (cname="TTF_RenderUNICODE_Blended")]
		public SDL.Surface? render_blended_unicode([CCode (array_length = false)] uint16[] text, SDL.Color fg);
		
		[CCode (cname="TTF_RenderText_Blended_Wrapped")]
		public SDL.Surface? render_blended_wrapped(string text, SDL.Color fg, uint32 wrapLength);

		[CCode (cname="TTF_RenderUTF8_Blended_Wrapped")]
		public SDL.Surface? render_blended_wrapped_utf8(string text, SDL.Color fg, uint32 wrapLength);

		[CCode (cname="TTF_RenderUNICODE_Blended_Wrapped")]
		public SDL.Surface? render_blended__wrapped_unicode([CCode (array_length = false)] uint16[] text, SDL.Color fg, uint32 wrapLength);
		
		
	}// Font
}// SDLTTF
