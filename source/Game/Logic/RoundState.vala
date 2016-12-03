using Gee;

public class RoundState : Object
{
    private ServerSettings settings;
    private int current_index;
    private int player_index;
    private int[] winner_indices;
    private RoundStatePlayer[] players = new RoundStatePlayer[4];
    private RoundStateWall wall;

    private bool flow_interrupted = false;
    private int turn_counter = 1;
    private bool rinshan = false;

    public RoundState(ServerSettings settings, int player_index, Wind round_wind, int dealer, int wall_index, bool[] can_riichi)
    {
        init(false, settings, player_index, round_wind, dealer, wall_index, null, can_riichi, false, null);
    }

    public RoundState.server(ServerSettings settings, Wind round_wind, int dealer, int wall_index, Random rnd, bool[] can_riichi)
    {
        init(true, settings, -1, round_wind, dealer, wall_index, rnd, can_riichi, true, null);
    }

    public RoundState.custom(ServerSettings settings, Wind round_wind, int dealer, int wall_index, bool[] can_riichi, Tile[] tiles)
    {
        init(false, settings, -1, round_wind, dealer, wall_index, null, can_riichi, true, tiles);
    }

    private void init(bool shuffled, ServerSettings settings, int player_index, Wind round_wind, int dealer, int wall_index, Random? rnd, bool[] can_riichi, bool revealed, Tile[]? tiles)
    {
        this.settings = settings;
        this.player_index = player_index;
        this.round_wind = round_wind;
        this.dealer = current_index = dealer;

        if (shuffled)
        {
            /* For testing purposes
            TileType[] p1 = new TileType[]
            {
                TileType.MAN6,
                TileType.MAN6,
                TileType.MAN7,
                TileType.MAN8,
                TileType.PIN7,
                TileType.PIN8,
                TileType.PIN9,
                TileType.SOU5,
                TileType.SOU6,
                TileType.SOU7,
                TileType.HATSU,
                TileType.HATSU,
                TileType.HATSU,
            };

            TileType[] p2 = new TileType[]
            {
            };

            TileType[] p3 = new TileType[]
            {
            };

            TileType[] p4 = new TileType[]
            {
            };


            TileType[] draw_wall = new TileType[]
            {
                TileType.BLANK,
                TileType.HATSU,
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.PIN1,
            };


            TileType[] dead_wall = new TileType[]
            {
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.HAKU,
                TileType.BLANK,
                TileType.BLANK,
                TileType.BLANK,
                TileType.PIN1,
            };

            wall = new RoundStateWall.seeded(dealer, wall_index, settings.aka_dora == Options.OnOffEnum.ON, true, rnd, p1, p2, p3, p4, draw_wall, dead_wall);
            /*/
            wall = new RoundStateWall.shuffled(dealer, wall_index, settings.aka_dora == Options.OnOffEnum.ON, rnd);
            //*/
        }
        else if (tiles != null)
            wall = new RoundStateWall.custom(dealer, wall_index, tiles);
        else
            wall = new RoundStateWall(dealer, wall_index);
        discard_tile = null;

        for (int i = 0; i < players.length; i++)
            players[i] = new RoundStatePlayer(i, i == dealer, (Wind)((i - dealer + 4) % 4), can_riichi[i], i == player_index || revealed);

        game_draw_type = GameDrawType.NONE;
        chankan_call = ChankanCall.NONE;
        riichi_return_index = -1;
    }

    public void start()
    {
        for (int i = 0; i < 3; i++)
        {
            for (int p = 0; p < 4; p++)
            {
                RoundStatePlayer player = current_player;

                for (int t = 0; t < 4; t++)
                {
                    Tile tile = wall.draw_wall();
                    player.draw_initial(tile);
                }

                current_index = (current_index + 1) % players.length;
            }
        }

        for (int p = 0; p < 4; p++)
        {
            RoundStatePlayer player = current_player;
            Tile tile = wall.draw_wall();
            player.draw_initial(tile);
            current_index = (current_index + 1) % players.length;
        }
    }

    public void tile_assign(Tile tile)
    {
        Tile t = get_tile(tile.ID);
        t.tile_type = tile.tile_type;
        t.dora = tile.dora;
    }

