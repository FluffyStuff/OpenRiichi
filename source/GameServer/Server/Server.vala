using Gee;
using Engine;

namespace GameServer
{
    abstract class Server : Object
    {
        protected GameState state;
        protected GameStartInfo start_info;
        protected ServerSettings settings;
        protected RandomClass rnd;
        private State action_state;
        private ServerGameRound? round;
        private DelayTimer timer = new DelayTimer();

        protected ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();
        protected ArrayList<ServerPlayer> spectators = new ArrayList<ServerPlayer>();

        protected Server(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, RandomClass rnd, GameStartInfo start_info, ServerSettings settings)
        {
            this.rnd = rnd;
            this.start_info = start_info;
            this.settings = settings;

            state = new GameState(start_info, settings);

            for (int i = 0; i < players.size; i++)
            {
                ServerPlayer player = players[i];
                this.players.add(player);

                ServerMessageGameStart start = new ServerMessageGameStart(start_info, settings, i);
                player.send_message(start);
            }

            for (int i = 0; i < spectators.size; i++)
            {
                ServerPlayer spectator = spectators[i];
                this.spectators.add(spectator);

                ServerMessageGameStart start = new ServerMessageGameStart(start_info, settings, -1);
                spectator.send_message(start);
            }
        }

        protected void start()
        {
            start_round(0);
        }

        public void process(float time)
        {
            if (finished)
                return;

            if (action_state == State.ACTIVE)
            {
                round.process(time);

                if (round.finished)
                {
                    RoundFinishResult result = round.result;
                    var score = state.round_finished(result);

                    timer.set_time(start_info.timings.get_animation_round_end_delay(score));

                    if (state.game_is_finished)
                        action_state = State.GAME_FINISHED;
                    else if (state.hanchan_is_finished)
                        action_state = State.HANCHAN_FINISHED;
                    else if (state.round_is_finished)
                        action_state = State.ROUND_FINISHED;
                }
            }
            else
            {
                bool done = false;
                if (timer.active(time))
                    done = true;
                else
                {
                    done = true;
                    foreach (var player in players)
                        if (!player.ready)
                            done = false;
                    foreach (var player in spectators)
                        if (!player.ready)
                            done = false;
                }

                if (done)
                {
                    if (action_state == State.ROUND_FINISHED || action_state == State.HANCHAN_FINISHED)
                        start_round(time);
                    else if (action_state == State.GAME_FINISHED)
                        finished = true;
                }
            }
        }

        public void message_received(ServerPlayer player, ClientMessage message)
        {
            if (action_state == State.ACTIVE && players.contains(player))
                round.message_received(player, message);
            else if (message is ClientMessageMenuReady)
                player.ready = true;
        }

        public void player_disconnected(ServerPlayer player)
        {
            player.is_disconnected = true;

            if (finished || action_state == State.GAME_FINISHED)
                return;

            for (int i = 0; i < players.size; i++)
            {
                if (players[i] == player)
                {
                    ServerMessagePlayerLeft message = new ServerMessagePlayerLeft(i);

                    foreach (ServerPlayer p in players)
                        p.send_message(message);

                    foreach (ServerPlayer p in spectators)
                        p.send_message(message);

                    if (round != null)
                        round.player_disconnected(i);

                    break;
                }
            }
        }

        private void start_round(float time)
        {
            foreach (var player in players)
                player.ready = false;
            foreach (var player in spectators)
                player.ready = false;

            action_state = State.ACTIVE;

            var info = get_round_start_info();
            state.start_round(info);
            round = create_round(info);

            round.declare_riichi.connect(state.declare_riichi);
            round.start(time);
        }

        protected abstract ServerGameRound create_round(RoundStartInfo info);
        protected abstract RoundStartInfo get_round_start_info();

        public bool finished { get; private set; }

        private enum State
        {
            ACTIVE,
            GAME_FINISHED,
            HANCHAN_FINISHED,
            ROUND_FINISHED
        }
    }

    class RegularServer : Server
    {
        private GameLogger? game_log;

        public RegularServer(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, RandomClass rnd, GameStartInfo info, ServerSettings settings)
        {
            base(players, spectators, rnd, info, settings);
            game_log = Environment.open_game_log(info, settings);

            start();
        }

        private void log(GameLogLine line)
        {
            if (game_log != null)
                game_log.log(line);
        }

        private void log_round(RoundStartInfo info, Tile[] tiles)
        {
            if (game_log != null)
                game_log.log_round(info, tiles);
        }

        protected override RoundStartInfo get_round_start_info()
        {
            int wall_index = rnd.int_range(1, 7) + rnd.int_range(1, 7); // Emulate dual die roll probability
            return new RoundStartInfo(wall_index);
        }

        protected override ServerGameRound create_round(RoundStartInfo info)
        {
            RegularServerGameRound round = new RegularServerGameRound(info, settings, players, spectators, state.round_wind, state.dealer_index, rnd, state.can_riichi(), start_info.timings);
            log_round(info, round.tiles);
            round.log.connect(log);

            return round;
        }
    }

    class LogServer : Server
    {
        private GameLogRound[] rounds;
        private GameLogRound round;
        private int round_index = 0;

        public LogServer(ArrayList<ServerPlayer> spectators, RandomClass rnd, ServerSettings settings, GameLog log)
        {
            ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();
            for (int i = 0; i < 4; i++)
                players.add(new ServerLogPlayer()); // Dummies

            base(players, spectators, rnd, log.start_info, settings);
            rounds = log.rounds.to_array();

            start();
        }

        protected override RoundStartInfo get_round_start_info()
        {
            if (rounds.length <= round_index)
            {
                var info = new RoundStartInfo(rnd.int_range(2, 13));
                round = new GameLogRound(info, null);
                return info;
            }

            round = rounds[round_index++];
            return round.start_info;
        }

        protected override ServerGameRound create_round(RoundStartInfo info)
        {
            return new LogServerGameRound(settings, players, spectators, state.round_wind, state.dealer_index, rnd, state.can_riichi(), start_info.timings, round);
        }

        public class ServerLogPlayer : ServerPlayer
        {
            public ServerLogPlayer()
            {
                base("", false);

                ready = true;
                state = State.PLAYER;
            }

            public override void close()
            {
                // Nothing
            }

            public override bool ready
            {
                get { return true; }
                set {}
            }
        }
    }
}
