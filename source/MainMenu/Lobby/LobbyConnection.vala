using Gee;
using Lobby;

public class LobbyConnection
{
    public signal void authentication_result(LobbyConnection connection, bool success);
    public signal void lobby_enumeration_result(LobbyConnection connection, bool success);
    public signal void enter_lobby_result(LobbyConnection connection, bool success);
    public signal void enter_game_result(LobbyConnection connection, bool success, int game_ID);
    public signal void create_game_result(LobbyConnection connection, bool success, int game_ID);
    public signal void disconnected(LobbyConnection connection);

    private Connection connection;
    private Mutex mutex = Mutex();

    private LobbyConnection(Connection connection)
    {
        this.connection = connection;
        connection.message_received.connect(received_message);
        connection.closed.connect(on_disconnected);
        tunneled_connection = new TunneledGameConnection();
        tunneled_connection.request_send_message.connect(request_tunnel_send);
        tunneled_connection.request_close.connect(request_tunnel_close);
    }

    ~LobbyConnection()
    {
        tunneled_connection.request_send_message.disconnect(request_tunnel_send);
        tunneled_connection.request_close.disconnect(request_tunnel_close);
        connection.closed.disconnect(on_disconnected);
        connection.message_received.disconnect(received_message);
        connection.close();
    }

    public static LobbyConnection? create(string host, int port)
    {
        Connection? con = Networking.join(host, (uint16)port);

        if (con != null)
        {
            LobbyConnection lobby = new LobbyConnection(con);
            lobby.send_message(new ClientLobbyMessageVersionInfo(Environment.version_info));

            return lobby;
        }

        return null;
    }

    public void get_lobby_information()
    {
        send_message(new ClientLobbyMessageGetLobbies());
    }

    public void authenticate(string username_in)
    {
        // TODO: Unify name check
        string username = username_in.strip();
        if (username.length < 1 || username.length > 20)
            return;

        send_message(new ClientLobbyMessageAuthenticate(username));
    }

    public void enter_lobby(LobbyInformation lobby)
    {
        send_message(new ClientLobbyMessageEnterLobby(lobby.ID));
    }

    public void leave_lobby()
    {
        send_message(new ClientLobbyMessageLeaveLobby());
    }

    public void enter_game(ClientLobbyGame game)
    {
        send_message(new ClientLobbyMessageEnterGame(game.ID));
    }

    public void create_game()
    {
        send_message(new ClientLobbyMessageCreateGame());
    }

    public void leave_game()
    {
        send_message(new ClientLobbyMessageLeaveGame());
    }

    public void disconnect()
    {
        tunneled_connection.request_send_message.disconnect(request_tunnel_send);
        tunneled_connection.request_close.disconnect(request_tunnel_close);
        connection.closed.disconnect(on_disconnected);
        connection.message_received.disconnect(received_message);

        connection.close();
        tunneled_connection.disconnected();
        disconnected(this);
        is_disconnected = true;
    }

    private void request_tunnel_send(TunneledGameConnection connection, ClientMessage message)
    {
        mutex.lock();
        this.connection.send(new Message(message.serialize()));
        mutex.unlock();
    }

    private void request_tunnel_close()
    {
        send_message(new ClientLobbyMessageCloseTunnel());
    }

    private void on_disconnected(Connection connection)
    {
        is_disconnected = true;
        tunneled_connection.disconnected();
        disconnected(this);
    }

