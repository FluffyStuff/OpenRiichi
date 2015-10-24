using Gee;

namespace GameServer
{
    public class ServerController : Object
    {
        private Server server;
        private ServerNetworking? net;
        private ClientMessageParser parser = new ClientMessageParser();
        private ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();

        private Mutex mutex = Mutex();
        private Rand rnd = new Rand();
        private Timer timer = new Timer();
        private bool game_starting = false;
        private bool game_started = false;
        private bool finished = false;

        public ServerController()
        {

        }

        ~ServerController()
        {
            stop_listening();
        }

        public void start_local()
        {
            Threading.start0(server_worker);
        }

        public void start_network(uint16 port)
        {
            start_listening(port);
            start_local();
        }

        private void server_worker()
        {
            ref(); // Keep alive until graceful shutdown

            bool alive = true;

            while (alive)
            {
                mutex.lock();
                alive = !finished;
                bool starting = game_starting;
                bool started = game_started;
                mutex.unlock();

                sleep();

                process_messages();

                if (!starting && !started)
                    continue;

                if (!started)
                {
                    start_controller();
                    game_started = true;
                }

                server.process((float)timer.elapsed());
            }

            die();

            unref(); // Allow graceful deallocation
        }

        private void process_messages()
        {
            ClientMessageParser.ClientMessageTuple? message;

            while ((message = parser.dequeue()) != null)
            {
                parser.execute(message.player, message.message);

                if (!game_started)
                    continue;

                server.message_received(message.player, message.message);
            }
        }

        private void sleep()
        {
            Thread.usleep(10000); // Server is not cpu intensive at all (can save cycles)
        }

        private bool start_listening(uint16 port)
        {
            net = new ServerNetworking();
            net.player_connected.connect(player_connected);

            if (net.listen(port))
                return false;

            return true;
        }

        private void stop_listening()
        {
            if (net != null)
                net.close();
        }

        private void message_received(ServerPlayer player, ClientMessage message)
        {
            ref();
            parser.add(player, message);
            unref();
        }

        private void player_connected(ServerPlayer player)
        {
            print("Player connected (%d players now).\n", players.size + 1);

            ref();
            add_player(player);
            unref();
        }

        private void player_disconnected(ServerPlayer player)
        {
            ref();

            print("Player disconnected (%d players now).\n", players.size - 1);
            remove_player(player);

            mutex.lock();
            if (game_started)
                finished = true;
            mutex.unlock();

            unref();
        }

        public void add_player(ServerPlayer player)
        {
            player.receive_message.connect(message_received);
            player.disconnected.connect(player_disconnected);

            mutex.lock();
            players.add(player);
            int size = players.size;
            mutex.unlock();

            if (size == 4)
                start_game();
        }

        public void remove_player(ServerPlayer player)
        {
            mutex.lock();
            player.disconnected.disconnect(remove_player);
            player.receive_message.disconnect(message_received);
            players.remove(player);
            mutex.unlock();
        }

        public void start_game()
        {
            mutex.lock();
            game_starting = true;
            mutex.unlock();
        }

        private void start_controller()
        {
            bool ready = true;
            int playing = 0;

            int a = 0;
            foreach (ServerPlayer player in players)
            {
                if (player.state == ServerPlayer.State.PLAYER)
                {
                    if (a >= 4 || !player.ready)
                    {
                        ready = false;
                        break;
                    }

                    playing++;
                }
            }

            if (!ready || playing != 4)
                return;

            net.stop_listening();

            foreach (ServerPlayer player in players)
                player.disconnected.disconnect(remove_player);

            net.player_connected.disconnect(player_connected);
            server = new Server(players, rnd);
        }

        public int get_player_count()
        {
            return players.size;
        }

        private void die()
        {
            while (true)
            {
                ServerPlayer player;
                mutex.lock();

                if (players.size == 0)
                {
                    mutex.unlock();
                    break;
                }

                player = players[0];
                player.close();
                mutex.unlock();

                remove_player(player);
            }

            stop_listening();
        }
    }
}
