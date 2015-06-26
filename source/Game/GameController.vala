public class GameController
{
    private View view;
    private GameState? game;
    private IGameRenderer renderer;

    public GameController(View view, GameStartState game_start)
    {
        this.view = view;

        GameRenderView renderer = new GameRenderView();
        view.add_child(renderer);
        this.renderer = renderer;

        if (game_start.controlled_player != null)
            create_game(game_start);
    }

    private void create_game(GameStartState game_start)
    {
        game = new GameState(game_start);


    }
}

public class GameState
{
    public GameState(GameStartState state)
    {

    }
}

public class GameStartState
{
    public IGameConnection connection { get; private set; }
    public GamePlayer[] players { get; private set; }
    public GamePlayer? controlled_player { get; private set; }
}

public abstract class IGameConnection
{

}

public class GamePlayer
{

}
