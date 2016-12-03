using Gee;

namespace GameServer
{
    public class Server : Object
    {
        private GameState state;
        private GameStartInfo start_info;
        private ServerSettings settings;
        private State action_state;
        private ServerGameRound? round = null;
        private Random rnd;
        private DelayTimer timer = new DelayTimer();
        private ServerGameRoundInfoSource source;
        private bool reveal;

        private ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();
        private ArrayList<ServerPlayer> spectators = new ArrayList<ServerPlayer>();
        //private Logger logger;
        private GameLogger? game_log;

        //public signal void log(string message);

        private void log(GameLogLine line)
        {
            //logger.log(LogType.GAME, "Server", message);
            if (game_log != null)
                game_log.log(line);
        }

        private void log_round(RoundStartInfo info, Tile[] tiles)
        {
            if (game_log != null)
                game_log.log_round(info, tiles);
        }

        public Server(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, Random rnd, GameStartInfo start_info, ServerSettings settings, ServerGameRoundInfoSource source, bool do_log, bool reveal)
        {
            this.players = new ArrayList<ServerPlayer>();
            this.spectators = spectators;
            this.rnd = rnd;
            this.start_info = start_info;
            this.settings = settings;
            this.source = source;
            this.reveal = reveal;

            for (int i = 0; i < players.size; i++)
            {
                ServerPlayer player = players[i];
                this.players.add(player);

                ServerMessageGameStart start = new ServerMessageGameStart(start_info, settings, i);
                player.send_message(start);
            }

            for (int i = 0; i < spectators.size; i++)
            {
                ServerMessageGameStart start = new ServerMessageGameStart(start_info, settings, -1);
                spectators[i].send_message(start);
            }

            state = new GameState(start_info, settings);

            if (do_log)
                game_log = Environment.open_game_log(start_info, settings);

            //log(new StartingGameGameLogLine(new TimeStamp.now(), start_info, settings));

            //state.log.connect(do_log);

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
                    state.round_finished(result);

                    if (state.game_is_finished)
                    {
                        action_state = State.GAME_FINISHED;
                        timer.set_time(start_info.game_wait_time);
                    }
                    else if (state.hanchan_is_finished)
                    {
                        action_state = State.HANCHAN_FINISHED;
                        timer.set_time(start_info.hanchan_wait_time);
                    }
                    else if (state.round_is_finished)
                    {
                        action_state = State.ROUND_FINISHED;
                        timer.set_time(start_info.round_wait_time);
                    }
                }
            }
            else if (action_state == State.ROUND_FINISHED || action_state == State.HANCHAN_FINISHED)
            {
                if (!timer.active(time))
                    return;

                start_round(time);
            }
            else if (action_state == State.GAME_FINISHED)
            {
                if (!timer.active(time))
                    return;

                finished = true;
            }
        }

        public void message_received(ServerPlayer player, ClientMessage message)
        {
            if (action_state == State.ACTIVE)
                round.message_received(player, message);
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
            ServerGameRoundInfoSourceRound info = source.get_round();

            action_state = State.ACTIVE;
            state.start_round(info.info);

            round = new ServerGameRound(info.info, settings, players, spectators, state.round_wind, state.dealer_index, rnd, state.can_riichi(), start_info.decision_time, info.tiles, reveal);
            log_round(info.info, round.tiles);

            round.declare_riichi.connect(state.declare_riichi);
            round.log.connect(log);
            round.start(time);
        }

        public bool finished { get; private set; }

        private enum State
        {
            ACTIVE,
            GAME_FINISHED,
            HANCHAN_FINISHED,
            ROUND_FINISHED
        }
    }
}
