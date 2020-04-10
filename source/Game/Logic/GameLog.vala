using Engine;

public class GameLog : Serializable
{
    private GameLogRound? round;

    public GameLog(VersionInfo version, GameStartInfo start_info, ServerSettings settings)
    {
        this.version = version;
        this.start_info = start_info;
        this.settings = settings;
        rounds = new SerializableList<GameLogRound>.empty();
    }

    public static GameLog from_log(string log)
    {
        return (GameLog)Serializable.deserialize_string(log);
    }

    private void add_round(GameLogRound round)
    {
        GameLogRound[] r = rounds.to_array();

        GameLogRound[] rounds = new GameLogRound[r.length + 1];
        for (int i = 0; i < r.length; i++)
            rounds[i] = r[i];

        rounds[r.length] = round;

        this.rounds = new SerializableList<GameLogRound>(rounds);
    }

    public void start_round(RoundStartInfo info, Tile[] tiles)
    {
        if (round != null)
            end_round();

        round = new GameLogRound(info, tiles);
        add_round(round);
    }

    public void end_round()
    {
        if (round == null)
            return;

        round = null;
    }

    public void add_line(GameLogLine line)
    {
        if (round == null)
            return;

        round.add_line(line);
    }

    public VersionInfo version { get; protected set; }
    public GameStartInfo start_info { get; protected set; }
    public ServerSettings settings { get; protected set; }
    public SerializableList<GameLogRound> rounds { get; protected set; }
}

public class GameLogRound : Serializable
{
    public GameLogRound(RoundStartInfo info, Tile[]? tiles)
    {
        start_info = info;
        this.tiles = new SerializableList<Tile>(tiles);
        lines = new SerializableList<GameLogLine>.empty();
    }

    public void add_line(GameLogLine line)
    {
        GameLogLine[] l = lines.to_array();

        GameLogLine[] lines = new GameLogLine[l.length + 1];
        for (int i = 0; i < l.length; i++)
            lines[i] = l[i];

        lines[l.length] = line;

        this.lines = new SerializableList<GameLogLine>(lines);
    }

    public RoundStartInfo start_info { get; protected set; }
    public SerializableList<Tile> tiles { get; protected set; }
    public SerializableList<GameLogLine> lines { get; protected set; }
}

public class GameLogLine : Serializable
{
    public GameLogLine(float delta, ServerAction action)
    {
        this.delta = delta;
        this.action = action;
    }

    public float delta { get; protected set; }
    public ServerAction action { get; protected set; }
}