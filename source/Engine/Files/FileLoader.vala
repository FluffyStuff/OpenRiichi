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
        catch {}

        string[] l = new string[lines.size];
        for (int i = 0; i < lines.size; i++)
            l[i] = lines[i];

        return l;
    }

    public static bool save(string name, string[] lines)
    {
        try
        {
            var file = File.new_for_path(name);

            if (file.query_exists())
                file.delete();
            else
                file.get_parent().make_directory_with_parents();

            FileOutputStream stream = file.create (FileCreateFlags.REPLACE_DESTINATION);

            foreach (string line in lines)
                stream.write((line + "\n").data);

            stream.close();
        }
        catch
        {
            return false;
        }

        return true;
    }

    public static bool exists(string name)
    {
        return File.new_for_path(name).query_exists();
    }

    public static string[] get_files_in_dir(string name)
    {
        ArrayList<string> files = new ArrayList<string>();

        try
        {
            FileEnumerator enumerator = File.new_for_path(name).enumerate_children
            (
                "standard::*",
                FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
                null
            );

            FileInfo info = null;
            while ((info = enumerator.next_file(null)) != null)
            {
                if (info.get_file_type() == FileType.REGULAR)
                    files.add(info.get_name());
            }
        }
        catch {}

        return files.to_array();
    }

    public static string get_user_dir()
    {
        return GLib.Environment.get_user_config_dir() + "/RiichiMahjong/";
    }
}
