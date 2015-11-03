using Cairo;
using GLib;
using Pango;

public class LabelLoader
{
    private static Mutex mutex = Mutex();

    private const int PANGO_SCALE = 64 * 16;

    public LabelLoader()
    {

    }

    public LabelInfo get_label_info(string font_type, float font_size, string text)
    {
        return get_label_info_static(font_type, font_size, text);
    }

    public LabelBitmap generate_label_bitmap(string font_type, float font_size, string text)
    {
        return generate_label_bitmap_static(font_type, font_size, text);
    }

    public static LabelInfo get_label_info_static(string font_type, float font_size, string text)
    {
        font_size = font_size / 1.6f;
        return get_text_size(text, font_type + " " + font_size.to_string());
    }

    public static LabelBitmap generate_label_bitmap_static(string font_type, float font_size, string text)
    {
        font_size = font_size / 1.6f;
        return render_text(text, font_type + " " + font_size.to_string());
    }

    private static LabelInfo get_text_size(string text, string font)
    {
        mutex.lock();

        Cairo.ImageSurface temp_surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 0, 0);
        Cairo.Context layout_context = new Cairo.Context(temp_surface);

        // Create a PangoLayout, set the font and text
        Layout layout = Pango.cairo_create_layout(layout_context);
        layout.set_text(text, -1);

        // Load the font
        Pango.FontDescription desc = Pango.FontDescription.from_string(font);
        layout.set_font_description(desc);

        // Get text dimensions and create a context to render to
        int text_width, text_height;
        layout.get_size(out text_width, out text_height);
        text_width /= PANGO_SCALE;
        text_height /= PANGO_SCALE;

        mutex.unlock();

        return new LabelInfo(Size2i(text_width, text_height));
    }

    private static LabelBitmap render_text(string text, string font)
    {
        mutex.lock();

        Cairo.ImageSurface temp_surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 0, 0);
        Cairo.Context layout_context = new Cairo.Context(temp_surface);

        // Create a PangoLayout, set the font and text
        Layout layout = Pango.cairo_create_layout(layout_context);
        layout.set_text(text, -1);

        // Load the font
        Pango.FontDescription desc = Pango.FontDescription.from_string(font);
        layout.set_font_description(desc);

        // Get text dimensions and create a context to render to
        int text_width, text_height, channels = 4;
        layout.get_size(out text_width, out text_height);
        text_width /= PANGO_SCALE;
        text_height /= PANGO_SCALE;

        uchar[] surface_data = new uchar[channels * text_width * text_height];
        Cairo.ImageSurface surface = new Cairo.ImageSurface.for_data(surface_data, Cairo.Format.ARGB32, text_width, text_height, channels * text_width);
        Cairo.Context render_context = new Cairo.Context(surface);

        // Render
        render_context.set_source_rgba(1, 1, 1, 1);
        cairo_show_layout(render_context, layout);

        LabelBitmap bitmap = new LabelBitmap(surface_data, Size2i(text_width, text_height));

        mutex.unlock();

        return bitmap;
    }
}

public class LabelInfo
{
    public LabelInfo(Size2i size)
    {
        this.size = size;
    }

    public Size2i size { get; private set; }
}

public class LabelBitmap
{
    public LabelBitmap(uchar[] data, Size2i size)
    {
        this.data = data;
        this.size = size;
    }

    public uchar[] data { get; private set; }
    public Size2i size { get; private set; }
}
