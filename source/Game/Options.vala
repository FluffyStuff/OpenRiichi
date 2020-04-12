using Gee;
using Engine;

public class Options
{
    private string dir = Environment.get_user_dir() + "options.cfg";

    public Options.default()
    {
        shader_quality = QualityEnum.HIGH;
        model_quality = QualityEnum.HIGH;
        screen_type = ScreenTypeEnum.WINDOWED;
        anisotropic_filtering = OnOffEnum.ON;
        anti_aliasing = OnOffEnum.ON;
        v_sync = OnOffEnum.OFF;
        music = OnOffEnum.ON;
        sounds = OnOffEnum.ON;
        tile_fore_color = Color.white();
        tile_back_color = Color(0, 0.5f, 1, 1);
        tile_textures = TileTextureEnum.REGULAR;
        window_width = 1280;
        window_height = 720;
        window_x = -1;
        window_y = -1;
    }

    public Options.from_disk()
    {
        this.default();
        load();
    }

    public void load()
    {
        string[] options = FileLoader.load(dir);

        foreach (string option in options)
        {
            string[] parts = option.split("=", 2);

            if (parts.length < 2)
                continue;

            string name = parts[0].strip().down();
            string value = parts[1].strip();

            if (name == "" || value == "")
                continue;

            parse_name(name, value);
        }
    }

    public void save()
    {
        ArrayList<string> options = new ArrayList<string>();

        options.add("shader_quality = " + quality_enum_to_string(shader_quality));
        options.add("model_quality = " + quality_enum_to_string(model_quality));
        options.add("screen_type = " + screentype_enum_to_string(screen_type));
        options.add("anisotropic_filtering = " + on_off_enum_to_string(anisotropic_filtering));
        options.add("anti_aliasing = " + on_off_enum_to_string(anti_aliasing));
        options.add("v_sync = " + on_off_enum_to_string(v_sync));
        options.add("music = " + on_off_enum_to_string(music));
        options.add("sounds = " + on_off_enum_to_string(sounds));
        options.add("tile_fore_color = " + color_to_string(tile_fore_color));
        options.add("tile_back_color = " + color_to_string(tile_back_color));
        options.add("tile_textures = " + tile_texture_enum_to_string(tile_textures));
        options.add("window_width = " + window_width.to_string());
        options.add("window_height = " + window_height.to_string());
        options.add("window_x = " + window_x.to_string());
        options.add("window_y = " + window_y.to_string());

        FileLoader.save(dir, options.to_array());
    }

    private void parse_name(string name, string value)
    {
        string down_value = value.down();

        switch (name)
        {
        case "shader_quality":
            shader_quality = parse_quality_enum(down_value);
            break;
        case "model_quality":
            model_quality = parse_quality_enum(down_value);
            break;
        case "screen_type":
            screen_type = parse_screen_type_enum(down_value);
            break;
        case "anisotropic_filtering":
            anisotropic_filtering = parse_on_off_enum(down_value);
            break;
        case "anti_aliasing":
            anti_aliasing = parse_on_off_enum(down_value);
            break;
        case "v_sync":
            v_sync = parse_on_off_enum(down_value);
            break;
        case "music":
            music = parse_on_off_enum(down_value);
            break;
        case "sounds":
            sounds = parse_on_off_enum(down_value);
            break;
        case "tile_fore_color":
            tile_fore_color = parse_color(down_value);
            break;
        case "tile_back_color":
            tile_back_color = parse_color(down_value);
            break;
        case "tile_textures":
            tile_textures = parse_tile_texture_enum(down_value);
            break;
        case "window_width":
            window_width = int.parse(down_value);
            break;
        case "window_height":
            window_height = int.parse(down_value);
            break;
        case "window_x":
            window_x = int.parse(down_value);
            break;
        case "window_y":
            window_y = int.parse(down_value);
            break;
        }
    }

    public QualityEnum shader_quality { get; set; }
    public QualityEnum model_quality { get; set; }
    public ScreenTypeEnum screen_type { get; set; }
    public OnOffEnum anisotropic_filtering { get; set; }
    public OnOffEnum anti_aliasing { get; set; }
    public OnOffEnum v_sync { get; set; }
    public OnOffEnum music { get; set; }
    public OnOffEnum sounds { get; set; }
    public Color tile_fore_color { get; set; }
    public Color tile_back_color { get; set; }
    public TileTextureEnum tile_textures { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int window_x { get; set; }
    public int window_y { get; set; }
}

public static ScreenTypeEnum parse_screen_type_enum(string value)
{
    switch (value)
    {
    case "fullscreen":
        return ScreenTypeEnum.FULLSCREEN;
    case "maximized":
        return ScreenTypeEnum.MAXIMIZED;
    case "windowed":
    default:
        return ScreenTypeEnum.WINDOWED;
    }
}

public static QualityEnum parse_quality_enum(string value)
{
    switch (value)
    {
    case "low":
        return QualityEnum.LOW;
    case "high":
    default:
        return QualityEnum.HIGH;
    }
}

public static string screentype_enum_to_string(ScreenTypeEnum screen_type)
{
    switch (screen_type)
    {
    case ScreenTypeEnum.FULLSCREEN:
        return "fullscreen";
    case ScreenTypeEnum.MAXIMIZED:
        return "maximized";
    case ScreenTypeEnum.WINDOWED:
    default:
        return "windowed";
    }
}

public static string quality_enum_to_string(QualityEnum quality)
{
    switch (quality)
    {
    case QualityEnum.LOW:
        return "low";
    case QualityEnum.HIGH:
    default:
        return "high";
    }
}

public static TileTextureEnum parse_tile_texture_enum(string value)
{
    switch (value)
    {
    default:
    case "regular":
        return TileTextureEnum.REGULAR;
    case "black":
        return TileTextureEnum.BLACK;
    }
}

public static string tile_texture_enum_to_string(TileTextureEnum texture)
{
    switch (texture)
    {
    default:
    case TileTextureEnum.REGULAR:
        return "regular";
    case TileTextureEnum.BLACK:
        return "black";
    }
}

public static OnOffEnum parse_on_off_enum(string value)
{
    switch (value)
    {
    case "off":
        return OnOffEnum.OFF;
    case "on":
    default:
        return OnOffEnum.ON;
    }
}

public static string on_off_enum_to_string(OnOffEnum on_off)
{
    switch (on_off)
    {
    case OnOffEnum.OFF:
        return "off";
    case OnOffEnum.ON:
    default:
        return "on";
    }
}

public static Color parse_color(string value)
{
    int64 v;
    if (!int64.try_parse(value, out v))
        v = 16777215;
    return Color((float)(v / 65536) / 255, (float)((v / 256) % 256) / 255, (float)(v % 256) / 255, 1);
}

public static string color_to_string(Color color)
{
    return ((int)(color.r * 255) * 65536 + (int)(color.g * 255) * 256 + (int)(color.b * 255)).to_string();
}

public enum QualityEnum
{
    LOW = 0,
    HIGH = 1
}

public enum OnOffEnum
{
    OFF = 0,
    ON = 1
}

public enum TileTextureEnum
{
    REGULAR,
    BLACK
}
