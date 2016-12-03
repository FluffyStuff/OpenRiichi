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

    /*private static void parse(string[] log)
    {
        string version = log[0];

        for (int i = 0; i < log.length; i++)
        {
            parse_line(log[i]);
        }
    }

    private static GameLogLine parse_line(string line)
    {

    }*/

    /*private static void parse_line(string line)
    {
        int end = line.index_of("]");
        string time = line.substring(1, end - 1);

        int start = line.index_of(": \"") + 3;
        string action = line.substring(start, line.length - 1 - start);

        GameLogLine? log = null;

        if (action.index_of(StartingGameGameLogLine.TEXT) == 0)
        {
            start = StartingGameGameLogLine.TEXT.length + 1;
            end = action.length - 1;
            string p = action.substring(start, end - start);
            string[] parts = p.split(",");

            //log = new StartingGameGameLogLine();
        }
    }*/

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
    public GameLogRound(RoundStartInfo info, Tile[] tiles)
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

public abstract class GameLogLine : Serializable
{
    public GameLogLine(TimeStamp timestamp)
    {
        this.timestamp = timestamp;
    }

    public TimeStamp timestamp { get; protected set; }
}

/*public class StartingGameGameLogLine : GameLogLine
{
    public const string TEXT = "Starting game";

    public StartingGameGameLogLine(TimeStamp timestamp, GameStartInfo info, ServerSettings settings)
    {
        base(timestamp);
        this.info = info;
        this.settings = settings;
    }

    /*public string to_string()
    {
        string str = TEXT + "(";

        foreach (GamePlayer player in info.player_list.to_array())
            str += "(" + player.to_string() + ")";

        str +=
        "starting_dealer:" + info.starting_dealer.to_string() + "," +
        "starting_score:" + info.starting_score.to_string() + "," +
        "round_count:" + info.round_count.to_string()+ ","  +
        "hanchan_count:" + info.hanchan_count.to_string()+ ","  +
        "decision_time:" + info.decision_time.to_string()+ ","  +
        "round_wait_time:" + info.round_wait_time.to_string()+ ","  +
        "hanchan_wait_time:" + info.hanchan_wait_time.to_string()+ ","  +
        "game_wait_time:" + info.game_wait_time.to_string() + "," +
        "uma_higher:" + info.uma_higher.to_string() + ","  +
        "uma_lower:" + info.uma_lower.to_string() + "," +
        "open_riichi:" + settings.open_riichi.to_string() + "," +
        "aka_dora:" + settings.aka_dora.to_string() + "," +
        "multiple_ron:" + settings.multiple_ron.to_string() + "," +
        "triple_ron_draw:" + settings.triple_ron_draw.to_string() +
        ")";

        return str;
    }* /

    /*public static GameStartInfo? from_string(string str)
    {
        string[] parts = str.split(",");

        foreach (string part in parts)
        {
            if (part.index_of("(") == 0)
            {

            }
        }
    }* /

    public GameStartInfo info { get; protected set; }
    public ServerSettings settings { get; protected set; }
}

public class RoundStartGameLogLine : GameLogLine
{
    public const string text = "Round start";

    public RoundStartGameLogLine(TimeStamp timestamp, RoundStartInfo info)
    {
        base(timestamp);
        this.info = info;
    }

    public RoundStartInfo info { get; protected set; }
}*/

/*public class TileSeedsGameLogLine : GameLogLine
{
    public const string text = "TileSeeds";

    public TileSeedsGameLogLine(TimeStamp timestamp, Tile[] tiles)
    {
        base(timestamp);
        this.tiles = tiles;
    }

    public Tile[] tiles { get; protected set; }
}*/

public class DefaultTileDiscardGameLogLine : GameLogLine
{
    public const string text = "default_action";
    public const string sub_text = "Defaulting tile_discard";

    public DefaultTileDiscardGameLogLine(TimeStamp timestamp, int client, int tile)
    {
        base(timestamp);
        this.client = client;
        this.tile = tile;
    }

    public int client { get; protected set; }
    public int tile { get; protected set; }
}

public class DefaultCallActionGameLogLine : GameLogLine
{
    public const string text = "default_action";
    public const string sub_text = "Defaulting remaining call decisions";

    public DefaultCallActionGameLogLine(TimeStamp timestamp)
    {
        base(timestamp);
    }
}

public class ClientTileDiscardGameLogLine : GameLogLine
{
    public const string text = "client_tile_discard";
    public const string sub_text = "Tile discarded";

    public ClientTileDiscardGameLogLine(TimeStamp timestamp, int client, int tile)
    {
        base(timestamp);
        this.client = client;
        this.tile = tile;
    }

    public int client { get; protected set; }
    public int tile { get; protected set; }
}

public class ClientNoCallGameLogLine : GameLogLine
{
    public const string text = "client_no_call";

    public class ClientNoCallGameLogLine(TimeStamp timestamp, int client)
    {
        base(timestamp);
        this.client = client;
    }

    public int client { get; protected set; }
}

public class ClientRonGameLogLine : GameLogLine
{
    public class ClientRonGameLogLine(TimeStamp timestamp, int client)
    {
        base(timestamp);
        this.client = client;
    }

    public int client { get; protected set; }
}

public class ClientTsumoGameLogLine : GameLogLine
{
    public class ClientTsumoGameLogLine(TimeStamp timestamp, int client)
    {
        base(timestamp);
        this.client = client;
    }

    public int client { get; protected set; }
}

public class ClientVoidHandGameLogLine : GameLogLine
{
    public class ClientVoidHandGameLogLine(TimeStamp timestamp, int client)
    {
        base(timestamp);
        this.client = client;
    }

    public int client { get; protected set; }
}

public class ClientRiichiGameLogLine : GameLogLine
{
    public class ClientRiichiGameLogLine(TimeStamp timestamp, int client, bool open)
    {
        base(timestamp);
        this.client = client;
        this.open = open;
    }

    public int client { get; protected set; }
    public bool open { get; protected set; }
}

public class ClientLateKanGameLogLine : GameLogLine
{
    public class ClientLateKanGameLogLine(TimeStamp timestamp, int client, int tile)
    {
        base(timestamp);
        this.client = client;
        this.tile = tile;
    }

    public int client { get; protected set; }
    public int tile { get; protected set; }
}

public class ClientClosedKanGameLogLine : GameLogLine
{
    public class ClientClosedKanGameLogLine(TimeStamp timestamp, int client, TileType tile_type)
    {
        base(timestamp);
        this.client = client;
        this.tile_type = tile_type;
    }

    public int client { get; protected set; }
    public TileType tile_type { get; protected set; }
}

public class ClientOpenKanGameLogLine : GameLogLine
{
    public class ClientOpenKanGameLogLine(TimeStamp timestamp, int client)
    {
        base(timestamp);
        this.client = client;
    }

    public int client { get; protected set; }
}

public class ClientPonGameLogLine : GameLogLine
{
    public class ClientPonGameLogLine(TimeStamp timestamp, int client)
    {
        base(timestamp);
        this.client = client;
    }

    public int client { get; protected set; }
}

public class ClientChiiGameLogLine : GameLogLine
{
    public class ClientChiiGameLogLine(TimeStamp timestamp, int client, int tile_1, int tile_2)
    {
        base(timestamp);
        this.client = client;
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
    }

    public int client { get; protected set; }
    public int tile_1 { get; protected set; }
    public int tile_2 { get; protected set; }
}