    private void received_message(Connection connection, Message msg)
    {
        Serializable? m = Serializable.deserialize(msg.data);

        if (m == null || !(m.get_type().is_a(typeof(ServerLobbyMessage)) || m.get_type().is_a(typeof(ServerMessage))))
        {
            Environment.log(LogType.NETWORK, "LobbyConnection", "Client discarding invalid server lobby message");
            return;
        }

        if (m.get_type().is_a(typeof(ServerMessage)))
        {
            tunneled_connection.do_receive_message(m as ServerMessage);
            return;
        }

        ServerLobbyMessage? message = m as ServerLobbyMessage;

        if (message is ServerLobbyMessageCloseTunnel)
            do_close_tunnel(message as ServerLobbyMessageCloseTunnel);
        else if (message is ServerLobbyMessageVersionMismatch)
            do_version_mismatch(message as ServerLobbyMessageVersionMismatch);
        else if (message is ServerLobbyMessageVersionInfo)
            do_version_info(message as ServerLobbyMessageVersionInfo);
        else if (message is ServerLobbyMessageAuthenticationResult)
            do_authentication_result(message as ServerLobbyMessageAuthenticationResult);
        else if (message is ServerLobbyMessageLobbyEnumerationResult)
            do_lobby_enumeration_result(message as ServerLobbyMessageLobbyEnumerationResult);
        else if (message is ServerLobbyMessageEnterLobbyResult)
            do_enter_lobby_result(message as ServerLobbyMessageEnterLobbyResult);
        else if (message is ServerLobbyMessageEnterGameResult)
            do_enter_game_result(message as ServerLobbyMessageEnterGameResult);
        else if (message is ServerLobbyMessageCreateGameResult)
            do_create_game_result(message as ServerLobbyMessageCreateGameResult);
        else if (message is ServerLobbyMessageUserEnteredLobby)
            do_user_entered_lobbby(message as ServerLobbyMessageUserEnteredLobby);
        else if (message is ServerLobbyMessageUserLeftLobby)
            do_user_left_lobbby(message as ServerLobbyMessageUserLeftLobby);
        else if (message is ServerLobbyMessageGameAdded)
            do_game_added(message as ServerLobbyMessageGameAdded);
        else if (message is ServerLobbyMessageGameRemoved)
            do_game_removed(message as ServerLobbyMessageGameRemoved);
        else if (message is ServerLobbyMessageUserEnteredGame)
            do_user_entered_game(message as ServerLobbyMessageUserEnteredGame);
        else if (message is ServerLobbyMessageUserLeftGame)
            do_user_left_game(message as ServerLobbyMessageUserLeftGame);
    }

    private void do_close_tunnel(ServerLobbyMessageCloseTunnel message)
    {
        tunneled_connection.disconnected();
    }

    private void do_version_mismatch(ServerLobbyMessageVersionMismatch message)
    {
        if (message.disconnecting)
        {
            version_mismatch = true;
            disconnect();
            return;
        }
    }

    private void do_version_info(ServerLobbyMessageVersionInfo message)
    {
        if (!Environment.compatible(message.version_info))
        {
            version_mismatch = true;
            disconnect();
            return;
        }

        server_version = message.version_info;
    }

    private void do_authentication_result(ServerLobbyMessageAuthenticationResult result)
    {
        authentication_result(this, result.success);
    }

    private void do_lobby_enumeration_result(ServerLobbyMessageLobbyEnumerationResult result)
    {
        if (result.success)
            lobbies = result.get_lobbies();
        lobby_enumeration_result(this, result.success);
    }

    private void do_enter_lobby_result(ServerLobbyMessageEnterLobbyResult result)
    {
        current_lobby = new ClientLobby(result.name, result.get_users(), result.get_games());
        enter_lobby_result(this, result.success);
    }

    private void do_enter_game_result(ServerLobbyMessageEnterGameResult result)
    {
        enter_game_result(this, result.success, result.game_ID);
    }

    private void do_create_game_result(ServerLobbyMessageCreateGameResult result)
    {
        create_game_result(this, result.success, result.game_ID);
    }

    private void do_user_entered_lobbby(ServerLobbyMessageUserEnteredLobby message)
    {
        current_lobby.add_user(message.user);
    }

    private void do_user_left_lobbby(ServerLobbyMessageUserLeftLobby message)
    {
        current_lobby.remove_user(message.ID);
    }

    private void do_game_added(ServerLobbyMessageGameAdded message)
    {
        current_lobby.add_game(message.game);
    }

    private void do_game_removed(ServerLobbyMessageGameRemoved message)
    {
        current_lobby.remove_game(message.ID, message.started);
    }

    private void do_user_entered_game(ServerLobbyMessageUserEnteredGame message)
    {
        current_lobby.add_game_user(message.user_ID, message.game_ID);
    }

    private void do_user_left_game(ServerLobbyMessageUserLeftGame message)
    {
        current_lobby.remove_game_user(message.user_ID, message.game_ID);
    }

    private void send_message(ClientLobbyMessage message)
    {
        mutex.lock();
        connection.send(new Message(message.serialize()));
        mutex.unlock();
    }

