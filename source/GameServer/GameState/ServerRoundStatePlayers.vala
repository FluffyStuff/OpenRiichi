using Gee;

namespace GameServer
{
    class ServerRoundStatePlayers
    {
        private int current_player;

        public ServerRoundStatePlayers(int dealer)
        {
            current_player = dealer;

            players = new ServerRoundStatePlayer[4];

            for (int i = 0; i < players.length; i++)
                players[i] = new ServerRoundStatePlayer(i, (Wind)((4 - dealer + i) % 4), i == dealer);
        }

        public ArrayList<ServerRoundStatePlayer> get_call_players(ServerRoundStatePlayer caller, RoundStateContext context)
        {
            ArrayList<ServerRoundStatePlayer> players = new ArrayList<ServerRoundStatePlayer>();

            Tile tile = context.win_tile;

            foreach (ServerRoundStatePlayer player in this.players)
                if (player != caller &&
                    (player.can_ron(context) ||
                     player.can_pon(tile) ||
                    (((caller.index + 1) % 4 == player.index) && player.can_chii(tile))))
                        players.add(player);

            return players;
        }

        public ArrayList<ServerRoundStatePlayer> get_tenpai_players()
        {
            ArrayList<ServerRoundStatePlayer> players = new ArrayList<ServerRoundStatePlayer>();

            foreach (ServerRoundStatePlayer player in this.players)
                if (player.in_tenpai())
                    players.add(player);

            return players;
        }

        public void next_player()
        {
            current_player = (current_player + 1) % players.length;
        }

        public ServerRoundStatePlayer get_current_player()
        {
            return players[current_player];
        }

        public void set_current_player(ServerRoundStatePlayer player)
        {
            current_player = player.index;
        }

        public ServerRoundStatePlayer? get_player(int index)
        {
            foreach (ServerRoundStatePlayer p in players)
                if (p.index == index)
                    return p;
            return null;
        }

        public void clear_calls()
        {
            foreach (ServerRoundStatePlayer player in players)
            {
                player.state = ServerRoundStatePlayer.PlayerState.DONE;
                player.call_decision = null;
            }
        }

        public ServerRoundStatePlayer[] players { get; private set; }

        public int count { get { return players.length; } }
    }
}
