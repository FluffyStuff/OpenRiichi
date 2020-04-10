using Engine;
using Gee;

class SelectGameLogMenuView : MenuSubView
{
    private GameLogsListControl log_list;
    private MenuTextButton load_button;
    private float padding = 50;

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        load_button = new MenuTextButton("MenuButton", "Load");
        load_button.clicked.connect(load_clicked);
        buttons.add(load_button);

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    protected override void load_finished()
    {
        log_list = new GameLogsListControl();
        log_list.selected_index_changed.connect(button_enable_check);
        add_child(log_list);
        log_list.resize_style = ResizeStyle.ABSOLUTE;
        log_list.inner_anchor = Vec2(0.5f, 1);
        log_list.outer_anchor = Vec2(0.5f, 1);
        log_list.position = Vec2(0, -(top_offset + padding));

        string[] rev = Environment.get_game_log_names();
        string[] logs = new string[rev.length];
        for (int i = 0; i < rev.length; i++)
            logs[i] = rev[rev.length - i - 1];

        log_list.set_log_list(logs);

        button_enable_check();
    }

    protected override void resized()
    {
        log_list.size = Size2(size.width - 2 * padding, size.height - (top_offset + bottom_offset + 2 * padding));
    }

    private void button_enable_check()
    {
        load_button.enabled = log_list.selected_index != -1;
    }

    private void load_clicked()
    {
        string log_name = log_list.logs[log_list.selected_index];
        string name = Environment.game_log_dir + log_name + Environment.log_extension;
        log = Environment.load_game_log(name);

        if (log == null || !Environment.compatible(log.version))
        {
            load_sub_view(new InformationMenuView("Could not load log file \"" + log_name + "\""));
            return;
        }

        do_finish();
    }

    protected override void set_visibility(bool visible)
    {
        log_list.visible = visible;
    }

    protected override string get_name() { return "Select log"; }
    public GameLog? log { get; private set; }
}

public class GameLogsListControl : ListControl
{
    public GameLogsListControl()
    {
        base(true);
        font_size = 40;
        row_height = 45;
    }

    public void set_log_list(string[] logs)
    {
        this.logs = logs;
        refresh_data();
    }

    protected override void added()
    {
        refresh_data();
    }

    protected override string get_cell_data(int row, int column)
    {
        if (logs == null || logs.length == 0)
            return "";

        return logs[row];
    }

    protected override ListColumnInfo get_column_info(int column)
    {
        //if (column == 0)
            return new ListColumnInfo("Log file", new ListCellStyle(ResizeStyle.RELATIVE, 1));
        //else
        //    return new ListColumnInfo("Size", new ListCellStyle(ResizeStyle.ABSOLUTE, 100));
    }

    protected override int row_count
    {
        get
        {
            if (logs == null)
                return 0;
            return logs.length;
        }
    }

    protected override int column_count
    {
        get { return 1; }
    }

    public string[]? logs { get; private set; }
}

/*public class GameLogsListControl : ListControl
{
    public GameLogsListControl()
    {
        base(true);
        font_size = 40;
        row_height = 45;
    }

    public void set_logs(GameLog[] logs)
    {
        this.logs = logs;
        refresh_data();
    }

    protected override void on_added()
    {
        refresh_data();
    }

    protected override string get_cell_data(int row, int column)
    {
        if (logs == null || logs.length == 0)
            return "";

        return logs[row].name;
    }

    protected override ListColumnInfo get_column_info(int column)
    {
        return new ListColumnInfo("Log file", new ListCellStyle(ResizeStyle.RELATIVE, 1));
    }

    protected override int row_count
    {
        get
        {
            if (logs == null)
                return 0;
            return logs.length;
        }
    }

    protected override int column_count
    {
        get { return 1; }
    }

    public GameLog[]? logs { get; private set; }
}*/
