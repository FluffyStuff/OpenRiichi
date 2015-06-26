namespace GameServer
{
    class ServerPlayer
    {
        public signal void disconnected(ServerPlayer player);
        public signal void player_turn_decision(ServerPlayer player, GameStateTurnDecision decision);
        public signal void player_call_decision(ServerPlayer player, GameStateCallDecision decision);

        public ServerPlayer()
        {
            ready = true;
        }

        public void game_turn_decision(GameStatePlayer player, GameStateTurnDecision decision)
        {

        }

        public void game_call_decision(GameStatePlayer player, GameStateCallDecision decision)
        {

        }

        public void game_draw_tile(GameStatePlayer player, GameStateTile tile)
        {

        }

        public void game_draw_hidden(GameStatePlayer player)
        {

        }

        public State state { get; private set; }
        public bool ready { get; private set; }

        public enum State
        {
            PLAYER,
            SPECTATOR
        }
    }
}
