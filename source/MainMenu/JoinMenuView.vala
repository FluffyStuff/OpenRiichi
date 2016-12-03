using Gee;
using GameServer;

class JoinMenuView : MainMenuSubView
{
    private MenuTextButton join_button;
    private LabelControl info_label;
    private TextInputControl server_text;
    private TextInputControl name_text;
    private bool connecting = false;

    private DelayTimer timer = new DelayTimer();
    private int delay_time = 5;

    //public signal void joined(IGameConnection connection, string name);

    protected override void load()
    {
        int padding = 60;

        info_label = new LabelControl();
        add_child(info_label);
        info_label.font_size = 40;
        info_label.outer_anchor = Vec2(0.5f, 1);
        info_label.inner_anchor = Vec2(0.5f, 1);
        info_label.position = Vec2(0, -(top_offset + padding));

        server_text = new TextInputControl("Hostname", 50);
        add_child(server_text);
        server_text.position = Vec2(0, padding);

        name_text = new TextInputControl("Player name", Environment.MAX_NAME_LENGTH);
        add_child(name_text);
        name_text.position = Vec2(0, -padding);

        name_text.text_changed.connect(name_changed);
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (!connecting)
            return;

        if (timer.active(delta.time))
        {
            info_label.text = "Error: Failed to connect";
            join_button.enabled = true;
            connecting = false;
        }

        if (connection == null)
            return;

        ServerMessage? message;
        while ((message = connection.dequeue_message()) != null)
        {
            ServerMessageAcceptJoin msg = message as ServerMessageAcceptJoin;
            if (msg == null)
                continue;

            if (msg.version_mismatch || !Environment.compatible(msg.version_info))
            {
                connection.disconnected.disconnect(disconnected);
                connection.close();
                connection = null;
                join_button.enabled = true;
                info_label.text = "Error: Version mismatch\n" + "Please get the latest version";
                connecting = false;
                return;
            }

            do_finish();
            break;
        }
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        join_button = new MenuTextButton("MenuButton", "Join");
        join_button.clicked.connect(join_clicked);
        buttons.add(join_button);

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    protected override void load_finished()
    {
        name_changed();
    }

    protected override void set_visibility(bool visible)
    {
        info_label.visible = visible;
    }

    private void name_changed()
    {
        join_button.enabled = !connecting && Environment.is_valid_name(name_text.text);
    }

    private void join_clicked()
    {
        join_button.enabled = false;
        info_label.text = "Connecting...";
        connecting = true;
        timer.set_time(delay_time);

        string host = server_text.text;
        player_name = name_text.text;

        ref();
        Threading.start2(try_join, new Obj<string>(host), new Obj<string>(player_name));
    }

    private void try_join(Object host_obj, Object name_obj)
    {
        string host = ((Obj<string>)host_obj).obj;
        string name = ((Obj<string>)name_obj).obj;

        Connection? con = Networking.join(host, Environment.GAME_PORT);

        if (con == null)
        {
            info_label.text = "Error: Failed to connect";
            join_button.enabled = true;
            connecting = false;
        }
        else
        {
            info_label.text = "Connected";
            connection = new GameNetworkConnection(con);
            //connection.received_message.connect(received_message);
            connection.disconnected.connect(disconnected);
            connection.send_message(new ClientMessageAuthenticate(name, Environment.version_info));
        }

        unref();
    }

    /*private void received_message()
    {
        ServerMessage? message;

        while ((message = connection.dequeue_message()) != null)
        {
            ServerMessageAcceptJoin msg = message as ServerMessageAcceptJoin;
            if (msg == null)
                continue;

            if (msg.version_mismatch || !Environment.compatible(msg.version_info))
            {
                connection.disconnected.disconnect(disconnected);
                connection.close();
                connection = null;
                join_button.enabled = true;
                info_label.text = "Error: Version mismatch\n" + "Please get the latest version";
                connecting = false;
                return;
            }

            ServerMenuView view = new ServerMenuView.join_server(connection, false);
            load_sub_view(view);
            //joined(connection, player_name);
            break;
        }
    }*/

    private void disconnected()
    {
        connection.close();
        connection = null;
        join_button.enabled = true;
        info_label.text = "Error: Connection closed";
        connecting = false;
    }

    protected override string get_name() { return "Join Server"; }
    public IGameConnection? connection { get; private set; }
    public string player_name { get; private set; }
}
