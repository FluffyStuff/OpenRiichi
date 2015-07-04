public class GameStartState
{
    public GameStartState(IGameConnection connection, GamePlayer[] players, GamePlayer? controlled_player)
    {
        this.connection = connection;
        this.players = players;
        this.controlled_player = controlled_player;
    }

    public IGameConnection connection { get; private set; }
    public GamePlayer[] players { get; private set; }
    public GamePlayer? controlled_player { get; private set; }
}
