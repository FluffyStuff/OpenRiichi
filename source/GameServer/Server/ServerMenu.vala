using Gee;
using Engine;

namespace GameServer
{
    class ServerMenu : Object
    {
        private Mutex mutex = Mutex();

        private ClientMessageParser parser = new ClientMessageParser();
        private ServerPlayer?[] slots = new ServerPlayer?[4];
        private RandomClass rnd = new RandomClass();

        public signal void game_start(GameStartInfo info);
        public signal void game_start_event(GameStartInfo info);

        public ServerMenu()
        {
            players = new ArrayList<ServerPlayer>();
            observers = new ArrayList<ServerPlayer>();
            settings = new ServerSettings.default();

            parser.connect(client_game_start, typeof(ClientMessageMenuGameStart));
            parser.connect(client_add_bot, typeof(ClientMessageMenuAddBot));
            parser.connect(client_kick_player, typeof(ClientMessageMenuKickPlayer));
            parser.connect(client_settings, typeof(ClientMessageMenuSettings));
            parser.connect(client_log_file, typeof(ClientMessageMenuGameLog));
        }

        public bool player_connected(ServerPlayer player)
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

                    player.send_message(new ServerMessageMenuSettings(settings));
                    players.add(player);

                    player.receive_message.connect(message_received);
                    player.disconnected.connect(player_disconnected);

                    slots[i] = player;
                    send_assign(i, player);

