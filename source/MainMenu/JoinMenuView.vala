using GameServer;

public class JoinMenuView : View2D
{
    private IGameConnection? connection;
    private GameMenuButton join_button;
    private GameMenuButton back_button;
    private TextInputView server_text;
    private TextInputView name_text;
    private string name;

    public signal void joined(IGameConnection connection, string name);
    public signal void back();

    public JoinMenuView()
    {
    }

    protected override void added()
    {
        LabelControl label = new LabelControl(store);
        label.text = "Join Server";
        label.font_size = 40;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        add_control(label);

        int padding = 50;

        server_text = new TextInputView(store, "Hostname");
        server_text.position = Vec2(0, padding);
        add_control(server_text);

        name_text = new TextInputView(store, "Player name");
        name_text.position = Vec2(0, -padding);
        name_text.text_changed.connect(name_changed);
        add_control(name_text);

        join_button = new GameMenuButton(store, "Join");
        join_button.outer_anchor = Vec2(0.5f, 0);
        join_button.inner_anchor = Vec2(1, 0);
        join_button.position = Vec2(-padding, padding);
        join_button.clicked.connect(join_clicked);
        join_button.enabled = false;
        add_control(join_button);

        back_button = new GameMenuButton(store, "Back");
        back_button.outer_anchor = Vec2(0.5f, 0);
        back_button.inner_anchor = Vec2(0, 0);
        back_button.position = Vec2(padding, padding);
        back_button.clicked.connect(back_clicked);
        add_control(back_button);
    }

    private void name_changed()
    {
        string name = name_text.text.strip();
        join_button.enabled = (name.char_count() > 0 && name.char_count() < 20);
    }

    private void join_clicked()
    {
        join_button.enabled = false;
        back_button.enabled = false;

        string host = server_text.text;
        name = name_text.text;

        Threading.start2(try_join, new Obj<string>(host), new Obj<string>(name));
    }

    private void try_join(Object host_obj, Object name_obj)
    {
        string host = ((Obj<string>)host_obj).obj;
        string name = ((Obj<string>)name_obj).obj;

        Connection? con = Networking.join(host, 1337);

        if (con == null)
        {
            join_button.enabled = true;
            back_button.enabled = true;
        }
        else
        {
            connection = new GameNetworkConnection(con);
            connection.received_message.connect(received_message);
            connection.send_message(new ClientMessageAuthenticate(name));
        }
    }

    private void received_message()
    {
        ServerMessage? message;

        while ((message = connection.dequeue_message()) != null)
        {
            ServerMessageAcceptJoin msg = message as ServerMessageAcceptJoin;
            if (msg == null)
                continue;

            joined(connection, name);
            break;
        }
    }

    private void back_clicked()
    {
        back();
    }
}
