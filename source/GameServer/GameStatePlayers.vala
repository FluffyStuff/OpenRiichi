namespace GameServer
{
    class GameStatePlayers
    {
        private GameStatePlayer[] players;

        public GameStatePlayers(GameStatePlayer[] players)
        {
            this.players = players;
        }

        public bool turn_decision(GameStatePlayer player, GameStateTurnDecision decision)
        {
            return false;
        }

        public bool call_decision(GameStatePlayer player, GameStateCallDecision decision)
        {
            return false;
        }

        public bool can_call(GameStateTile tile)
        {
            return false;
        }

        public void wait_calls(GameStateTile tile)
        {

        }

        public void next_player()
        {

        }

        public void initial_draw(GameStateTile tile)
        {

        }
    }
}
