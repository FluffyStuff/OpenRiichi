namespace GameServer
{
    abstract class ServerPlayer : Object
    {
        public signal void disconnected(ServerPlayer player);
        public signal void receive_message(ServerPlayer player, ClientMessage message);

        public virtual void send_message(ServerMessage message) {}

        public State state { get; protected set; }
        public bool ready { get; protected set; }

        public enum State
        {
            PLAYER,
            SPECTATOR
        }
    }

    class ServerHumanPlayer : ServerPlayer
    {
        private ServerPlayerConnection connection;

        public ServerHumanPlayer(ServerPlayerConnection connection)
        {
            // TODO: Remove this
            ready = true;
            state = State.PLAYER;

            this.connection = connection;
            connection.receive_message.connect(forward_message);
        }

        private void forward_message(ClientMessage message)
        {
            receive_message(this, message);
        }

        public override void send_message(ServerMessage message)
        {
            connection.send_message(message);
        }
    }

    class ServerComputerPlayer : ServerPlayer
    {
        private ServerPlayerConnection connection;

        public ServerComputerPlayer(ServerPlayerConnection connection)
        {
            ready = true;
            state = State.PLAYER;

            this.connection = connection;
            connection.receive_message.connect(forward_message);
        }

        private void forward_message(ClientMessage message)
        {
            receive_message(this, message);
        }

        public override void send_message(ServerMessage message)
        {
            connection.send_message(message);
        }
    }

    public abstract class ServerPlayerConnection
    {
        public signal void receive_message(ClientMessage message);
        public abstract void send_message(ServerMessage message);
    }

    public class ServerPlayerLocalConnection : ServerPlayerConnection
    {
        private unowned GameLocalConnection? connection;

        public void set_connection(GameLocalConnection connection)
        {
            this.connection = connection;
        }

        public override void send_message(ServerMessage message)
        {
            if (connection != null)
                connection.receive_message(message);
        }
    }
}
