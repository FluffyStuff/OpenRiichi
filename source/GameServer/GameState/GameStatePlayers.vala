using Gee;

namespace GameServer
{
    class GameStatePlayers
    {
        private GameStatePlayer[] players;
        private int current_player;

        public GameStatePlayers(int dealer)
        {
            current_player = dealer;

            players = new GameStatePlayer[4];

            for (int i = 0; i < players.length; i++)
                players[i] = new GameStatePlayer(i);
        }

        public ArrayList<GameStatePlayer> get_call_players(GameStatePlayer exception, Tile tile)
        {
            ArrayList<GameStatePlayer> players = new ArrayList<GameStatePlayer>();

            foreach (GameStatePlayer player in this.players)
                if (player != exception && player.can_call(tile))
                    players.add(player);

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

        public GameStatePlayer? get_player(int ID)
        {
            foreach (GameStatePlayer p in players)
                if (p.ID == ID)
                    return p;
            return null;
        }
    }
}
