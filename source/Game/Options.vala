using Gee;

public class Options
{
    private string dir = FileLoader.get_user_dir() + "options.cfg";

    public Options.default()
    {
        shader_quality = QualityEnum.HIGH;
        model_quality = QualityEnum.HIGH;
        fullscreen = OnOffEnum.ON;
        anisotropic_filtering = OnOffEnum.ON;
        anti_aliasing = OnOffEnum.ON;
        v_sync = OnOffEnum.OFF;
        music = OnOffEnum.ON;
        sounds = OnOffEnum.ON;
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
            string value = parts[1].strip().down();

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
        options.add("fullscreen = " + on_off_enum_to_string(fullscreen));
        options.add("anisotropic_filtering = " + on_off_enum_to_string(anisotropic_filtering));
        options.add("anti_aliasing = " + on_off_enum_to_string(anti_aliasing));
        options.add("v_sync = " + on_off_enum_to_string(v_sync));
        options.add("music = " + on_off_enum_to_string(music));
        options.add("sounds = " + on_off_enum_to_string(sounds));

        FileLoader.save(dir, options.to_array());
    }

    private void parse_name(string name, string value)
    {
        switch (name)
        {
        case "shader_quality":
            shader_quality = parse_quality_enum(value);
            break;
        case "model_quality":
            model_quality = parse_quality_enum(value);
            break;
        case "fullscreen":
            fullscreen = parse_on_off_enum(value);
            break;
        case "anisotropic_filtering":
            anisotropic_filtering = parse_on_off_enum(value);
            break;
        case "anti_aliasing":
            anti_aliasing = parse_on_off_enum(value);
            break;
        case "v_sync":
            v_sync = parse_on_off_enum(value);
            break;
        case "music":
            music = parse_on_off_enum(value);
            break;
        case "sounds":
            sounds = parse_on_off_enum(value);
            break;
        }
    }

    private static QualityEnum parse_quality_enum(string value)
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

    private static OnOffEnum parse_on_off_enum(string value)
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

    public QualityEnum shader_quality { get; set; }
    public QualityEnum model_quality { get; set; }
    public OnOffEnum fullscreen { get; set; }
    public OnOffEnum anisotropic_filtering { get; set; }
    public OnOffEnum anti_aliasing { get; set; }
    public OnOffEnum v_sync { get; set; }
    public OnOffEnum music { get; set; }
    public OnOffEnum sounds { get; set; }

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
}
