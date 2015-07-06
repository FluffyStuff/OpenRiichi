public class GameController
{
    private GameStartState state;
    private GameState? game;
    private IGameRenderer renderer;
    private IGameConnection connection;

    public GameController(View parent_view, GameStartState game_start)
    {
        this.state = game_start;

        GameRenderView renderer = new GameRenderView(game_start);
        parent_view.add_child(renderer);
        this.renderer = renderer;
        connection = game_start.connection;

        if (game_start.player_ID != -1)
        {
            create_game(game_start);
            game.send_message.connect(connection.send_message);
            renderer.tile_selected.connect(game.tile_selected);
        }
    }

    public void process()
    {
        ServerMessage message;
        while ((message = connection.dequeue_message()) != null)
        {
            renderer.receive_message(message);

            if (game != null)
                game.receive_message(message);
        }
    }

    private void create_game(GameStartState game_start)
    {
        game = new GameState(game_start);
    }
}
