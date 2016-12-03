using Gee;

public class ServerSettings : Serializable
{
    private string dir = Environment.get_user_dir() + "server_settings.cfg";

    public ServerSettings.default()
    {
        open_riichi = Options.OnOffEnum.OFF;
        aka_dora = Options.OnOffEnum.ON;
        multiple_ron = Options.OnOffEnum.ON;
        triple_ron_draw = Options.OnOffEnum.ON;
    }

    public ServerSettings.from_disk()
    {
        this.default();
        load_disk();
    }

    public ServerSettings.from_string(string settings)
    {
        load_string(settings);
    }

    public ServerSettings.from_settings(ServerSettings settings)
    {
        load_from_string(settings.to_string());
    }

    public void load_disk()
    {
        string[] settings = FileLoader.load(dir);
        load_from_string(settings);
    }

    public void load_string(string settings)
    {
        string[] s = FileLoader.load(dir);
        load_from_string(s);
    }

    private void load_from_string(string[] settings)
    {
        foreach (string setting in settings)
        {
            string[] parts = setting.split("=", 2);

            if (parts.length < 2)
                continue;

            string name = parts[0].strip().down();
            string value = parts[1].strip().down();

            if (name == "" || value == "")
                continue;

            parse_name(name, value);
        }
    }

    public string[] to_string()
    {
        ArrayList<string> settings = new ArrayList<string>();

        settings.add("open_riichi = " + Options.on_off_enum_to_string(open_riichi));
        settings.add("aka_dora = " + Options.on_off_enum_to_string(aka_dora));
        settings.add("multiple_ron = " + Options.on_off_enum_to_string(multiple_ron));
        settings.add("triple_ron_draw = " + Options.on_off_enum_to_string(triple_ron_draw));

        return settings.to_array();
    }

    public void save()
    {
        string[] settings = to_string();
        FileLoader.save(dir, settings);
    }

    private void parse_name(string name, string value)
    {
        switch (name)
        {
        case "open_riichi":
            open_riichi = Options.parse_on_off_enum(value);
            break;
        case "aka_dora":
            aka_dora = Options.parse_on_off_enum(value);
            break;
        case "multiple_ron":
            multiple_ron = Options.parse_on_off_enum(value);
            break;
        case "triple_ron_draw":
            triple_ron_draw = Options.parse_on_off_enum(value);
            break;
        }
    }

    public Options.OnOffEnum open_riichi { get; set; }
    public Options.OnOffEnum aka_dora { get; set; }
    public Options.OnOffEnum multiple_ron { get; set; }
    public Options.OnOffEnum triple_ron_draw { get; set; }
}
