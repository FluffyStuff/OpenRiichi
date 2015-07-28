using GameServer;

public class GameStartState
{
    public GameStartState(IGameConnection connection, GamePlayer[] players, int player_ID, Wind round_wind, int dealer, int wall_index)
    {
        this.connection = connection;
        this.players = players;
        this.player_ID = player_ID;
        this.round_wind = round_wind;
        this.dealer = dealer;
        this.wall_index = wall_index;
    }

    public IGameConnection connection { get; private set; }
    public GamePlayer[] players { get; private set; }
    public int player_ID { get; private set; }
    public Wind round_wind { get; private set; }
    public int dealer { get; private set; }
    public int wall_index { get; private set; }
}
