namespace GameServer
{
    class ServerNetworking
    {
        public signal void player_connected(ServerPlayer player);

        private Networking net = new Networking();

        public ServerNetworking()
        {
        }

        public bool listen(uint16 port)
        {
            return net.host(port);
        }
    }
}
