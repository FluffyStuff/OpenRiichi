using Gee;
using Engine;

namespace GameServer
{
    public class ServerController : Object
    {
        private Server server;
        private ServerMenu menu = new ServerMenu();
        private ServerNetworking? net = null;
        private ClientMessageParser parser = new ClientMessageParser();

        private ServerPlayer host;
        private ArrayList<ServerPlayer> players;
        private ArrayList<ServerPlayer> observers;
        private GameLog? log;
        private ServerSettings settings;
        private GameStartInfo info;
        private RandomClass rnd = new RandomClass();

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

        private void game_start(GameStartInfo info)
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

            host = menu.host;

            foreach (ServerPlayer player in menu.players)
                player.disconnected.connect(player_disconnected);

            if(menu.do_log)
            {
                observers = menu.players;
                foreach (var player in menu.observers)
                    observers.add(player);
                players = new ArrayList<ServerPlayer>();

                log = menu.log;
                settings = log.settings;
                this.info = log.start_info;
            }
            else
            {
                players = menu.players;
                observers = menu.observers;
                settings = menu.settings;
                this.info = info;

                foreach (ServerPlayer player in players)
                    player.receive_message.connect(message_received);
            }

            foreach (ServerPlayer player in observers)
                player.receive_message.connect(message_received);

            menu = null;

            ref(); // Keep alive until graceful shutdown
            Threading.start0(server_worker);

            mutex.unlock();
        }

        private void server_worker()
        {
            if (log != null)
                server = new LogServer(observers, rnd, settings, log);
            else
                server = new RegularServer(players, observers, rnd, info, settings);
            
            Timer timer = new Timer();

            while (!finished && !server.finished)
            {
                mutex.lock();
                float time = (float)timer.elapsed();
                process_messages();
                server.process(time);
                mutex.unlock();
                sleep();
            }

            die();

            unref(); // Allow graceful deallocation
        }

        private void sleep()
        {
            Thread.usleep(10000); // Server is not cpu intensive at all (can save cycles)
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
            if (player == host)
            {
                kill();
                return;
            }

            mutex.lock();
            server.player_disconnected(player);
            mutex.unlock();
        }

        private void die()
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
