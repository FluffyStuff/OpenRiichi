namespace GameServer
{
    class ServerNetworking
    {
        public signal void player_connected(ServerPlayer player);

        private Networking? net = new Networking();

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
            net.connected.disconnect(connected);
            net.stop_listening();
        }

        private void connected(Connection connection)
        {
            ServerPlayerNetworkConnection con = new ServerPlayerNetworkConnection(connection);
            ServerHumanPlayer player = new ServerHumanPlayer(con);

            player_connected(player);
        }
    }
}
