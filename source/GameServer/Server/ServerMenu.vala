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
            parser.connect(client_add_bot, typeof(ClientMessageMenuAddBot));
            parser.connect(client_kick_player, typeof(ClientMessageMenuKickPlayer));
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

            for (int i = 0; i < slots.length; i++)
                if (slots[i] == player)
                {
                    kick_slot(i);
                    break;
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

        private void client_add_bot(ServerPlayer player, ClientMessage message)
        {
            if (player != host)
                return;

            var msg = (ClientMessageMenuAddBot)message;
            string name = typeof(Bot).name();
            name = name.substring(0, name.length - 3) + msg.name;
            Type tn = typeof(NullBot);
            Type? type = Type.from_name(name);

            if (type == null || !type.is_a(typeof(Bot)))
                return;

            Object? obj = Object.newv(type, new Parameter[0]);
            if (obj == null)
                return;

            Bot bot = (Bot)obj;
            int slot = msg.slot;

            ServerPlayer bot_player = new ServerComputerPlayer(bot);

            players.add(bot_player);

            kick_slot(msg.slot);
            slots[slot] = bot_player;
            send_assign(slot, bot_player);
        }

        private void client_kick_player(ServerPlayer player, ClientMessage message)
        {
            if (player != host)
                return;

            var kick = (ClientMessageMenuKickPlayer)message;
            kick_slot(kick.slot);
        }

        private void kick_slot(int slot)
        {
            ServerPlayer? p = slots[slot];
            if (p == null)
                return;

            p.disconnected.disconnect(player_disconnected);
            p.receive_message.disconnect(message_received);
            players.remove(p);
            p.close();
            send_clear(slot);
            slots[slot] = null;
        }

        public ArrayList<ServerPlayer> players { get; private set; }
        public ArrayList<ServerPlayer> observers { get; private set; }
    }
}