    public void calls_finished()
    {
        if (chankan_call == ChankanCall.NONE)
        {
            if (wall.empty)
            {
                game_over = true;
                game_draw_type = GameDrawType.EMPTY_WALL;
                return;
            }

            bool four_riichi = true;
            bool diff = false;
            int count = 0;

            foreach (RoundStatePlayer player in players)
            {
                if (!player.in_riichi)
                    four_riichi = false;

                if ((count += player.get_kan_count()) != 4)
                    diff = true;
            }

            if (count == 4 && diff) // Four kans game draw
            {
                game_over = true;
                game_draw_type = GameDrawType.FOUR_KANS;
                return;
            }

            if (four_riichi) // Four riichi game draw
            {
                game_over = true;
                game_draw_type = GameDrawType.FOUR_RIICHI;
                return;
            }

            if (turn_counter == 4 && !flow_interrupted)
            {
                bool four_winds = true;
                for (int i = 0; i < players.length; i++)
                {
                    if (players[i].pond.size != 1 ||
                       !players[i].pond[0].is_wind_tile() ||
                        players[i].pond[0].tile_type != players[0].pond[0].tile_type)
                    {
                        four_winds = false;
                        break;
                    }
                }

                if (four_winds) // Four winds game draw
                {
                    game_over = true;
                    game_draw_type = GameDrawType.FOUR_WINDS;
                    return;
                }
            }

            current_index = (current_index + 1) % players.length;
        }
        else
            kan();

        check_temporary_furiten();

        turn_counter++;
        riichi_return_index = -1;
        chankan_call = ChankanCall.NONE;
    }

    public void void_hand()
    {
        game_over = true;
        game_draw_type = GameDrawType.VOID_HAND;
        return;
    }

    public void triple_ron()
    {
        game_over = true;
        game_draw_type = GameDrawType.TRIPLE_RON;
        return;
    }

    public Tile tile_draw()
    {
        Tile tile = wall.draw_wall();
        current_player.draw(tile);

        return tile;
    }

    public Tile tile_draw_dead_wall()
    {
        Tile tile = wall.draw_dead_wall();
        current_player.draw(tile);

        return tile;
    }

    public bool tile_discard(int tile_ID)
    {
        Tile tile = get_tile(tile_ID);
        RoundStatePlayer player = current_player;
        if (!player.discard(tile))
            return false;

        discard_tile = tile;
        rinshan = false;
        chankan_call = ChankanCall.NONE;

        return true;
    }

    public void flip_dora()
    {
        wall.flip_dora();
    }

    public void ron(int[] player_indices)
    {
        game_over = true;
        winner_indices = player_indices;
    }

    public void tsumo()
    {
        game_over = true;
    }

    public bool riichi(bool open)
    {
        if (!can_riichi())
            return false;

        riichi_return_index = current_player.index;
        current_player.do_riichi(open);
        return true;
    }

    public ArrayList<Tile>? late_kan(int tile_ID)
    {
        if (!can_late_kan_with(tile_ID))
            return null;

        Tile tile = get_tile(tile_ID);

        var kan_tiles = current_player.do_late_kan(tile);
        chankan_call = ChankanCall.LATE;
        discard_tile = tile;

        return kan_tiles;
    }

    public ArrayList<Tile>? closed_kan(TileType tile_type)
    {
        if (!can_closed_kan_with(tile_type))
            return null;

        var tiles = current_player.do_closed_kan(tile_type);
        assert(tiles.size == 4);

        chankan_call = ChankanCall.CLOSED;
        discard_tile = tiles[0];
        //interrupt_flow(); // TODO: Find out whether this is correct

        return tiles;
    }

    public void open_kan(int player_index, int tile_1_ID, int tile_2_ID, int tile_3_ID)
    {
        RoundStatePlayer player = get_player(player_index);
        RoundStatePlayer discarder = current_player;

        Tile tile = discard_tile;
        Tile tile_1 = get_tile(tile_1_ID);
        Tile tile_2 = get_tile(tile_2_ID);
        Tile tile_3 = get_tile(tile_3_ID);
        discarder.rob_tile(tile);

        player.do_open_kan(discarder.index, tile, tile_1, tile_2, tile_3);

        current_index = player_index;
        kan();

        check_temporary_furiten();
    }

    public void pon(int player_index, int tile_1_ID, int tile_2_ID)
    {
        RoundStatePlayer player = get_player(player_index);
        RoundStatePlayer discarder = current_player;

        Tile tile = discard_tile;
        Tile tile_1 = get_tile(tile_1_ID);
        Tile tile_2 = get_tile(tile_2_ID);
        discarder.rob_tile(tile);

        player.do_pon(discarder.index, tile, tile_1, tile_2);

        interrupt_flow();
        current_index = player_index;

        check_temporary_furiten();
    }

