using Gee;

namespace GameServer
{
    public class Server : Object
    {
        private GameState state;
        private GameStartInfo start_info;
        private State action_state;
        private ServerGameRound? round = null;
        private unowned Rand rnd;
        private DelayTimer timer = new DelayTimer();

        private ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();
        private ArrayList<ServerPlayer> spectators = new ArrayList<ServerPlayer>();

        public Server(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, Rand rnd, GameStartInfo start_info)
        {
            this.players = new ArrayList<ServerPlayer>();
            this.spectators = spectators;
            this.rnd = rnd;
            this.start_info = start_info;

            for (int i = 0; i < players.size; i++)
            {
                ServerPlayer player = players[i];
                this.players.add(player);

                ServerMessageGameStart start = new ServerMessageGameStart(start_info, i);
                player.send_message(start);
            }

            state = new GameState(start_info);

            start_round();
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

                start_round();
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

        private void start_round()
        {
            action_state = State.ACTIVE;

            int wall_index = rnd.int_range(1, 7) + rnd.int_range(1, 7); // Emulate dual die roll probability
            RoundStartInfo info = new RoundStartInfo(wall_index);
            state.start_round(info);

            round = new ServerGameRound(info, players, spectators, state.round_wind, state.dealer_index, rnd, state.can_riichi());
            round.declare_riichi.connect(state.declare_riichi);
            round.start();
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
