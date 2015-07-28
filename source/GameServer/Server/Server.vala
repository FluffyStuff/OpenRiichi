using Gee;

namespace GameServer
{
    // Round manager
    public class Server
    {
        private State state = State.ACTIVE;
        private ServerGameRound round;

        private int round_number = 0;
        private int dealer = 0;
        private Wind round_wind = Wind.EAST;
        private int[] player_seats;
        private int renchan = 0;

        private unowned Rand rnd;
        private DelayTimer timer = new DelayTimer();

        private ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();
        private ArrayList<ServerPlayer> spectators = new ArrayList<ServerPlayer>();

        public Server(ArrayList<ServerPlayer> clients, Rand rnd)
        {
            this.rnd = rnd;

            foreach (ServerPlayer client in clients)
            {
                if (client.state == ServerPlayer.State.PLAYER)
                    players.add(client);
                else if (client.state == ServerPlayer.State.SPECTATOR)
                    spectators.add(client);
            }

            player_seats = random_seats(rnd, 4);
            start_round();
        }

        private void start_round()
        {
            state = State.ACTIVE;
            round = new ServerGameRound(players, spectators, player_seats, round_wind, dealer);
        }

        private void next_round(bool renchan)
        {
            if (renchan)
                this.renchan++;
            else
            {
                this.renchan = 0;

                round_number = (round_number + 1) % 4;
                dealer = round_number;

                if (round_number == 0)
                    round_wind = NEXT_WIND(round_wind);
            }
        }

        public void process(float time)
        {
            if (state == State.ACTIVE)
            {
                round.process(time);

                if (round.finished)
                    round_finished();
            }
            else if (state == State.WAITING)
            {
                if (!timer.active(time))
                    return;

                next_round(false);
                start_round();
            }
        }

        public void message_received(ServerPlayer player, ClientMessage message)
        {
            if (state == State.ACTIVE)
            {
                round.message_received(player, message);
            }
        }

        private void round_finished()
        {
            round = null;
            state = State.WAITING;
            timer.set_time(15);
        }

        private int[] random_seats(Rand rnd, int count)
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

        private enum State
        {
            ACTIVE,
            WAITING
        }

        private class ServerRoundPlayer
        {

        }
    }
}
