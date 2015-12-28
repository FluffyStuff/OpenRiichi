using Gee;
using GameServer;
using Lobby;

public class LobbyConnectionView : View2D
{
    private LabelControl label;
    private LabelControl message_label;
    private LobbyInformationListControl? lobby_info;
    private LobbyInformation? selected_lobby;
    private LobbyConnection? connection;
    private TextInputControl name_text;
    private MenuTextButton join_button;
    private MenuTextButton back_button;
    private LobbyView lobby_view;
    private bool connecting_finished;
    private bool processed;
    private int padding = 80;

    public signal void start_game(GameStartInfo info, IGameConnection connection, int player_index);
    public signal void back();

    protected override void added()
    {
        label = new LabelControl();
        add_child(label);
        label.text = "Select Lobby";
        label.font_size = 40;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        label.position = Vec2(0, -60);

        message_label = new LabelControl();
        add_child(message_label);
        message_label.text = "Connecting to lobby...";
        message_label.font_size = 50;

        Threading.start2(try_join, new Obj<string>("riichi.fluffy.is"), new Obj<int>(1337));
    }

    private void try_join(Object host_obj, Object port_obj)
    {
        string host = ((Obj<string>)host_obj).obj;
        int port = ((Obj<int>)port_obj).obj;

        connection = LobbyConnection.create(host, port);
        connecting_finished = true;
    }

    protected override void do_process(DeltaArgs time)
    {
        if (!connecting_finished || processed)
            return;
        processed = true;

        if (connection == null)
        {
            MenuTextButton ok_button = new MenuTextButton("MenuButton", "OK");
            add_child(ok_button);
            ok_button.outer_anchor = Vec2(0.5f, 0.5f);
            ok_button.inner_anchor = Vec2(0.5f, 1);
            ok_button.position = Vec2(0, -message_label.size.height / 2 - padding);
            ok_button.clicked.connect(back_clicked);

            message_label.text = "Could not connect to lobby";
        }
        else
        {
            join_button = new MenuTextButton("MenuButton", "Enter Lobby");
            add_child(join_button);
            join_button.outer_anchor = Vec2(0, 0);
            join_button.inner_anchor = Vec2(0, 0);
            join_button.position = Vec2(padding, padding);
            join_button.clicked.connect(enter_clicked);
            join_button.enabled = false;

            back_button = new MenuTextButton("MenuButton", "Back");
            add_child(back_button);
            back_button.outer_anchor = Vec2(1, 0);
            back_button.inner_anchor = Vec2(1, 0);
            back_button.position = Vec2(-padding, padding);
            back_button.clicked.connect(back_clicked);

            name_text = new TextInputControl("Player name");
            add_child(name_text);
            name_text.text_changed.connect(button_enable_check);
            name_text.outer_anchor = Vec2(0, 0);
            name_text.inner_anchor = Vec2(0, 0);
            name_text.position = Vec2(padding + 5, 2 * padding + join_button.size.height);

            message_label.visible = false;

            lobby_info = new LobbyInformationListControl();
            add_child(lobby_info);
            lobby_info.resize_style = ResizeStyle.ABSOLUTE;
            lobby_info.inner_anchor = Vec2(0.5f, 1);
            lobby_info.outer_anchor = Vec2(0.5f, 1);
            lobby_info.position = Vec2(0, -120);
            lobby_info.selected_index_changed.connect(lobby_index_changed);
            resized();

            connection.disconnected.connect(on_disconnected);
            connection.lobby_enumeration_result.connect(lobby_enumeration_result);
            connection.enter_lobby_result.connect(enter_lobby_result);
            connection.get_lobby_information();
        }
    }

    protected override void resized()
    {
        if (lobby_info == null)
            return;

        lobby_info.size = Size2(size.width - 2 * padding, size.height - 450);
    }

    private void lobby_index_changed()
    {
        if (lobby_info.selected_index == -1)
            selected_lobby = null;
        else
            selected_lobby = connection.lobbies[lobby_info.selected_index];

        button_enable_check();
    }

    private void button_enable_check()
    {
        string name = name_text.text.strip();
        join_button.enabled = name.char_count() >= 1 && name.char_count() <= 20 && selected_lobby != null;
    }

    private void enter_clicked()
    {
        connection.authenticate(name_text.text);
        connection.enter_lobby(selected_lobby);
    }

    private void back_clicked()
    {
        back();
    }

    private void on_disconnected()
    {
        back();
    }

    private void lobby_enumeration_result(LobbyConnection connection, bool success)
    {
        if (!success) // Should never happen, something bad must have happened
        {
            back();
            return;
        }

        lobby_info.set_lobbies(connection.lobbies);
    }

    private void enter_lobby_result(LobbyConnection connection, bool success)
    {
        if (!success) // Should never happen, something bad must have happened
        {
            back();
            return;
        }

        label.visible = false;
        lobby_info.visible = false;
        name_text.visible = false;
        join_button.visible = false;
        back_button.visible = false;

        lobby_view = new LobbyView(this.connection);
        add_child(lobby_view);
        lobby_view.start_game.connect(do_start_game);
        lobby_view.back.connect(lobby_back_clicked);
    }

    private void do_start_game(GameStartInfo info, IGameConnection connection, int player_index)
    {
        start_game(info, connection, player_index);
    }

    private void lobby_back_clicked()
    {
        remove_child(lobby_view);
        lobby_view = null;

        connection.leave_lobby();
        connection.get_lobby_information();

        label.visible = true;
        lobby_info.visible = true;
        name_text.visible = true;
        join_button.visible = true;
        back_button.visible = true;
    }
}
