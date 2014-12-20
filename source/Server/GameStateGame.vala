class GameStateGame
{
    public signal void game_turn_decision(GameStatePlayer player, GameStateTurnDecision decision);
    public signal void game_call_decision(GameStatePlayer player, GameStateCallDecision decision);
    public signal void game_draw_tile(GameStatePlayer player, GameStateTile tile);

    private GameState current_state = GameState.WAITING_TURN;
    private GameStateBoardTiles tiles;
    private GameStatePlayers players;

    // Whether the standard game flow has been interrupted
    private bool flow_interrupted = false;

    public GameStateGame(GameStateBoardTiles tiles, GameStatePlayers players)
    {
        this.tiles = tiles;
        this.players = players;

        initial_draw();
    }

    public bool player_turn_decision(GameStatePlayer player, GameStateTurnDecision decision)
    {
        if (current_state != GameState.WAITING_TURN)
            return false;

        if (!players.turn_decision(player, decision))
            return false;

        if (decision.DecisionType == GameStateTurnDecision.TurnDecision.TSUMO)
            current_state = GameState.FINISHED;
        else if (decision.DecisionType == GameStateTurnDecision.TurnDecision.DISCARD)
        {
            if (players.can_call(decision.Tile))
            {
                current_state = GameState.WAITING_CALLS;
                players.wait_calls(decision.Tile);
            }
            else
                players.next_player();
        }

        return true;
    }

    public bool player_call_decision(GameStatePlayer player, GameStateCallDecision decision)
    {
        if (current_state != GameState.WAITING_CALLS)
            return false;

        if (!players.call_decision(player, decision))
            return false;

        if (decision.DecisionType == GameStateCallDecision.CallDecision.RON)
            current_state = GameState.FINISHED;
        else if (decision.DecisionType != GameStateCallDecision.CallDecision.NONE)
            flow_interrupted = true;

        return true;
    }

    private void initial_draw()
    {
        // Start initial wall drawing
        for (int i = 0; i < 2; i++)
        {
            for (int p = 0; p < 4; p++)
            {
                for (int t = 0; t < 4; t++)
                {
                    GameStateTile tile = tiles.draw();
                    players.initial_draw(tile);
                }
            }
        }

        for (int p = 0; p < 4; p++)
        {
            for (int t = 0; t < 4; t++)
            {
                GameStateTile tile = tiles.draw();
                players.initial_draw(tile);
            }
        }
    }

    private enum GameState
    {
        WAITING_CALLS,
        WAITING_TURN,
        FINISHED
    }
}