    public void chii(int player_index, int tile_1_ID, int tile_2_ID)
    {
        RoundStatePlayer player = get_player(player_index);
        RoundStatePlayer discarder = current_player;

        Tile tile = discard_tile;
        Tile tile_1 = get_tile(tile_1_ID);
        Tile tile_2 = get_tile(tile_2_ID);
        discarder.rob_tile(tile);

        player.do_chii(discarder.index, tile, tile_1, tile_2);

        interrupt_flow();
        current_index = player_index;

        check_temporary_furiten();
    }

    public Scoring[]? get_ron_score()
    {
        if (winner_indices == null)
            return null;

        Scoring[] scores = new Scoring[winner_indices.length];
        RoundStateContext context = create_context(true, discard_tile);

        for (int i = 0; i < scores.length; i++)
            scores[i] = get_player(winner_indices[i]).get_ron_score(context);

        return scores;
    }

    public Scoring get_tsumo_score()
    {
        RoundStatePlayer player = current_player;
        return player.get_tsumo_score(create_context(false, player.newest_tile));
    }

    public bool can_void_hand()
    {
        return !flow_interrupted && turn_counter <= 4 && TileRules.can_void_hand(current_player.hand);
    }

    public bool can_ron(RoundStatePlayer player)
    {
        if (player == current_player)
            return false;

        if (!player.can_ron(create_context(true, discard_tile)))
            return false;

        if (chankan_call == ChankanCall.CLOSED)
            return player.can_closed_chankan(discard_tile);

        return true;
    }

    public bool can_tsumo()
    {
        RoundStatePlayer player = current_player;
        return player.can_tsumo(create_context(false, player.newest_tile));
    }

    public bool can_riichi()
    {
        return wall.can_riichi && current_player.can_riichi();
    }

    public bool can_late_kan_with(int tile_ID)
    {
        return wall.can_call && wall.can_kan && current_player.can_late_kan_with(get_tile(tile_ID));
    }

    public bool can_closed_kan_with(TileType type)
    {
        return wall.can_call && wall.can_kan && current_player.can_closed_kan_with(type);
    }

    public bool can_late_kan()
    {
        return wall.can_call && wall.can_kan && current_player.can_late_kan();
    }

    public bool can_closed_kan()
    {
        return wall.can_call && wall.can_kan && current_player.can_closed_kan();
    }

    public bool can_open_kan(RoundStatePlayer player)
    {
        return
            wall.can_call &&
            wall.can_kan &&
            !player.in_riichi &&
            player != current_player &&
            chankan_call == ChankanCall.NONE &&
            TileRules.can_open_kan(player.hand, discard_tile);
    }

    public bool can_pon(RoundStatePlayer player)
    {
        return
            wall.can_call &&
            !player.in_riichi &&
            player != current_player &&
            chankan_call == ChankanCall.NONE &&
            TileRules.can_pon(player.hand, discard_tile);
    }

    public bool can_chii(RoundStatePlayer player)
    {
        return
            wall.can_call &&
            ((current_player.index + 1) % 4 == player.index) &&
            chankan_call == ChankanCall.NONE &&
            player.can_chii(discard_tile);
    }

    public bool can_chii_with(RoundStatePlayer player, Tile tile_1, Tile tile_2)
    {
        return can_chii(player) && player.can_chii_with(tile_1, tile_2, discard_tile);
    }

    public ArrayList<ArrayList<Tile>> get_chii_groups(RoundStatePlayer player)
    {
        return player.get_chii_groups(discard_tile);
    }

    public ArrayList<Tile> get_tenpai_tiles(RoundStatePlayer player)
    {
        return TileRules.tenpai_tiles(player.hand, player.calls);
    }

    public RoundStatePlayer get_player(int player_index)
    {
        assert(player_index >= 0 && player_index < players.length);
        return players[player_index];
    }

    public Tile get_tile(int tile_ID)
    {
        return wall.get_tile(tile_ID);
    }

    public int[] get_nagashi_indices()
    {
        ArrayList<int> indices = new ArrayList<int>();

        if (game_over && game_draw_type == GameDrawType.EMPTY_WALL)
        {
            foreach (RoundStatePlayer player in players)
                if (player.has_nagashi_mangan())
                    indices.add(player.index);
        }

        return indices.to_array();
    }

