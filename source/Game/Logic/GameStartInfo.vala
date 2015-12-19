using GameServer;

public class GameStartInfo : Serializable
{
    public GameStartInfo
    (
        GamePlayer[] players,
        int starting_dealer,
        int starting_score,
        int round_count,
        int hanchan_count,
        int decision_time,
        int round_wait_time,
        int hanchan_wait_time,
        int game_wait_time,
        int uma_higher,
        int uma_lower
    )
    {
        player_list = new SerializableList<GamePlayer>(players);
        this.starting_dealer = starting_dealer;
        this.starting_score = starting_score;
        this.round_count = round_count;
        this.hanchan_count = hanchan_count;
        this.decision_time = decision_time;
        this.round_wait_time = round_wait_time;
        this.hanchan_wait_time = hanchan_wait_time;
        this.game_wait_time = game_wait_time;
        this.uma_higher = uma_higher;
        this.uma_lower = uma_lower;
    }

    public GamePlayer[] get_players()
    {
        return player_list.to_array();
    }

    public int starting_dealer { get; protected set; }
    public int starting_score { get; protected set; }
    public int round_count { get; protected set; }
    public int hanchan_count { get; protected set; }
    public int decision_time { get; protected set; }
    public int round_wait_time { get; protected set; }
    public int hanchan_wait_time { get; protected set; }
    public int game_wait_time { get; protected set; }
    public int uma_higher { get; protected set; }
    public int uma_lower { get; protected set; }

    public SerializableList<GamePlayer> player_list { get; protected set; }
}

public class RoundStartInfo : Serializable
{
    public RoundStartInfo(int wall_index)
    {
        this.wall_index = wall_index;
    }

    public int wall_index { get; protected set; }
}
