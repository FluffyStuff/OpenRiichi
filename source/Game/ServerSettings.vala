using Gee;
using Engine;

public class ServerSettings : Serializable
{
    private string dir = Environment.get_user_dir() + "server_settings.cfg";

    public ServerSettings.default()
    {
        open_riichi = OnOffEnum.OFF;
        aka_dora = OnOffEnum.ON;
        multiple_ron = OnOffEnum.ON;
        triple_ron_draw = OnOffEnum.ON;
        decision_time = 10;
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

    public new string[] to_string()
    {
        ArrayList<string> settings = new ArrayList<string>();

        settings.add("open_riichi = " + on_off_enum_to_string(open_riichi));
        settings.add("aka_dora = " + on_off_enum_to_string(aka_dora));
        settings.add("multiple_ron = " + on_off_enum_to_string(multiple_ron));
        settings.add("triple_ron_draw = " + on_off_enum_to_string(triple_ron_draw));
        settings.add("decision_time = " + decision_time.to_string());

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
            open_riichi = parse_on_off_enum(value);
            break;
        case "aka_dora":
            aka_dora = parse_on_off_enum(value);
            break;
        case "multiple_ron":
            multiple_ron = parse_on_off_enum(value);
            break;
        case "triple_ron_draw":
            triple_ron_draw = parse_on_off_enum(value);
            break;
        case "decision_time":
            decision_time = int.parse(value).clamp(2, 120);
            break;
        }
    }

    public OnOffEnum open_riichi { get; set; }
    public OnOffEnum aka_dora { get; set; }
    public OnOffEnum multiple_ron { get; set; }
    public OnOffEnum triple_ron_draw { get; set; }
    public int decision_time;
}
