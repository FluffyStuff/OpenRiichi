namespace GameServer
{
    class ServerNetworking
    {
        public signal void player_connected(ServerPlayer player);

        private Networking net = new Networking();

        public ServerNetworking()
        {
            net.connected.connect(connected);
        }

        public bool listen(uint16 port)
        {
            return net.host(port);
        }

        private void connected(Connection connection)
        {
            ServerPlayerNetworkConnection con = new ServerPlayerNetworkConnection(connection);
            ServerHumanPlayer player = new ServerHumanPlayer(con);

            player_connected(player);
        }
    }
}