    public ArrayList<RoundStatePlayer> get_tenpai_players()
    {
        ArrayList<RoundStatePlayer> players = new ArrayList<RoundStatePlayer>();

        foreach (RoundStatePlayer player in this.players)
            if (player.in_tenpai())
                players.add(player);

        return players;
    }

    private void check_temporary_furiten()
    {
        if (discard_tile != null)
            foreach (var player in players)
                player.check_temporary_furiten(discard_tile, chankan_call == ChankanCall.CLOSED);
    }

    private void interrupt_flow()
    {
        foreach (RoundStatePlayer player in players)
            player.flow_interrupted();
        flow_interrupted = true;
        riichi_return_index = -1;
    }

    private void kan()
    {
        rinshan = true;
        wall.flip_dora();
        tile_draw_dead_wall();
        interrupt_flow();
    }

    private RoundStateContext create_context(bool ron, Tile win_tile)
    {
        bool last_tile = wall.empty;
        bool chankan = chankan_call != ChankanCall.NONE && ron;

        return new RoundStateContext
        (
            round_wind,
            wall.dora,
            wall.ura_dora,
            ron,
            win_tile,
            last_tile,
            rinshan && !ron,
            chankan,
            flow_interrupted
        );
    }

    public RoundStatePlayer self { get { return players[player_index]; } }
    public Tile? discard_tile { get; private set; }
    public RoundStatePlayer current_player { get { return players[current_index]; } }
    public int dealer { get; private set; }
    public Wind round_wind { get; private set; }
    public bool game_over { get; private set; }
    public GameDrawType game_draw_type { get; private set; }
    public Tile[] tiles { get { return wall.tiles; } }
    public Tile newest_dora { get { return wall.newest_dora; } }
    public ArrayList<Tile> ura_dora { get { return wall.ura_dora; } }
    public bool tiles_empty { get { return wall.empty; } }
    public ChankanCall chankan_call { get; private set; }
    public int riichi_return_index { get; private set; }
}

public class RoundStatePlayer
{
    private bool revealed;
    private bool double_riichi = false;
    private bool do_riichi_discard = false;
    private bool do_chii_discard = false;
    private bool do_pon_discard = false;
    private bool ippatsu = false;
    private bool dealer;
    private bool tiles_called_on = false;
    private bool temporary_furiten = false;
    private bool _can_riichi;

    private int sekinin_rinshan_index = -1;
    private int sekinin_index = -1;

    public RoundStatePlayer(int index, bool dealer, Wind wind, bool can_riichi, bool revealed)
    {
        this.index = index;
        this.dealer = dealer;
        this.wind = wind;
        _can_riichi = can_riichi;
        this.revealed = revealed;

        hand = new ArrayList<Tile>();
        pond = new ArrayList<Tile>();
        calls = new ArrayList<RoundStateCall>();
        in_riichi = false;
        first_turn = true;
    }

    public bool has_tile(Tile tile)
    {
        foreach (Tile t in hand)
            if (t.ID == tile.ID)
                return true;
        return false;
    }

    public void draw_initial(Tile tile)
    {
        hand.add(tile);
    }

    public void draw(Tile tile)
    {
        hand.add(tile);

        if (!in_riichi)
            temporary_furiten = false;
    }

    public bool discard(Tile tile)
    {
        if (!can_discard(tile))
            return false;

        hand.remove(tile);
        pond.add(tile);

        if (do_riichi_discard)
            do_riichi_discard = false;
        else
            ippatsu = false;

        first_turn = false;
        do_chii_discard = false;
        do_pon_discard = false;
        sekinin_rinshan_index = -1;

        return true;
    }

    public void rob_tile(Tile tile)
    {
        //pond.remove(tile); // Don't need to do this
        tiles_called_on = true;
    }

    public void check_temporary_furiten(Tile tile, bool closed_chankan)
    {
        ArrayList<Tile> hand = new ArrayList<Tile>();
        hand.add_all(this.hand);
        hand.add(tile);

        if (TileRules.winning_hand(hand, calls))
        {
            if (!closed_chankan || can_closed_chankan(tile))
                temporary_furiten = true;
        }
    }

    public void flow_interrupted()
    {
        ippatsu = false;
        first_turn = false;
    }

