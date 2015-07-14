using Gee;

namespace GameServer
{
    class GameStatePlayers
    {
        private int current_player;

        public GameStatePlayers(int dealer)
        {
            current_player = dealer;

            players = new GameStatePlayer[4];

            for (int i = 0; i < players.length; i++)
                players[i] = new GameStatePlayer(i);
        }

        public ArrayList<GameStatePlayer> get_call_players(GameStatePlayer caller, Tile tile)
        {
            ArrayList<GameStatePlayer> players = new ArrayList<GameStatePlayer>();

            foreach (GameStatePlayer player in this.players)
                if (player != caller &&
                    (player.can_ron(tile) ||
                     player.can_pon(tile) ||
                    (((caller.ID + 1) % 4 == player.ID) && player.can_chi(tile))))
                    {
                        if (player.ID != 0)
                        players.add(player);
                    }

            return players;
        }

        public void next_player()
        {
            current_player = (current_player + 1) % players.length;
        }

        public GameStatePlayer get_current_player()
        {
            return players[current_player];
        }

        public void set_current_player(GameStatePlayer player)
        {
            current_player = player.ID;
        }

        public GameStatePlayer? get_player(int ID)
        {
            foreach (GameStatePlayer p in players)
                if (p.ID == ID)
                    return p;
            return null;
        }

        public void clear_calls()
        {
            foreach (GameStatePlayer player in players)
            {
                player.state = GameStatePlayer.PlayerState.DONE;
                player.call_decision = null;
            }
        }

        public GameStatePlayer[] players { get; private set; }
    }
}