    public bool is_disconnected { get; private set; }
    public bool version_mismatch { get; private set; }
    public bool authenticated { get; private set; }
    public VersionInfo? server_version { get; private set; }
    public LobbyInformation[]? lobbies { get; private set; }
    public ClientLobby? current_lobby { get; private set; }
    public TunneledGameConnection tunneled_connection { get; private set; }
}

public class ClientLobby
{
    public signal void user_added(ClientLobby lobby, ClientLobbyUser user);
    public signal void user_removed(ClientLobby lobby, ClientLobbyUser user);
    public signal void game_added(ClientLobby lobby, ClientLobbyGame game);
    public signal void game_removed(ClientLobby lobby, ClientLobbyGame game, bool started);
    public signal void user_entered_game(ClientLobby lobby, ClientLobbyUser user, ClientLobbyGame game);
    public signal void user_left_game(ClientLobby lobby, ClientLobbyUser user, ClientLobbyGame game);

    public ClientLobby(string name, LobbyUser[] users, LobbyGame[] games)
    {
        this.name = name;
        this.users = new ArrayList<ClientLobbyUser>();
        this.games = new ArrayList<ClientLobbyGame>();

        foreach (LobbyUser user in users)
            add_user(user);

        foreach (LobbyGame game in games)
            add_game(game);
    }

    public void add_user(LobbyUser u)
    {
        ClientLobbyUser user = new ClientLobbyUser(u.ID, u.name);
        users.add(user);
        user_added(this, user);
    }

    private ClientLobbyUser? get_user_by_ID(int ID)
    {
        // TODO: Binary search
        foreach (ClientLobbyUser user in users)
            if (user.ID == ID)
                return user;
        return null;
    }

    public void remove_user(int ID)
    {
        ClientLobbyUser? user = get_user_by_ID(ID);
        if (user == null)
            return;

        users.remove(user);
        user_removed(this, user);
    }

    public void add_game(LobbyGame g)
    {
        ClientLobbyGame game = new ClientLobbyGame(g.ID);
        foreach (LobbyUser u in g.get_users())
        {
            ClientLobbyUser? user = get_user_by_ID(u.ID);
            if (user == null)
                continue;

            game.add_user(user);
        }

        games.add(game);
        game_added(this, game);
    }

    private ClientLobbyGame? get_game_by_ID(int ID)
    {
        // TODO: Binary search
        foreach (ClientLobbyGame game in games)
            if (game.ID == ID)
                return game;
        return null;
    }

    public void remove_game(int ID, bool started)
    {
        ClientLobbyGame? game = get_game_by_ID(ID);
        if (game == null)
            return;

        games.remove(game);
        game_removed(this, game, started);
    }

    public void add_game_user(int user_ID, int game_ID)
    {
        ClientLobbyGame? game = get_game_by_ID(game_ID);
        ClientLobbyUser? user = get_user_by_ID(user_ID);
        if (game == null || user == null)
            return;

        game.add_user(user);
        user_entered_game(this, user, game);
    }

    public void remove_game_user(int user_ID, int game_ID)
    {
        ClientLobbyGame? game = get_game_by_ID(game_ID);
        ClientLobbyUser? user = get_user_by_ID(user_ID);
        if (game == null || user == null)
            return;

        game.remove_user(user);
        user_left_game(this, user, game);
    }

    public string name { get; private set; }
    public ArrayList<ClientLobbyUser> users { get; private set; }
    public ArrayList<ClientLobbyGame> games { get; private set; }
}

public class ClientLobbyGame
{
    public ClientLobbyGame(int ID)
    {
        this.ID = ID;
        users = new ArrayList<ClientLobbyUser>();
    }

    public void add_user(ClientLobbyUser user)
    {
        users.add(user);
    }

    public void remove_user(ClientLobbyUser user)
    {
        users.remove(user);
    }

    public int ID { get; private set; }
    public ArrayList<ClientLobbyUser> users { get; private set; }
}

public class ClientLobbyUser
{
    public ClientLobbyUser(int ID, string name)
    {
        this.ID = ID;
        this.name = name;
    }

    public int ID { get; private set; }
    public string name { get; private set; }
}
