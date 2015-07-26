using Gee;

namespace GameServer
{
    public class ServerController : Object
    {
        private Server server;
        private ServerNetworking? net;
        private ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();

        private Mutex mutex = new Mutex();
        private bool finished = false;

        public ServerController()
        {
        }

        ~ServerController()
        {
            stop_listen();
        }

        public bool listen(uint16 port)
        {
            net = new ServerNetworking();
            net.player_connected.connect(player_connected);

            if (net.listen(port))
                return false;

            return true;
        }

        public void stop_listen()
        {
            if (net != null)
                net.close();
        }

        private void player_connected(ServerPlayer player)
        {
            print("Player joined (%d players now).\n", players.size + 1);
            player.disconnected.connect(player_disconnected);
            add_player(player);
        }

        private void player_disconnected(ServerPlayer player)
        {
            print("Player left (%d players now).\n", players.size - 1);
            remove_player(player);
        }

        public void add_player(ServerPlayer player)
        {
            mutex.lock();
            players.add(player);
            mutex.unlock();

            if (players.size == 4)
                start_game();
        }

        public void remove_player(ServerPlayer player)
        {
            mutex.lock();
            player.disconnected.disconnect(remove_player);
            players.remove(player);
            mutex.unlock();
        }

        public void start_game()
        {
            Threading.start0(start);
        }

        private void start()
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

            net.stop_listening();

            ref(); // Keep alive until graceful shutdown

            foreach (ServerPlayer player in this.players)
                player.disconnected.disconnect(remove_player);

            net.player_connected.disconnect(player_connected);
            server = new Server();
            server.server_finished.connect(die);
            server.create_game(players);
            mutex.unlock();
        }

        public int get_player_count()
        {
            return players.size;
        }

        //private ServerController? dealloc = null;
        private void die()
        {
            mutex.lock();
            if (finished)
            {
                mutex.unlock();
                return;
            }
            finished = true;
            mutex.unlock();

            while (players.size > 0)
            {
                ServerPlayer player = players[0];
                player.close();
                remove_player(player);
            }

            players.clear();
            stop_listen();

            unref(); // Allow graceful deallocation
        }
    }
}