    public void do_riichi(bool open)
    {
        in_riichi = true;
        this.open = open;
        ippatsu = true;
        do_riichi_discard = true;

        if (first_turn)
            double_riichi = true;
    }

    public ArrayList<Tile>? do_late_kan(Tile tile)
    {
        if (!can_late_kan_with(tile))
            return null;

        hand.remove(tile);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(tile);
        int discarder_index = index;

        foreach (RoundStateCall call in calls)
        {
            if (call.call_type == RoundStateCall.CallType.PON)
                if (call.tiles[0].tile_type == tile.tile_type)
                {
                    calls.remove(call);
                    tiles.add_all(call.tiles);
                    discarder_index = call.discarder_index;
                    break;
                }
        }

        calls.add(new RoundStateCall(RoundStateCall.CallType.LATE_KAN, tiles, tile, discarder_index));
        return tiles;
    }

    public ArrayList<Tile>? do_closed_kan(TileType type)
    {
        if (!can_closed_kan_with(type))
            return null;

        ArrayList<Tile> tiles = get_closed_kan_tiles(type);

        foreach (Tile tile in tiles)
            hand.remove(tile);

        calls.add(new RoundStateCall(RoundStateCall.CallType.CLOSED_KAN, tiles, null, index));
        return tiles;
    }

