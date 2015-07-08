using Gee;

namespace GameServer
{
    public class ServerController
    {
        private Server server;
        private ServerNetworking net;
        private ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();

        private Mutex mutex = new Mutex();

        public ServerController()
        {
        }

        public bool listen(uint16 port)
        {
            net = new ServerNetworking();
            net.player_connected.connect(add_player);

            if (net.listen(port))
                return false;

            return true;
        }

        public void add_player(ServerPlayer player)
        {
            mutex.lock();
            player.disconnected.connect(remove_player);
            players.add(player);
            mutex.unlock();

            //if (players.size == 4)
            //    Threading.start0(start);
        }

        private void start()
        {
            Thread.usleep(1 * 1000000);
            start_game();
        }

        private void remove_player(ServerPlayer player)
        {
            players.remove(player);
        }

        public void start_game()
        {
            mutex.lock();
            bool ready = true;
            int playing = 0;
            ServerPlayer[] players = new ServerPlayer[4];

            int a = 0;
            foreach (ServerPlayer player in this.players)
            {
                if (player.state == ServerPlayer.State.PLAYER)
                {
                    if (a >= 4 || !player.ready)
                    {
                        ready = false;
                        break;
                    }

                    players[a++] = player;
                    playing++;
                }
            }

            if (!ready || playing != 4)
            {
                mutex.unlock();
                return;
            }

            server = new Server();
            server.create_game(players);
            mutex.unlock();
        }
    }
}