                    mutex.unlock();
                    return true;
                }
            }

            mutex.unlock();

            player.close();
            return false;
        }

        public void player_disconnected(ServerPlayer player)
        {
            mutex.lock();

            for (int i = 0; i < slots.length; i++)
                if (slots[i] == player)
                {
                    mutex.unlock();
                    kick_slot(i);
                    return;
                }

            mutex.unlock();
        }

        private void message_received(ServerPlayer player, ClientMessage message)
        {
            parser.execute(player, message);
        }

        private void send_assign(int slot, ServerPlayer player)
        {
            send_assign_name(slot, player.name);
        }

        private void send_assign_name(int slot, string name)
        {
            ServerMessageMenuSlotAssign message = new ServerMessageMenuSlotAssign(slot, name);
            foreach (ServerPlayer p in players)
                p.send_message(message);
        }

        private void send_clear(int slot)
        {
            ServerMessageMenuSlotClear message = new ServerMessageMenuSlotClear(slot);
            foreach (ServerPlayer player in players)
                player.send_message(message);
        }

        private void send_settings()
        {
            ServerMessageMenuSettings message = new ServerMessageMenuSettings(settings);
            foreach (ServerPlayer player in players)
                player.send_message(message);
        }

        private void send_game_log(GameLog? log)
        {
            ServerMessageMenuGameLog message = new ServerMessageMenuGameLog(log == null ? null : "log");
            foreach (ServerPlayer player in players)
                player.send_message(message);
        }

        private void client_game_start(ServerPlayer player, ClientMessage message)
        {
            if (player != host)
                return;

            mutex.lock();

            if (players.size != 4 && log == null)
            {
                mutex.unlock();
                return;
            }

            foreach (ServerPlayer p in players)
            {
                p.receive_message.disconnect(message_received);
                p.disconnected.disconnect(player_disconnected);
            }

            int[] seats = RandomClass_seats(rnd, this.players.size);
            ArrayList<ServerPlayer> shuffled_players = new ArrayList<ServerPlayer>();
            for (int i = 0; i < this.players.size; i++)
                shuffled_players.add(this.players[seats[i]]);
            this.players = shuffled_players;

            GamePlayer[] players = new GamePlayer[this.players.size];
            for (int i = 0; i < players.length; i++)
                players[i] = new GamePlayer(i, this.players[i].name);

            mutex.unlock();

            GameStartInfo info = create_start_info(players);

            game_start(info);
        }

        private void client_add_bot(ServerPlayer player, ClientMessage message)
        {
            if (player != host)
                return;

            mutex.lock();

            var msg = (ClientMessageMenuAddBot)message;
            string name = typeof(Bot).name();
            name = name.substring(0, name.length - 3) + msg.name;
            Type? type = Type.from_name(name);

            if (type == null || !type.is_a(typeof(Bot)))
            {
                mutex.lock();
                return;
            }

            Object? obj = Object.new_with_properties(type, new string[0], new Value[0]);
            if (obj == null)
            {
                mutex.lock();
                return;
            }

            Bot bot = (Bot)obj;
            int slot = msg.slot;

            ServerPlayer bot_player = new ServerComputerPlayer(bot);

            players.add(bot_player);

            mutex.unlock();

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
            mutex.lock();

            ServerPlayer? p = slots[slot];
            if (p == null)
            {
                mutex.unlock();
                return;
            }

            p.disconnected.disconnect(player_disconnected);
            p.receive_message.disconnect(message_received);
            players.remove(p);
            send_clear(slot);
            slots[slot] = null;

            mutex.unlock();
            p.close();
        }

        private void client_settings(ServerPlayer player, ClientMessage message)
        {
            if (player != host)
                return;

            var s = (ClientMessageMenuSettings)message;
            settings = s.settings;

            send_settings();
        }

        private void client_log_file(ServerPlayer player, ClientMessage message)
        {
            if (player != host)
                return;

            var l = (ClientMessageMenuGameLog)message;
            log = l.log;
            do_log = (log != null && Environment.compatible(log.version));

            if (log != null && !Environment.compatible(log.version))
                Environment.log(LogType.DEBUG, "ServerMenu", "Incompatible game log version");

            if (!do_log)
                log = null;

            send_game_log(log);

            if (do_log)
            {
                settings = log.settings;
                send_settings();

                GamePlayer[] players = log.start_info.get_players();
                foreach (GamePlayer p in players)
                    send_assign_name(p.ID, p.name);
            }
        }

        private int[] RandomClass_seats(RandomClass rnd, int count)
        {
            int[] seats = new int[count];

            for (int i = 0; i < count; i++)
                seats[i] = i;

            for (int i = 0; i < count; i++)
            {
                int tmp = rnd.int_range(0, count);
                int a = seats[i];
                seats[i] = seats[tmp];
                seats[tmp] = a;
            }

            return seats;
        }

        private GameStartInfo create_start_info(GamePlayer[] players)
        {
            int starting_dealer = 0;
            int starting_score = 25000;
            int round_count = 8;
            int hanchan_count = 1;
            int uma_higher = 20;
            int uma_lower = 10;


            float winning_draw_animation_time = 0.5f;
            float hand_reveal_animation_time = 0.5f;
            float round_over_delay = 1.0f;

            // Add a second so the indicator counts down from the specific second to 0
            float round_end_delay = 10 + 1;
            float hanchan_end_delay = 30 + 1;
            float game_end_delay = 60 + 1;
            int decision_time = settings.decision_time + 1;

            var finish_label_fade = new AnimationTime(1, 0.5f, 0);
            var menu_items_fade = new AnimationTime(1, 0.5f, 1);
            var han_fade = new AnimationTime(0.5f, 0.5f, 0);
            var score_counting_fade = new AnimationTime(1, 0.5f, 0);
            var score_counting = new AnimationTime(1, 3, 2);
            var players_points_counting = new AnimationTime(0, 3, 2);
            var players_score_fade = new AnimationTime(0, 0.5f, 0);
            var players_score_counting = new AnimationTime(1, 3, 2);

            var initial_draw = new AnimationTime(0, 0.15f, 0);
            var tile_draw = new AnimationTime(0, 0.15f, 0.2f);
            var tile_discard = new AnimationTime(0, 0.15f, 0.3f);
            var call = new AnimationTime(0, 0.5f, 0);
            var hand_reveal = new AnimationTime(0, 0.15f, 0.8f);
            var split_wall = new AnimationTime(0, 0.5f, 0);
            var dora_flip = new AnimationTime(0, 0.2f, 0);
            var win = new AnimationTime(0, 0.5f, 0.5f);
            var riichi = new AnimationTime(0, 0.3f, 0.5f);

            var hand_order = new AnimationTime(0, 0.15f, 0);
            var hand_angle = new AnimationTime(0, 0.2f, 0);

            /*var finish_label_fade = new AnimationTime.zero();
            var menu_items_fade = new AnimationTime.zero();
            var han_fade = new AnimationTime.zero();
            var score_counting_fade = new AnimationTime.zero();
            var score_counting = new AnimationTime.zero();
            var players_points_counting = new AnimationTime.zero();
            var players_score_fade = new AnimationTime.zero();
            var players_score_counting = new AnimationTime.zero();
            var initial_draw = new AnimationTime.zero();
            var tile_draw = new AnimationTime.zero();
            var tile_discard = new AnimationTime.zero();
            var call = new AnimationTime.zero();
            var hand_reveal = new AnimationTime.zero();
            var split_wall = new AnimationTime.zero();
            var dora_flip = new AnimationTime.zero();
            var win = new AnimationTime.zero();
            var riichi = new AnimationTime.zero();
            var hand_order = new AnimationTime.zero();
            var hand_angle = new AnimationTime.zero();*/

            AnimationTimings timings = new AnimationTimings
            (
                winning_draw_animation_time,
                hand_reveal_animation_time,
                round_over_delay,
                round_end_delay,
                hanchan_end_delay,
                game_end_delay,
                decision_time,
                finish_label_fade,
                menu_items_fade,
                han_fade,
                score_counting_fade,
                score_counting,
                players_points_counting,
                players_score_fade,
                players_score_counting,

                initial_draw,
                tile_draw,
                tile_discard,
                call,
                hand_reveal,
                split_wall,
                dora_flip,
                win,
                riichi,

                hand_order,
                hand_angle
            );

            GameStartInfo info = new GameStartInfo
            (
                players,
                timings,
                starting_dealer,
                starting_score,
                round_count,
                hanchan_count,
                uma_higher,
                uma_lower
            );

            return info;
        }

        public ServerPlayer? host { get; private set; }
        public ArrayList<ServerPlayer> players { get; private set; }
        public ArrayList<ServerPlayer> observers { get; private set; }
        public ServerSettings settings { get; private set; }
        public bool do_log { get; private set; }
        public GameLog? log { get; private set; }
    }
}