    public void do_open_kan(int discarder_index, Tile discard_tile, Tile tile_1, Tile tile_2, Tile tile_3)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);
        hand.remove(tile_3);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);
        tiles.add(tile_3);

        RoundStateCall new_call = new RoundStateCall(RoundStateCall.CallType.OPEN_KAN, tiles, discard_tile, discarder_index);
        if (TileRules.is_sekinin(calls, new_call, discard_tile))
            sekinin_index = discarder_index;
        sekinin_rinshan_index = discarder_index;

        calls.add(new_call);
    }

    public void do_pon(int discarder_index, Tile discard_tile, Tile tile_1, Tile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);

        RoundStateCall new_call = new RoundStateCall(RoundStateCall.CallType.PON, tiles, discard_tile, discarder_index);
        if (TileRules.is_sekinin(calls, new_call, discard_tile))
            sekinin_index = discarder_index;

        calls.add(new_call);
        do_pon_discard = true;
    }

    public void do_chii(int discarder_index, Tile discard_tile, Tile tile_1, Tile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);

        RoundStateCall new_call = new RoundStateCall(RoundStateCall.CallType.CHII, tiles, discard_tile, discarder_index);
        if (TileRules.is_sekinin(calls, new_call, discard_tile))
            sekinin_index = discarder_index;

        calls.add(new_call);
        do_chii_discard = true;

    }

    public ArrayList<Tile> get_discard_tiles()
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        if (in_riichi)
        {
            tiles.add(newest_tile);
            return tiles;
        }

        foreach (Tile tile in hand)
            if (can_discard(tile))
                tiles.add(tile);

        return tiles;
    }

    public ArrayList<Tile> get_late_kan_tiles(Tile tile)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();

        for (int i = 0; i < calls.size; i++)
        {
            RoundStateCall call = calls[i];

            if (call.call_type == RoundStateCall.CallType.PON)
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

    public ArrayList<Tile>? get_closed_kan_tiles(TileType type)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        foreach (Tile tile in hand)
            if (tile.tile_type == type)
                tiles.add(tile);

        if (tiles.size != 4)
            tiles.clear();
        return tiles;
    }

    public Scoring get_ron_score(RoundStateContext context)
    {
        return TileRules.get_score(create_context(false), context);
    }

    public Scoring get_tsumo_score(RoundStateContext context)
    {
        return TileRules.get_score(create_context(true), context);
    }

    public bool can_discard(Tile tile)
    {
        if (!has_tile(tile) ||
            (in_riichi && !do_riichi_discard && tile.ID != newest_tile.ID))
            return false;

        // Kuikae check
        if (do_chii_discard)
        {
            ArrayList<Tile> open_tiles = new ArrayList<Tile>();
            open_tiles.add_all(newest_call.tiles);
            open_tiles.remove(newest_call.call_tile);

            if (TileRules.can_chii(open_tiles, tile))
                return false;
        }
        else if (do_pon_discard)
        {
            if (tile.tile_type == newest_call.tiles[0].tile_type)
                return false;
        }

        return true;
    }

    public bool can_ron(RoundStateContext context)
    {
        return !in_furiten() && TileRules.can_ron(create_context(false), context);
    }

    public bool can_closed_chankan(Tile tile)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add_all(hand);
        tiles.add(tile);

        return TileRules.can_closed_chankan(tiles, calls);
    }

    public bool can_tsumo(RoundStateContext context)
    {
        return !do_chii_discard && !do_pon_discard && TileRules.can_tsumo(create_context(true), context);
    }

    public bool can_riichi()
    {
        if (!_can_riichi || in_riichi)
            return false;

        foreach (RoundStateCall call in calls)
            if (call.call_type != RoundStateCall.CallType.CLOSED_KAN)
                return false;

        return TileRules.tenpai_tiles(hand, calls).size > 0;
    }

    public bool can_late_kan()
    {
        if (do_chii_discard || do_pon_discard || in_riichi)
            return false;

        return TileRules.can_late_kan(hand, calls);
    }

    public bool can_late_kan_with(Tile tile)
    {
        return can_late_kan() && get_late_kan_tiles(tile).size > 0;
    }

    public bool can_closed_kan()
    {
        if (do_chii_discard || do_pon_discard)
            return false;

        return !revealed || TileRules.can_closed_kan(hand, calls, in_riichi);
    }

    public bool can_closed_kan_with(TileType type)
    {
        return can_closed_kan() && get_closed_kan_tiles(type).size > 0;
    }

    public bool can_chii(Tile discard_tile)
    {
        if (in_riichi)
            return false;

        return get_chii_groups(discard_tile).size > 0;
    }

    public bool can_chii_with(Tile tile_1, Tile tile_2, Tile discard_tile)
    {
        if (in_riichi)
            return false;

        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add(tile_1);
        tiles.add(tile_2);

        if (!TileRules.can_chii(tiles, discard_tile))
            return false;

        foreach (Tile tile in hand)
        {
            if (tile == tile_1 || tile == tile_2)
                continue;

            if (!TileRules.can_chii(tiles, tile))
                return true;
        }

        return false;
    }

    public bool in_furiten()
    {
        return temporary_furiten || TileRules.in_furiten(hand, calls, pond);
    }

    public ArrayList<ArrayList<Tile>> get_chii_groups(Tile discard_tile)
    {
        ArrayList<ArrayList<Tile>> groups = TileRules.get_chii_groups(hand, discard_tile);

        for (int i = 0; i < groups.size; i++)
        {
            ArrayList<Tile> group = groups[i];
            if (!can_chii_with(group[0], group[1], discard_tile))
                groups.remove_at(i--);
        }

        return groups;
    }

    public ArrayList<ArrayList<Tile>> get_closed_kan_groups()
    {
        return TileRules.get_closed_kan_groups(hand, calls, in_riichi);
    }

    public int get_kan_count()
    {
        int count = 0;
        foreach (RoundStateCall call in calls)
            if (call.call_type == RoundStateCall.CallType.OPEN_KAN ||
                call.call_type == RoundStateCall.CallType.CLOSED_KAN ||
                call.call_type == RoundStateCall.CallType.LATE_KAN)
                count++;

        return count;
    }

    public Tile get_default_discard_tile()
    {
        ArrayList<Tile> tiles = get_discard_tiles();
        return tiles[tiles.size - 1];
    }

    public bool has_nagashi_mangan()
    {
        return !tiles_called_on && calls.size == 0 && TileRules.is_nagashi_mangan(pond);
    }

    public bool in_tenpai()
    {
        return TileRules.in_tenpai(hand, calls);
    }

    private PlayerStateContext create_context(bool tsumo)
    {
        ArrayList<Tile> hand = new ArrayList<Tile>();
        hand.add_all(this.hand);
        if (tsumo)
            hand.remove(newest_tile);

        int sekinin = sekinin_rinshan_index;
        if (sekinin_index != -1)
            sekinin = sekinin_index;

        return new PlayerStateContext
        (
            index,
            hand,
            pond,
            calls,
            wind,
            dealer,
            in_riichi,
            double_riichi,
            open,
            ippatsu,
            tiles_called_on,
            first_turn,
            sekinin
        );
    }

    public int index { get; private set; }
    public Wind wind { get; private set; }
    public ArrayList<Tile> hand { get; private set; }
    public ArrayList<Tile> pond { get; private set; }
    public ArrayList<RoundStateCall> calls { get; private set; }
    public bool in_riichi { get; private set; }
    public bool open { get; private set; } // Open riichi
    public bool first_turn { get; private set; }
    public Tile newest_tile { owned get { return hand[hand.size - 1]; } }
    public RoundStateCall newest_call { owned get { return calls[calls.size - 1]; } }
}

