using Gee;

namespace GameServer
{
    public class Server
    {
        private const int ROUNDS = 1;

        private ServerRoundManager round;
        private int round_count = 0;

        private ArrayList<ServerPlayer> players = new ArrayList<ServerPlayer>();
        private ArrayList<ServerPlayer> spectators = new ArrayList<ServerPlayer>();
        private int[] player_seats;

        public Server(ArrayList<ServerPlayer> clients, Rand rnd)
        {
            player_seats = random_seats(rnd, 4);
            foreach (ServerPlayer client in clients)
            {
                if (client.state == ServerPlayer.State.PLAYER)
                    players.add(client);
                else if (client.state == ServerPlayer.State.SPECTATOR)
                    spectators.add(client);
            }

            round = new ServerRoundManager(players, spectators, player_seats, rnd);
        }


        public void process(float time)
        {
            if (finished)
                return;

            round.process(time);

            if (round.finished)
            {
                int[] points = round.points;
                calculate_points(points);

                if (++round_count == ROUNDS)
                {
                    finished = true;
                    return;
                }
            }
        }

        public void message_received(ServerPlayer player, ClientMessage message)
        {
            round.message_received(player, message);
        }

        private void calculate_points(int[] points)
        {
            int first = 0;

            for (int i = 1; i < points.length; i++)
                if (points[player_seats[i]] > points[player_seats[first]])
                    first = i;

            int[] p = new int[points.length];

            int sum = 0;
            for (int i = 0; i < points.length; i++)
                if (i != player_seats[first])
                    sum -= (p[i] = (points[i] + 500) / 1000 - 30);

            p[player_seats[first]] = sum;

            for (int i = 0; i < p.length; i++)
            {
                print("Player[" + player_seats[i].to_string() + "] points: " + p[player_seats[i]].to_string() + "\n");
            }
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

        public bool finished { get; private set; }

        public class ServerGameResult
        {

        }
    }

    public class ServerRoundManager
    {
        private const int rounds = 2;

        private State state = State.ACTIVE;
        private ServerGameRound round;

        private int round_number = 0;
        private int dealer = 0;
        private Wind round_wind = Wind.EAST;
        private int[] player_seats;
        private int renchan = 0;

        private unowned Rand rnd;
        private DelayTimer timer = new DelayTimer();

        private ArrayList<ServerPlayer> players;
        private ArrayList<ServerPlayer> spectators;

        public ServerRoundManager(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, int[] player_seats, Rand rnd)
        {
            this.rnd = rnd;
            this.players = players;
            this.spectators = spectators;
            this.player_seats = player_seats;

            points = new int[players.size];

            for (int i = 0; i < points.length; i++)
                points[i] = 25000; // TODO: Make this dynamic

            start_round();
        }

        private void start_round()
        {
            state = State.ACTIVE;
            round = new ServerGameRound(players, spectators, player_seats, round_wind, dealer);
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
            bool do_renchan = false;

            if (round.winner != null)
            {
                if (dealer == player_seats[players.index_of(round.winner)])
                    do_renchan = true;

                if (round.loser == null)
                {
                    if (round.score.dealer)
                    {
                        for (int i = 0; i < players.size; i++)
                            if (player_seats[i] != dealer)
                                points[player_seats[i]] -= round.score.tsumo_points_higher + renchan * 100;
                    }
                    else
                    {
                        for (int i = 0; i < players.size; i++)
                        {
                            if (players.index_of(round.winner) == player_seats[i])
                                continue;
                            else if (player_seats[i] == dealer)
                                points[player_seats[i]] -= round.score.tsumo_points_higher + renchan * 100;
                            else
                                points[player_seats[i]] -= round.score.tsumo_points_lower + renchan * 100;
                        }
                    }
                }
                else
                    points[players.index_of(round.loser)] -= round.score.total_points + renchan * 300;

                points[players.index_of(round.winner)] += round.score.total_points + renchan * 300;
            }
            else
            {
                int tenpai_count = 0;
                for (int i = 0; i < round.in_tenpai.length; i++)
                    if (round.in_tenpai[i])
                        tenpai_count++;

                if (tenpai_count != 0 && tenpai_count != 4)
                    for (int i = 0; i < round.in_tenpai.length; i++)
                    {
                        if (round.in_tenpai[player_seats[i]])
                            points[player_seats[i]] += 3000 / tenpai_count;
                        else
                            points[player_seats[i]] -= 3000 / (4 - tenpai_count);
                    }


                if (round.in_tenpai[player_seats[dealer]])
                    do_renchan = true;
            }

            for (int i = 0; i < points.length; i++)
                print("Player[" + player_seats[i].to_string() + "] points: " + points[player_seats[i]].to_string() + " (" + ((Wind)((i + round_number * 3) % 4)).to_string() + ")\n");
            print("---------------------------\n");

            round = null;
            state = State.WAITING;

            if (do_renchan)
                renchan++;
            else
            {
                renchan = 0;

                round_number++;
                dealer = round_number % 4;

                if (round_number % 4 == 0)
                    round_wind = NEXT_WIND(round_wind);
            }

            bool done = round_number == 4 * rounds;

            for (int i = 0; i < points.length; i++)
                if (points[i] < 0)
                    done = true;

            if (done)
            {
                finished = true;
                return;
            }

            timer.set_time(150);
        }

        public bool finished { get; private set; }
        public int[] points { get; private set; }

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
