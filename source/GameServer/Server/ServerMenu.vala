using Gee;

namespace GameServer
{
    class ServerMenu
    {
        private Mutex mutex = Mutex();

        private ClientMessageParser parser = new ClientMessageParser();
        private ServerPlayer? host = null;
        private ServerPlayer?[] slots = new ServerPlayer?[4];

        public signal void game_start(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> observers);

        public ServerMenu()
        {
            players = new ArrayList<ServerPlayer>();
            observers = new ArrayList<ServerPlayer>();

            parser.connect(client_game_start, typeof(ClientMessageMenuGameStart));
        }

        public void player_connected(ServerPlayer player)
        {
            mutex.lock();

            if (host == null)
                host = player;

            for (int i = 0; i < slots.length; i++)
            {
                if (slots[i] == null)
                {
                    for (int j = 0; j < slots.length; j++)
                        if (slots[j] != null)
                            player.send_message(new ServerMessageMenuSlotAssign(j, slots[j].name));

                    players.add(player);

                    player.receive_message.connect(message_received);
                    player.disconnected.connect(player_disconnected);

                    slots[i] = player;
                    send_assign(i, player);

                    mutex.unlock();
                    return;
                }
            }

            mutex.unlock();

            player.close();
        }

        public void player_disconnected(ServerPlayer player)
        {
            mutex.lock();

            player.disconnected.disconnect(player_disconnected);
            player.receive_message.disconnect(message_received);
            players.remove(player);

            for (int i = 0; i < slots.length; i++)
                if (slots[i] == player)
                {
                    slots[i] = null;
                    send_clear(i);
                }

            mutex.unlock();
        }

        private void message_received(ServerPlayer player, ClientMessage message)
        {
            mutex.lock();
            parser.execute(player, message);
            mutex.unlock();
        }

        private void send_assign(int slot, ServerPlayer player)
        {
            ServerMessageMenuSlotAssign message = new ServerMessageMenuSlotAssign(slot, player.name);
            foreach (ServerPlayer p in players)
                p.send_message(message);
        }

        private void send_clear(int slot)
        {
            ServerMessageMenuSlotClear message = new ServerMessageMenuSlotClear(slot);
            foreach (ServerPlayer player in players)
                player.send_message(message);
        }

        private void client_game_start(ServerPlayer player, ClientMessage message)
        {
            if (player != host)
                return;

            if (players.size != 4)
                return;

            foreach (ServerPlayer p in players)
            {
                p.receive_message.disconnect(message_received);
                p.disconnected.disconnect(player_disconnected);
            }

            game_start(players, observers);
        }

        public ArrayList<ServerPlayer> players { get; private set; }
        public ArrayList<ServerPlayer> observers { get; private set; }
    }
}
