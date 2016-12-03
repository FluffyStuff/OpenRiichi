namespace Lobby
{
    public abstract class ClientLobbyMessage : Serializable {}

    public class ClientLobbyMessageCloseTunnel : ClientLobbyMessage {}

    public class ClientLobbyMessageVersionInfo : ClientLobbyMessage
    {
        public ClientLobbyMessageVersionInfo(VersionInfo version_info)
        {
            this.version_info = version_info;
        }

        public VersionInfo version_info { get; protected set; }
    }

    public class ClientLobbyMessageGetLobbies : ClientLobbyMessage {}

    public class ClientLobbyMessageAuthenticate : ClientLobbyMessage
    {
        public ClientLobbyMessageAuthenticate(string username)
        {
            this.username = username;
        }

        public string username { get; protected set; }
    }

    public class ClientLobbyMessageEnterLobby : ClientLobbyMessage
    {
        public ClientLobbyMessageEnterLobby(int ID)
        {
            this.ID = ID;
        }

        public int ID { get; protected set; }
    }

    public class ClientLobbyMessageLeaveLobby : ClientLobbyMessage {}

    public class ClientLobbyMessageEnterGame : ClientLobbyMessage
    {
        public ClientLobbyMessageEnterGame(int ID)
        {
            this.ID = ID;
        }

        public int ID { get; protected set; }
    }

    public class ClientLobbyMessageCreateGame : ClientLobbyMessage {}

    public class ClientLobbyMessageLeaveGame : ClientLobbyMessage {}

    public class ServerLobbyMessage : Serializable {}

    public class ServerLobbyMessageCloseTunnel : ServerLobbyMessage {}

    public class ServerLobbyMessageVersionInfo : ServerLobbyMessage
    {
        public ServerLobbyMessageVersionInfo(VersionInfo version_info)
        {
            this.version_info = version_info;
        }

        public VersionInfo version_info { get; protected set; }
    }

    public class ServerLobbyMessageVersionMismatch : ServerLobbyMessage
    {
        public ServerLobbyMessageVersionMismatch(bool disconnecting)
        {
            this.disconnecting = disconnecting;
        }

        public bool disconnecting { get; protected set; }
    }

    public class ServerLobbyMessageAuthenticationResult : ServerLobbyMessage
    {
        public ServerLobbyMessageAuthenticationResult(bool success, string? message)
        {
            this.success = success;
            this.message = message;
        }

        public bool success { get; protected set; }
        public string? message { get; protected set; }
    }

    public class ServerLobbyMessageLobbyEnumerationResult : ServerLobbyMessage
    {
        public ServerLobbyMessageLobbyEnumerationResult(bool success, LobbyInformation[]? lobbies)
        {
            this.success = success;
            if (lobbies != null)
                lobby_list = new SerializableList<LobbyInformation>(lobbies);
        }

        public LobbyInformation[]? get_lobbies()
        {
            if (lobby_list == null)
                return null;
            return lobby_list.to_array();
        }

        public bool success { get; protected set; }
        protected SerializableList<LobbyInformation>? lobby_list { get; protected set; }
    }

    public class ServerLobbyMessageEnterLobbyResult : ServerLobbyMessage
    {
        public ServerLobbyMessageEnterLobbyResult(bool success, string? name, LobbyUser[]? users, LobbyGame[]? games)
        {
            this.success = success;
            this.name = name;

            if (users != null)
                user_list = new SerializableList<LobbyUser>(users);
            if (games != null)
                game_list = new SerializableList<LobbyGame>(games);
        }

        public LobbyUser[]? get_users()
        {
            if (user_list == null)
                return null;
            return user_list.to_array();
        }

        public LobbyGame[]? get_games()
        {
            if (game_list == null)
                return null;
            return game_list.to_array();
        }

        public bool success { get; protected set; }
        public string? name { get; protected set; }
        protected SerializableList<LobbyUser>? user_list { get; protected set; }
        protected SerializableList<LobbyGame>? game_list { get; protected set; }
    }

    public class ServerLobbyMessageEnterGameResult : ServerLobbyMessage
    {
        public ServerLobbyMessageEnterGameResult(bool success, int game_ID)
        {
            this.success = success;
            this.game_ID = game_ID;
        }

        public bool success { get; protected set; }
        public int game_ID { get; protected set; }
    }

    public class ServerLobbyMessageLeaveGameResult : ServerLobbyMessage
    {
        public ServerLobbyMessageLeaveGameResult(bool success)
        {
            this.success = success;
        }

        public bool success { get; protected set; }
    }

    public class ServerLobbyMessageUserEnteredLobby : ServerLobbyMessage
    {
        public ServerLobbyMessageUserEnteredLobby(LobbyUser user)
        {
            this.user = user;
        }

        public LobbyUser user { get; protected set; }
    }

    public class ServerLobbyMessageUserLeftLobby : ServerLobbyMessage
    {
        public ServerLobbyMessageUserLeftLobby(int ID)
        {
            this.ID = ID;
        }

        public int ID { get; protected set; }
    }

    public class ServerLobbyMessageCreateGameResult : ServerLobbyMessage
    {
        public ServerLobbyMessageCreateGameResult(bool success, int game_ID)
        {
            this.success = success;
            this.game_ID = game_ID;
        }

        public bool success { get; protected set; }
        public int game_ID { get; protected set; }
    }

    public class ServerLobbyMessageGameAdded : ServerLobbyMessage
    {
        public ServerLobbyMessageGameAdded(LobbyGame game)
        {
            this.game = game;
        }

        public LobbyGame game { get; protected set; }
    }

    public class ServerLobbyMessageGameRemoved : ServerLobbyMessage
    {
        public ServerLobbyMessageGameRemoved(int ID, bool started)
        {
            this.ID = ID;
            this.started = started;
        }

        public int ID { get; protected set; }
        public bool started { get; protected set; }
    }

    public class ServerLobbyMessageUserEnteredGame : ServerLobbyMessage
    {
        public ServerLobbyMessageUserEnteredGame(int game_ID, int user_ID)
        {
            this.game_ID = game_ID;
            this.user_ID = user_ID;
        }

        public int game_ID { get; protected set; }
        public int user_ID { get; protected set; }
    }

    public class ServerLobbyMessageUserLeftGame : ServerLobbyMessage
    {
        public ServerLobbyMessageUserLeftGame(int user_ID, int game_ID)
        {
            this.user_ID = user_ID;
            this.game_ID = game_ID;
        }

        public int user_ID { get; protected set; }
        public int game_ID { get; protected set; }
    }

    public class LobbyInformation : Serializable
    {
        public LobbyInformation(int ID, string name, int users)
        {
            this.ID = ID;
            this.name = name;
            this.users = users;
        }

        public int ID { get; protected set; }
        public string name { get; protected set; }
        public int users { get; protected set; }
    }

    public class LobbyUser : Serializable
    {
        public LobbyUser(int ID, string name)
        {
            this.ID = ID;
            this.name = name;
        }

        public int ID { get; protected set; }
        public string name { get; protected set; }
    }

    public class LobbyGame : Serializable
    {
        public LobbyGame(int ID, LobbyUser[] users)
        {
            this.ID = ID;
            user_list = new SerializableList<LobbyUser>(users);
        }

        public LobbyUser[] get_users()
        {
            return user_list.to_array();
        }

        public int ID { get; protected set; }
        protected SerializableList<LobbyUser> user_list { get; protected set; }
    }
}