class RoundStateWall
{
    private ArrayList<Tile> wall_tiles = new ArrayList<Tile>();
    private ArrayList<Tile> dead_wall_tiles = new ArrayList<Tile>();
    private int dora_index = 4;

    public RoundStateWall(int dealer, int wall_index)
    {
        init(dealer, wall_index, false, null, false, false, null, null, null, null, null, null, null);
    }

    public RoundStateWall.shuffled(int dealer, int wall_index, bool aka_dora, Random rnd)
    {
        init(dealer, wall_index, aka_dora, rnd, true, false, null, null, null, null, null, null, null);
    }

    public RoundStateWall.seeded(int dealer, int wall_index, bool aka_dora, bool shuffle, Random? rnd, TileType[] p1_tiles, TileType[] p2_tiles, TileType[] p3_tiles, TileType[] p4_tiles, TileType[] draw_tiles, TileType[] dead_wall)
    {
        init(dealer, wall_index, aka_dora, rnd, shuffle, true, null, p1_tiles, p2_tiles, p3_tiles, p4_tiles, draw_tiles, dead_wall);
    }

    public RoundStateWall.custom(int dealer, int wall_index, Tile[] tiles)
    {
        init(dealer, wall_index, false, null, false, false, tiles, null, null, null, null, null, null);
    }

    private void init(int dealer, int wall_index, bool aka_dora, Random? rnd, bool shuffled, bool seeded, Tile[]? custom_tiles, TileType[]? p1_tiles, TileType[]? p2_tiles, TileType[]? p3_tiles, TileType[]? p4_tiles, TileType[]? draw_tiles, TileType[]? dead_wall)
    {
        if (custom_tiles != null)
            tiles = custom_tiles;
        else
            tiles = new Tile[136];

        dora = new ArrayList<Tile>();
        ura_dora = new ArrayList<Tile>();

        if (custom_tiles == null)
        {
            for (int i = 0; i < tiles.length; i++)
            {
                TileType type = (shuffled && !seeded) ? (TileType)((i / 4) + 1) : TileType.BLANK;
                tiles[i] = new Tile(-1, type, false);
            }
        }

        int start_wall = (4 - dealer) % 4;
        int index = start_wall * 34 + wall_index * 2;

        if (seeded)
            seed(index, rnd, tiles, p1_tiles, p2_tiles, p3_tiles, p4_tiles, draw_tiles, dead_wall);
        else if (shuffled)
            shuffle(tiles, rnd);

        if ((shuffled || seeded) && aka_dora)
        {
            ArrayList<Tile> five_man = new ArrayList<Tile>();
            ArrayList<Tile> five_pin = new ArrayList<Tile>();
            ArrayList<Tile> five_sou = new ArrayList<Tile>();

            foreach (Tile tile in tiles)
            {
                if (tile.tile_type == TileType.MAN5)
                    five_man.add(tile);
                else if (tile.tile_type == TileType.PIN5)
                    five_pin.add(tile);
                else if (tile.tile_type == TileType.SOU5)
                    five_sou.add(tile);
            }

            five_man[rnd.int_range(0, five_man.size - 1)].dora = true;
            five_pin[rnd.int_range(0, five_pin.size - 1)].dora = true;
            five_sou[rnd.int_range(0, five_sou.size - 1)].dora = true;
        }

        for (int i = 0; i < tiles.length; i++)
            tiles[i].ID = i;

        for (int i = 0; i < 122; i++)
        {
            int t = (index + i) % 136;
            wall_tiles.add(tiles[t]);
        }

        for (int i = 0; i < 14; i++)
        {
            int t = (index + i + 122) % 136;
            if (i % 2 == 0)
                t++;
            else
                t--;

            dead_wall_tiles.insert(0, tiles[t]);
        }

        flip_dora();
    }

    public Tile flip_dora()
    {
        assert(dead_wall_tiles.size > dora_index + 1);

        Tile tile = dead_wall_tiles[dora_index];
        dora.add(tile);
        ura_dora.add(dead_wall_tiles[dora_index + 1]);

        dora_index += 2;

        newest_dora = tile;
        return tile;
    }

    public Tile draw_wall()
    {
        assert(wall_tiles.size > 0);

        return wall_tiles.remove_at(0);
    }

