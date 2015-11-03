using Gee;

namespace GameServer
{
    public class ServerController : Object
    {
        private Server server;
        private ServerMenu menu = new ServerMenu();
        private ServerNetworking? net = null;
        private ClientMessageParser parser = new ClientMessageParser();

        private Mutex mutex = Mutex();
        private bool started = false;
        private bool finished = false;

        public ServerController()
        {
            menu.game_start.connect(game_start);
        }

        ~ServerController()
        {
            close_network();
        }

        public bool start_listening(uint16 port)
        {
            if (net != null)
                return false;

            net = new ServerNetworking();
            net.player_connected.connect(player_connected);

            return net.listen(port);
        }

        public void stop_listening()
        {
            if (net != null)
                net.stop_listening();
        }

        public void close_network()
        {
            if (net != null)
                net.close();
        }

        public void add_player(ServerPlayer player)
        {
            mutex.lock();

            if (!started)
                player_connected(player);

            mutex.unlock();
        }

        public void kill()
        {
            finished = true;
        }

        private void player_connected(ServerPlayer player)
        {
            menu.player_connected(player);
        }

        private void game_start()
        {
            mutex.lock();

            if (started)
            {
                mutex.unlock();
                return;
            }

            started = true;

            if (net != null)
            {
                net.player_connected.disconnect(player_connected);
                stop_listening();
            }

            ArrayList<ServerPlayer> players = menu.players;
            ArrayList<ServerPlayer> observers = menu.observers;

            foreach (ServerPlayer player in players)
            {
                player.receive_message.connect(message_received);
                player.disconnected.connect(player_disconnected);
            }

            menu = null;

            ref(); // Keep alive until graceful shutdown
            Threading.start2(server_worker, players, observers);

            mutex.unlock();
        }

        private void server_worker(Object players_obj, Object observers_obj)
        {
            ArrayList<ServerPlayer> players = players_obj as ArrayList<ServerPlayer>;
            ArrayList<ServerPlayer> observers = observers_obj as ArrayList<ServerPlayer>;

            server = new Server(players, new Rand());
            Timer timer = new Timer();

            while (!finished)
            {
                process_messages();
                server.process((float)timer.elapsed());
                sleep();
            }

            die(players, observers);

            unref(); // Allow graceful deallocation
        }

        private void process_messages()
        {
            ClientMessageParser.ClientMessageTuple? message;
            while ((message = parser.dequeue()) != null)
                server.message_received(message.player, message.message);
        }

        private void message_received(ServerPlayer player, ClientMessage message)
        {
            parser.add(player, message);
        }

        private void player_disconnected(ServerPlayer player)
        {
            finished = true;
        }

        private void sleep()
        {
            Thread.usleep(10000); // Server is not cpu intensive at all (can save cycles)
        }

        private void die(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> observers)
        {
            foreach (ServerPlayer player in players)
            {
                player.disconnected.disconnect(player_disconnected);
                player.close();
            }

            foreach (ServerPlayer player in observers)
            {
                player.disconnected.disconnect(player_disconnected);
                player.close();
            }

            close_network();
        }
    }
}
