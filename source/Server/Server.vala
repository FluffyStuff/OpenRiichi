class Server
{
    private GameStateServerPlayer[] players;
    private GameStateGame game;

    public Server()
    {

    }

    public void create_game(ServerPlayer[] players)
    {
        if (players != null)
            foreach (GameStateServerPlayer p in this.players)
                unsubscribe_player(p.server_player);

        this.players = new GameStateServerPlayer[players.length];
        GameStatePlayer[] gsplayers = new GameStatePlayer[players.length];

        for (int i = 0; i < players.length; i++)
        {
            GameStatePlayer gsp = new GameStatePlayer();
            GameStateServerPlayer player = new GameStateServerPlayer(players[i], gsp);
            subscribe_player(player.server_player);
            this.players[i] = player;
        }

        GameStateBoardTiles tiles = new GameStateBoardTiles();
        GameStatePlayers p = new GameStatePlayers(gsplayers);

        game = new GameStateGame(tiles, p);
        game.game_turn_decision.connect(game_state_turn_decision);
        game.game_call_decision.connect(game_state_call_decision);
        game.game_draw_tile.connect(game_state_draw_tile);
    }

    private void subscribe_player(ServerPlayer player)
    {
        player.player_turn_decision.connect(player_turn_decision);
        player.player_call_decision.connect(player_call_decision);
    }

    private void unsubscribe_player(ServerPlayer player)
    {
        player.player_turn_decision.disconnect(player_turn_decision);
        player.player_call_decision.disconnect(player_call_decision);
    }

    private void player_turn_decision(ServerPlayer player, GameStateTurnDecision decision)
    {
        GameStateServerPlayer p = get_gssp(players, player);
        if (p != null && p.game_state_player != null)
            game.player_turn_decision(p.game_state_player, decision);
    }

    private void player_call_decision(ServerPlayer player, GameStateCallDecision decision)
    {
        GameStateServerPlayer p = get_gssp(players, player);
        if (p != null && p.game_state_player != null)
            game.player_call_decision(p.game_state_player, decision);
    }

    private static GameStateServerPlayer? get_gssp(GameStateServerPlayer[] players, ServerPlayer player)
    {
        foreach (GameStateServerPlayer p in players)
            if (p.server_player == player)
                return p;
        return null;
    }

    private void game_state_turn_decision(GameStatePlayer player, GameStateTurnDecision decision)
    {
        foreach (GameStateServerPlayer p in players)
            p.server_player.game_turn_decision(player, decision);
    }

    private void game_state_call_decision(GameStatePlayer player, GameStateCallDecision decision)
    {
        foreach (GameStateServerPlayer p in players)
            p.server_player.game_call_decision(player, decision);
    }

    private void game_state_draw_tile(GameStatePlayer player, GameStateTile tile)
    {
        foreach (GameStateServerPlayer p in players)
            if (p.game_state_player == player || p.server_player.state != ServerPlayer.State.PLAYER)
                p.server_player.game_draw_tile(player, tile);
            else
                p.server_player.game_draw_hidden(player);
    }

    private class GameStateServerPlayer
    {
        public GameStateServerPlayer(ServerPlayer sp, GameStatePlayer gsp)
        {
            server_player = sp;
            game_state_player = gsp;
        }

        public ServerPlayer server_player { get; private set; }
        public GameStatePlayer game_state_player { get; private set; }
    }
}
