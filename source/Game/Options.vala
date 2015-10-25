using Gee;

public class Options
{
    private string dir = FileLoader.get_user_dir() + "options.cfg";

    public Options.default()
    {
        shader_quality = QualityEnum.HIGH;
        model_quality = QualityEnum.HIGH;
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
        case Options.QualityEnum.LOW:
            return "low";
        case Options.QualityEnum.HIGH:
        default:
            return "high";
        }
    }

    public QualityEnum shader_quality { get; set; }
    public QualityEnum model_quality { get; set; }

    public enum QualityEnum
    {
        LOW = 0,
        HIGH = 1
    }
}