    public Tile draw_dead_wall()
    {
        assert(dead_wall_tiles.size > 0);

        Tile tile = dead_wall_tiles.remove_at(0);
        dead_tile_add();
        dora_index--;
        return tile;
    }

    private Tile dead_tile_add()
    {
        Tile tile = wall_tiles.remove_at(wall_tiles.size - 1);
        dead_wall_tiles.insert(dead_wall_tiles.size, tile);
        return tile;
    }

    public Tile? get_tile(int tile_ID)
    {
        assert(tile_ID >= 0 && tile_ID < tiles.length);

        foreach (Tile tile in tiles)
            if (tile.ID == tile_ID)
                return tile;
        return null;
    }

    private static void shuffle(Tile[] tiles, Random rnd)
    {
        for (int i = 0; i < tiles.length; i++)
        {
            int tmp = rnd.int_range(0, tiles.length);
            Tile t = tiles[i];
            tiles[i] = tiles[tmp];
            tiles[tmp] = t;
        }
    }

    private static void seed(int index, Random? rnd, Tile[] tiles, TileType[] p1_tiles, TileType[] p2_tiles, TileType[] p3_tiles, TileType[] p4_tiles, TileType[] draw_tiles, TileType[] dead_wall)
    {
        ArrayList<TileType> unassigned = new ArrayList<TileType>();
        for (int i = 0; i < tiles.length; i++)
            unassigned.add((TileType)((i / 4) + 1));

        int length = tiles.length;

        for (int i = 0; i < 4; i++)
        {
            for (int j = 0; j < 4; j++)
            {
                int a = i * 4 + j;

                if (p1_tiles.length > a)
                    replace(tiles, p1_tiles[a], unassigned, index);
                index++;
                length--;

                if (a >= 12)
                    break;
            }

            for (int j = 0; j < 4; j++)
            {
                int a = i * 4 + j;
                if (p2_tiles.length > a)
                    replace(tiles, p2_tiles[a], unassigned, index);
                index++;
                length--;

                if (a >= 12)
                    break;
            }

            for (int j = 0; j < 4; j++)
            {
                int a = i * 4 + j;
                if (p3_tiles.length > a)
                    replace(tiles, p3_tiles[a], unassigned, index);
                index++;
                length--;

                if (a >= 12)
                    break;
            }

            for (int j = 0; j < 4; j++)
            {
                int a = i * 4 + j;
                if (p4_tiles.length > a)
                    replace(tiles, p4_tiles[a], unassigned, index);
                index++;
                length--;

                if (a >= 12)
                    break;
            }
        }

        for (int i = 0; i < draw_tiles.length; i++)
        {
            replace(tiles, draw_tiles[i], unassigned, index++);
            length--;
        }

        index += length - 14;

        for (int i = 0; i < dead_wall.length; i++)
            replace(tiles, dead_wall[i], unassigned, index++);

        foreach (Tile t in tiles)
            if (t.tile_type == TileType.BLANK)
            {
                assert(unassigned.size > 0);
                t.tile_type = unassigned.remove_at(rnd.int_range(0, unassigned.size));
            }
    }

    private static void replace(Tile[] tiles, TileType tile_type, ArrayList<TileType> unassigned, int index)
    {
        if (tile_type == TileType.BLANK)
            return;

        index = index % tiles.length;

        for (int i = 0; i < unassigned.size; i++)
            if (unassigned[i] == tile_type)
            {
                tiles[index].tile_type = unassigned.remove_at(i);
                return;
            }

        Environment.log(LogType.GAME, "RoundStateWall", "RoundState seed, did not find " + tile_type.to_string());
    }

    public bool empty { get { return wall_tiles.size == 0; } }
    public bool can_kan { get { return dora.size < 5; } }
    public bool can_call { get { return wall_tiles.size > 0; } }
    public bool can_riichi { get { return wall_tiles.size >= 4; } }
    public Tile newest_dora { get; private set; }
    public ArrayList<Tile> dora { get; private set; }
    public ArrayList<Tile> ura_dora { get; private set; }
    public Tile[] tiles { get; private set; }
}

public enum GameDrawType
{
    NONE,
    EMPTY_WALL,
    FOUR_WINDS,
    FOUR_KANS,
    FOUR_RIICHI,
    VOID_HAND,
    TRIPLE_RON
}

public enum ChankanCall
{
    NONE,
    LATE,
    CLOSED
}
