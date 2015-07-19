using Gee;

public class FileLoader
{
    private FileLoader() {}

    public static string[]? load(string name)
    {
        var file = File.new_for_path(name);

        if (!file.query_exists())
            return null;

        ArrayList<string> lines = new ArrayList<string>();

        try
        {
            var dis = new DataInputStream(file.read());
            string line;
            while ((line = dis.read_line (null)) != null)
                lines.add(line);
        }
        catch (Error e)
        {
            return null;
        }

        string[] l = new string[lines.size];
        for (int i = 0; i < lines.size; i++)
            l[i] = lines[i];

        return l;
    }

    public static bool exists(string name)
    {
        return File.new_for_path(name).query_exists();
    }

    public static string get_user_dir()
    {
        return GLib.Environment.get_user_config_dir() + "/RiichiMahjong/";
    }
}
