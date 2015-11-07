using Gee;

namespace GameServer
{
    class ServerNetworking
    {
        public signal void player_connected(ServerPlayer player);
        private ArrayList<ConnectionAttempt> connections = new ArrayList<ConnectionAttempt>();

        private Networking? net = new Networking();
        private Mutex mutex = Mutex();

        public ServerNetworking()
        {
        }

        ~ServerNetworking()
        {
            close();
        }

        public bool listen(uint16 port)
        {
            net.connected.connect(connected);
            return net.host(port);
        }

        public void close()
        {
            net.connected.disconnect(connected);
            net.close();
        }

        public void stop_listening()
        {
            mutex.lock();

            net.connected.disconnect(connected);
            net.stop_listening();

            for (int i = 0; i < connections.size; i++)
                connections.get(i).close();
            connections.clear();

            mutex.unlock();
        }

        private void connected(Connection connection)
        {
            mutex.lock();

            ConnectionAttempt attempt = new ConnectionAttempt(connection);
            attempt.connection_attempt.connect(connection_attempt);
            connections.add(attempt);

            mutex.unlock();
        }

        private void connection_attempt(ConnectionAttempt connection, ClientMessageAuthenticate message)
        {
            string name = message.name.strip();

            bool accept = true;
            if (name.char_count() < 1 ||
                name.char_count() > 20)
                accept = false;

            mutex.lock();
            connections.remove(connection);

            if (accept)
            {
                ServerPlayerNetworkConnection con = new ServerPlayerNetworkConnection(connection.connection);
                ServerHumanPlayer player = new ServerHumanPlayer(con, name);
                player.send_message(new ServerMessageAcceptJoin());
                player_connected(player);
            }
            else
            {
                connection.close();
            }
            mutex.unlock();
        }

        private class ConnectionAttempt
        {
            public signal void connection_attempt(ConnectionAttempt client, ClientMessageAuthenticate message);
            public signal void disconnected(ConnectionAttempt client);

            public ConnectionAttempt(Connection connection)
            {
                this.connection = connection;
                connection.message_received.connect(parse_message);
                connection.closed.connect(forward_disconnected);
            }

            ~ConnectionAttempt()
            {
                connection.message_received.disconnect(parse_message);
                connection.closed.disconnect(forward_disconnected);
            }

            public void close()
            {
                connection.close();
            }

            private void parse_message(Connection connection, Message message)
            {
                Serializable? msg = Serializable.deserialize(message.data);

                if (msg == null || !msg.get_type().is_a(typeof(ClientMessageAuthenticate)))
                {
                    print("Server discarding invalid connection attempt message!\n");
                    return;
                }

                connection_attempt(this, (ClientMessageAuthenticate)msg);
            }

            private void forward_disconnected()
            {
                disconnected(this);
            }

            public Connection connection { get; private set; }
        }
    }
}
