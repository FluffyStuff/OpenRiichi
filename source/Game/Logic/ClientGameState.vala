using Gee;

public class ClientGameState
{
    private Tile[] tiles = new Tile[136];
    private int player_ID;
    private ClientGameStatePlayer[] players = new ClientGameStatePlayer[4];

    public ClientGameState(int player_ID)
    {
        this.player_ID = player_ID;
        discard_tile = null;

        for (int i = 0; i < players.length; i++)
            players[i] = new ClientGameStatePlayer(i);

        for (int i = 0; i < tiles.length; i++)
            tiles[i] = new Tile(i, TileType.BLANK, false);
    }

    public void tile_assign(Tile tile)
    {
        Tile t = tiles[tile.ID];
        t.tile_type = tile.tile_type;
        t.dora = tile.dora;
    }

    public void tile_draw(int player_ID, int tile_ID)
    {
        players[player_ID].draw(tiles[tile_ID]);
    }

    public void tile_discard(int player_ID, int tile_ID)
    {
        Tile tile = tiles[tile_ID];
        ClientGameStatePlayer player = players[player_ID];
        player.discard(tile);

        discard_tile = tile;
        discard_player = player;
    }

    public void late_kan(int player_ID, int tile_ID)
    {
        ClientGameStatePlayer player = get_player(player_ID);
        player.do_late_kan(get_tile(tile_ID));
    }

    public void closed_kan(int player_ID, TileType tile_type)
    {
        ClientGameStatePlayer player = get_player(player_ID);
        player.do_closed_kan(tile_type);
    }

    public void open_kan(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID)
    {
        ClientGameStatePlayer player = get_player(player_ID);
        ClientGameStatePlayer discarder = get_player(discarding_player_ID);

        Tile tile = get_tile(tile_ID);
        Tile tile_1 = get_tile(tile_1_ID);
        Tile tile_2 = get_tile(tile_2_ID);
        Tile tile_3 = get_tile(tile_3_ID);
        discarder.rob_tile(tile);

        player.do_open_kan(tile, tile_1, tile_2, tile_3);
    }

    public void pon(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        ClientGameStatePlayer player = get_player(player_ID);
        ClientGameStatePlayer discarder = get_player(discarding_player_ID);

        Tile tile = get_tile(tile_ID);
        Tile tile_1 = get_tile(tile_1_ID);
        Tile tile_2 = get_tile(tile_2_ID);
        discarder.rob_tile(tile);

        player.do_pon(tile, tile_1, tile_2);
    }

    public void chi(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        ClientGameStatePlayer player = get_player(player_ID);
        ClientGameStatePlayer discarder = get_player(discarding_player_ID);

        Tile tile = get_tile(tile_ID);
        Tile tile_1 = get_tile(tile_1_ID);
        Tile tile_2 = get_tile(tile_2_ID);
        discarder.rob_tile(tile);

        player.do_chi(tile, tile_1, tile_2);
    }

    public bool can_chi(Tile tile, ClientGameStatePlayer player, ClientGameStatePlayer discard_player)
    {
        return ((discard_player.seat + 1) % 4 == player.seat) && TileRules.can_chi(player.hand, tile);
    }

    public ClientGameStatePlayer get_player(int player_ID)
    {
        return players[player_ID];
    }

    public Tile get_tile(int tile_ID)
    {
        return tiles[tile_ID];
    }

    public ClientGameStatePlayer self { get { return players[player_ID]; } }

    public Tile? discard_tile { get; private set; }
    public ClientGameStatePlayer? discard_player { get; private set; }
}

public class ClientGameStatePlayer
{
    public ClientGameStatePlayer(int seat)
    {
        this.seat = seat;
        hand = new ArrayList<Tile>();
        pond = new ArrayList<Tile>();
        calls = new ArrayList<GameStateCall>();
    }

    public bool has_tile(Tile tile)
    {
        foreach (Tile t in hand)
            if (t.ID == tile.ID)
                return true;
        return false;
    }

    public void draw(Tile tile)
    {
        hand.add(tile);
    }

    public void discard(Tile tile)
    {
        hand.remove(tile);
        pond.add(tile);
    }

    public void rob_tile(Tile tile)
    {
        pond.remove(tile);
    }

    public void do_late_kan(Tile tile)
    {
        hand.remove(tile);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(tile);

        foreach (GameStateCall call in calls)
        {
            if (call.call_type == GameStateCall.CallType.PON)
                if (call.tiles[0].tile_type == tile.tile_type)
                {
                    calls.remove(call);
                    tiles.add_all(call.tiles);
                    break;
                }
        }

        calls.add(new GameStateCall(GameStateCall.CallType.LATE_KAN, tiles));
    }

    public void do_closed_kan(TileType type)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        for (int i = 0; i < hand.size; i++)
            if (hand[i].tile_type == type)
                tiles.add(hand.remove_at(i--));

        calls.add(new GameStateCall(GameStateCall.CallType.CLOSED_KAN, tiles));
    }

    public void do_open_kan(Tile discard_tile, Tile tile_1, Tile tile_2, Tile tile_3)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);
        hand.remove(tile_3);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);
        tiles.add(tile_3);

        calls.add(new GameStateCall(GameStateCall.CallType.OPEN_KAN, tiles));
    }

    public void do_pon(Tile discard_tile, Tile tile_1, Tile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);

        calls.add(new GameStateCall(GameStateCall.CallType.PON, tiles));
    }

    public void do_chi(Tile discard_tile, Tile tile_1, Tile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);

        calls.add(new GameStateCall(GameStateCall.CallType.CHI, tiles));
    }

    public ArrayList<Tile> get_late_kan_tiles(Tile tile)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();

        for (int i = 0; i < calls.size; i++)
        {
            GameStateCall call = calls[i];

            if (call.call_type == GameStateCall.CallType.PON)
            {
                if (call.tiles[0].tile_type == tile.tile_type)
                {
                    tiles.add_all(call.tiles);
                    break;
                }
            }
        }

        return tiles;
    }

    public int seat { get; private set; }
    public ArrayList<Tile> hand { get; private set; }
    public ArrayList<Tile> pond { get; private set; }
    public ArrayList<GameStateCall> calls { get; private set; }
}
