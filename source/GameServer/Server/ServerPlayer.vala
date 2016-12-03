namespace GameServer
{
    public abstract class ServerPlayer : Object
    {
        public ServerPlayer(string name, bool bot)
        {
            this.name = name;
            this.bot = bot;
        }

        public signal void disconnected(ServerPlayer player);
        public signal void receive_message(ServerPlayer player, ClientMessage message);

        public virtual void send_message(ServerMessage message) {}
        public abstract void close();

        public State state { get; protected set; }
        public bool ready { get; protected set; }
        public string name { get; private set; }
        public bool bot { get; private set; }
        public bool is_disconnected { get; set; }

        public enum State
        {
            PLAYER,
            SPECTATOR
        }
    }

    class ServerHumanPlayer : ServerPlayer
    {
        private ServerPlayerConnection connection;

        public ServerHumanPlayer(ServerPlayerConnection connection, string name)
        {
            base(name, false);

            // TODO: Remove this
            ready = true;
            state = State.PLAYER;

            this.connection = connection;
            connection.receive_message.connect(forward_message);
            connection.disconnected.connect(forward_disconnected);
        }

        ~ServerHumanPlayer()
        {
            connection.receive_message.disconnect(forward_message);
            connection.disconnected.disconnect(forward_disconnected);
        }

        private void forward_message(ClientMessage message)
        {
            receive_message(this, message);
        }

        private void forward_disconnected()
        {
            disconnected(this);
        }

        public override void send_message(ServerMessage message)
        {
            connection.send_message(message);
        }

        public override void close()
        {
            connection.close();
        }
    }

    class ServerComputerPlayer : ServerPlayer
    {
        private BotConnection bot_connection;
        private ServerPlayerConnection connection;

        public ServerComputerPlayer(Bot bot)
        {
            base(bot.name, true);

            ready = true;
            state = State.PLAYER;

            GameLocalConnection local = new GameLocalConnection();
            ServerPlayerLocalConnection server = new ServerPlayerLocalConnection();

            server.set_connection(local);
            local.set_connection(server);

            bot_connection = new BotConnection(bot, local);

            connection = server;
            connection.receive_message.connect(forward_message);
        }

        ~ServerComputerPlayer()
        {
            bot_connection.stop();
            connection.receive_message.disconnect(forward_message);
        }

        private void forward_message(ClientMessage message)
        {
            receive_message(this, message);
        }

        public override void send_message(ServerMessage message)
        {
            connection.send_message(message);
        }

        public override void close()
        {
            bot_connection.stop();
        }
    }

    public abstract class ServerPlayerConnection : Object
    {
        public signal void receive_message(ClientMessage message);
        public abstract void send_message(ServerMessage message);
        public signal void disconnected();
        public abstract void close();
    }

    public class ServerPlayerNetworkConnection : ServerPlayerConnection
    {
        private Connection connection;

        public ServerPlayerNetworkConnection(Connection connection)
        {
            this.connection = connection;
            connection.message_received.connect(parse_message);
            connection.closed.connect(forward_disconnected);
        }

        ~ServerPlayerNetworkConnection()
        {
            connection.message_received.disconnect(parse_message);
            connection.closed.disconnect(forward_disconnected);
        }

        public override void send_message(ServerMessage message)
        {
            Message msg = new Message(message.serialize());
            connection.send(msg);
        }

        public override void close()
        {
            connection.close();
        }

        private void parse_message(Connection connection, Message message)
        {
            Serializable? msg = Serializable.deserialize(message.data);

            if (msg == null || !msg.get_type().is_a(typeof(ClientMessage)))
            {
                Environment.log(LogType.NETWORK, "ServerPlayerNetworkConnection", "Server discarding invalid client message");
                return;
            }
            receive_message((ClientMessage)msg);
        }

        private void forward_disconnected(Connection connection)
        {
            disconnected();
        }
    }

    public class ServerPlayerTunneledConnection : ServerPlayerConnection
    {
        public signal void send_message_request(ServerPlayerTunneledConnection connection, ServerMessage message);
        public signal void close_connection_request(ServerPlayerTunneledConnection connection);

        public ServerPlayerTunneledConnection()
        {
        }

        public override void send_message(ServerMessage message)
        {
            send_message_request(this, message);
        }

        public override void close()
        {
            close_connection_request(this);
            disconnected();
        }
    }

    public class ServerPlayerLocalConnection : ServerPlayerConnection
    {
        private GameLocalConnection? connection;

        ~ServerPlayerLocalConnection()
        {
            if (connection != null)
            {
                connection.disconnected.disconnect(connection_disconnected);
                connection = null;
                disconnected();
            }
        }

        public void set_connection(GameLocalConnection connection)
        {
            ref();

            if (this.connection != null)
            {
                this.connection.disconnected.disconnect(connection_disconnected);
                this.connection.close();
            }

            this.connection = connection;
            this.connection.disconnected.connect(connection_disconnected);

            unref();
        }

        public override void send_message(ServerMessage message)
        {
            if (connection != null)
                connection.receive_message(message);
        }

        public override void close()
        {
            if (connection != null)
                connection_disconnected();
        }

        private void connection_disconnected()
        {
            ref();

            connection.disconnected.disconnect(connection_disconnected);
            connection = null;
            disconnected();

            unref();
        }
    }
}
