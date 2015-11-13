using Gee;

public class TileRules
{
    private TileRules(){} // Static class

    public static Scoring get_score(PlayerStateContext player, RoundStateContext round)
    {
        return calculate_yaku(player, round, false);
    }

    public static bool can_ron(PlayerStateContext player, RoundStateContext round)
    {
        Scoring score = calculate_yaku(player, round, true);
        return score.valid && score.has_valid_yaku();
    }

    public static bool can_tsumo(PlayerStateContext player, RoundStateContext round)
    {
        Scoring score = calculate_yaku(player, round, true);
        return score.valid && score.has_valid_yaku();
    }

    private static Scoring calculate_yaku(PlayerStateContext player, RoundStateContext round, bool early_return)
    {
        ArrayList<Tile> hand = new ArrayList<Tile>();
        hand.add_all(player.hand);
        hand.add(round.win_tile);

        ArrayList<HandReading> readings = hand_readings(hand, false, false);
        if (readings.size == 0)
            return new Scoring.invalid();

        ArrayList<TileMeld> call_melds = new ArrayList<TileMeld>();

        foreach (RoundStateCall call in player.calls)
        {
            if (call.call_type == RoundStateCall.CallType.CHII || call.call_type == RoundStateCall.CallType.PON)
                call_melds.add(new TileMeld(call.tiles[0], call.tiles[1], call.tiles[2], false));
            else if (call.call_type == RoundStateCall.CallType.OPEN_KAN || call.call_type == RoundStateCall.CallType.LATE_KAN)
                call_melds.add(new TileMeld.kan(call.tiles[0], call.tiles[1], call.tiles[2], call.tiles[3], false));
            else if (call.call_type == RoundStateCall.CallType.CLOSED_KAN)
                call_melds.add(new TileMeld.kan(call.tiles[0], call.tiles[1], call.tiles[2], call.tiles[3], true));
        }

        Scoring? top = null;

        foreach (HandReading reading in readings)
        {
            foreach (TileMeld meld in call_melds)
                reading.add_meld(meld);

            foreach (TileMeld meld in reading.melds)
            {
                if (meld.tile_1.ID == round.win_tile.ID ||
                    meld.tile_2.ID == round.win_tile.ID ||
                    meld.tile_3.ID == round.win_tile.ID ||
                    (meld.tile_4 != null && meld.tile_4.ID == round.win_tile.ID))
                    meld.is_closed = false;
            }

            ArrayList<Yaku> yaku = Yaku.get_yaku(player, round, reading);
            Scoring score = new Scoring(round, player, reading, yaku);

            if
            (
                top == null ||
                (
                    !(top.has_valid_yaku() && !score.has_valid_yaku()) &&
                    (
                        (score.has_valid_yaku() && !top.has_valid_yaku()) ||
                        (score.total_points > top.total_points)
                    )
                )
            )
            {
                top = score;
            }
        }

        if (top == null)
            top = new Scoring.invalid();

        return top;
    }

    public static bool can_late_kan(ArrayList<Tile> hand, ArrayList<RoundStateCall> calls)
    {
        foreach (RoundStateCall call in calls)
            if (call.call_type == RoundStateCall.CallType.PON)
                foreach (Tile tile in hand)
                    if (tile.tile_type == call.tiles[0].tile_type)
                        return true;

        return false;
    }

    public static bool can_closed_kan(ArrayList<Tile> hand)
    {
        for (int i = 0; i < hand.size; i++)
        {
            int same = 0;
            for (int j = 0; j < hand.size; j++)
            {
                if (hand[i].tile_type == hand[j].tile_type)
                    same++;
            }

            if (same == 4)
                return true;
        }

        return false;
    }

    public static bool can_open_kan(ArrayList<Tile> hand, Tile tile)
    {
        int count = 0;
        for (int i = 0; i < hand.size; i++)
            if (hand[i].tile_type == tile.tile_type)
                if (++count == 3)
                    return true;
        return false;
    }

    public static bool can_pon(ArrayList<Tile> hand, Tile tile)
    {
        int count = 0;
        for (int i = 0; i < hand.size; i++)
            if (hand[i].tile_type == tile.tile_type)
                if (++count == 2)
                    return true;
        return false;
    }

    public static bool can_chii(ArrayList<Tile> hand, Tile tile)
    {
        return get_chii_groups(hand, tile).size > 0;
    }

    public static ArrayList<Tile> get_late_kan_tiles(ArrayList<Tile> hand, ArrayList<RoundStateCall> calls)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();

        foreach (RoundStateCall call in calls)
            if (call.call_type == RoundStateCall.CallType.PON)
                foreach (Tile tile in hand)
                    if (tile.tile_type == call.tiles[0].tile_type)
                    {
                        tiles.add(tile);
                        break;
                    }

        return tiles;
    }

    public static ArrayList<ArrayList<Tile>> get_closed_kan_groups(ArrayList<Tile> hand_in)
    {
        ArrayList<ArrayList<Tile>> list = new ArrayList<ArrayList<Tile>>();

        ArrayList<Tile> hand = new ArrayList<Tile>();
        hand.add_all(hand_in);

        while (hand.size > 0)
        {
            int i = 0;

            ArrayList<Tile> tiles = new ArrayList<Tile>();
            for (int j = 0; j < hand.size; j++)
            {
                if (hand[i].tile_type == hand[j].tile_type)
                    tiles.add(hand[j]);
            }

            if (tiles.size == 4)
                list.add(tiles);

            hand.remove_at(i);
        }

        return list;
    }

    public static ArrayList<ArrayList<Tile>> get_chii_groups(ArrayList<Tile> hand, Tile tile)
    {
        ArrayList<ArrayList<Tile>> list = new ArrayList<ArrayList<Tile>>();

        if (!tile.is_suit_tile())
            return list;

        ArrayList<Tile> tiles = new ArrayList<Tile>();

        foreach (Tile t in hand)
            if (tile.is_same_sort(t))
                tiles.add(t);

        Tile? m2 = null;
        Tile? m1 = null;
        Tile? p1 = null;
        Tile? p2 = null;

        int type = (int)tile.tile_type;
        foreach (Tile t in tiles)
        {
            int otype = (int)t.tile_type;

            if (otype - type == -2)
                m2 = t;
            else if (otype - type == -1)
                m1 = t;
            else if (otype - type == 1)
                p1 = t;
            else if (otype - type == 2)
                p2 = t;
        }

        if (m1 != null && p1 != null)
        {
            ArrayList<Tile> l = new ArrayList<Tile>();
            l.add(m1);
            l.add(p1);
            list.add(l);
        }

        if (m2 != null && m1 != null)
        {
            ArrayList<Tile> l = new ArrayList<Tile>();
            l.add(m2);
            l.add(m1);
            list.add(l);
        }

        if (p1 != null && p2 != null)
        {
            ArrayList<Tile> l = new ArrayList<Tile>();
            l.add(p1);
            l.add(p2);
            list.add(l);
        }

        return list;
    }

    // Selection sort
    public static ArrayList<Tile> sort_tiles(ArrayList<Tile> tiles_in)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add_all(tiles_in);

        while (true)
        {
            bool sorted = true;

            for (int i = 0; i < tiles.size - 1; i++)
            {
                if (tiles[i].tile_type > tiles[i+1].tile_type)
                {
                    Tile t = tiles[i];
                    tiles[i] = tiles[i+1];
                    tiles[i+1] = t;
                    sorted = false;
                }
            }

            if (sorted)
                break;
        }

        return tiles;
    }

    public static bool in_tenpai(ArrayList<Tile> hand)
    {
        return hand_readings(hand, true, true).size > 0;
    }

    public static bool in_furiten(ArrayList<Tile> hand, ArrayList<Tile> pond_in)
    {
        ArrayList<Tile> pond = sort_tiles(pond_in);
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add_all(hand);

        for (int i = 0; i < pond.size; i++)
        {
            Tile tile = pond[i];

            if (i != 0 && tile.tile_type == pond[i-1].tile_type) // Already checked this tile type
                continue;

            tiles.add(tile);

            if (in_tenpai(tiles))
                return true;

            tiles.remove(tile);
        }

        return false;
    }

    public static bool winning_hand(ArrayList<Tile> hand)//, ArrayList<RoundStateCall> calls)
    {
        return hand_readings(hand, false, true).size > 0;
    }

    public static ArrayList<HandReading> hand_readings(ArrayList<Tile> hand, bool tenpai_only, bool early_return)
    {
        return hand_reading_recursion(hand, new ArrayList<TileMeld>(), tenpai_only, early_return);
    }

    private static ArrayList<HandReading> hand_reading_recursion(ArrayList<Tile> remaining_tiles, ArrayList<TileMeld> melds, bool tenpai_only, bool early_return)
    {
        ArrayList<HandReading> readings = new ArrayList<HandReading>();

        // Need to copy to a new list because we are going to sort our list
        ArrayList<Tile> hand = sort_tiles(remaining_tiles);

        if ((tenpai_only && (hand.size % 3 != 1 || hand.size > 13)) || // Pons/kans/chiis remove tile count by 3, so we should always have mod 3 + 1 tiles in our tenpai hand (+2 if it's a winning hand)
            (!tenpai_only && (hand.size % 3 != 2 || hand.size > 14)))
            return readings;
        else if (hand.size == 1) // If there is a single tile left then we are in a single tile pair wait
        {
            readings.add(new HandReading.empty());
            return readings;
        }
        else if (hand.size == 2) // If we have a winning hand, then our last two tiles must be the same
        {
            if (hand[0].tile_type == hand[1].tile_type)
            {
                TilePair pair = new TilePair(hand[0], hand[1]);
                readings.add(new HandReading(melds, pair));
            }

            return readings;
        }

        if (hand.size == 13 || hand.size == 14)
        {
            // -------- Kokushi musou --------
            {
                bool[] kokushi = new bool[13];

                foreach (Tile tile in remaining_tiles)
                {
                         if (tile.tile_type == TileType.MAN1 ) kokushi[ 0] = true;
                    else if (tile.tile_type == TileType.MAN9 ) kokushi[ 1] = true;
                    else if (tile.tile_type == TileType.PIN1 ) kokushi[ 2] = true;
                    else if (tile.tile_type == TileType.PIN9 ) kokushi[ 3] = true;
                    else if (tile.tile_type == TileType.SOU1 ) kokushi[ 4] = true;
                    else if (tile.tile_type == TileType.SOU9 ) kokushi[ 5] = true;
                    else if (tile.tile_type == TileType.TON  ) kokushi[ 6] = true;
                    else if (tile.tile_type == TileType.NAN  ) kokushi[ 7] = true;
                    else if (tile.tile_type == TileType.SHAA ) kokushi[ 8] = true;
                    else if (tile.tile_type == TileType.PEI  ) kokushi[ 9] = true;
                    else if (tile.tile_type == TileType.HATSU) kokushi[10] = true;
                    else if (tile.tile_type == TileType.HAKU ) kokushi[11] = true;
                    else if (tile.tile_type == TileType.CHUN ) kokushi[12] = true;
                }

                int count = 0;
                for (int i = 0; i < kokushi.length; i++)
                    if (kokushi[i])
                        count++;

                if (hand.size - count <= 1)
                {
                    readings.add(new HandReading.kokushi(remaining_tiles));
                    return readings; // Can't be anything else
                }
            }
            // -------- /Kokushi musou --------

            // -------- Chii-toi ---------
            {
                bool same = true;
                bool offset = false;
                for (int i = 0; i < (tenpai_only ? 12 : 13); i += 2)
                    if (hand[i].tile_type != hand[i+1].tile_type)
                    {
                        if (tenpai_only && !offset)
                        {
                            offset = true;
                            i--;
                        }
                        else
                        {
                            same = false;
                            break;
                        }
                    }
                if (same)
                {
                    if (tenpai_only || early_return)
                    {
                        readings.add(new HandReading.empty());

                        if (early_return)
                            return readings;
                    }
                    else
                    {
                        ArrayList<TilePair> p = new ArrayList<TilePair>();

                        for (int i = 0; i < 14; i += 2)
                            p.add(new TilePair(hand[i], hand[i+1]));
                        readings.add(new HandReading.chiitoi(p));
                    }
                }
            }
            // -------- /Chii-toi --------
        }

        for (int i = 0; i < hand.size; i++)
        {
            if (i != 0 && hand[i].tile_type == hand[i-1].tile_type)
                continue;

            // See if we can make a triplet with our tile
            Tile tile = hand[i];

            ArrayList<Tile> copy = new ArrayList<Tile>(); // A list which contains all the tiles from our hand, minus the triplet which we are going to make
            ArrayList<Tile> meld = new ArrayList<Tile>();

            foreach (Tile t in hand)
            {
                if (meld.size < 3 && tile.tile_type == t.tile_type)
                    meld.add(t);
                else
                    copy.add(t);
            }

            if (meld.size == 3)
            {
                TileMeld m = new TileMeld(meld[0], meld[1], meld[2], true);
                melds.add(m);
                readings.add_all(hand_reading_recursion(copy, melds, tenpai_only, early_return));
                melds.remove(m);

                if (early_return && readings.size > 0)
                    return readings;
            }

            if (tile.is_suit_tile() && tile.get_number_index() <= 6)
            {
                // See if we can make a row with our tile being the lowest number (only lowest, in order to skip redundant row permutations)
                Tile? one_more = null;
                Tile? two_more = null;
                copy.clear();

                foreach (Tile t in hand)
                {
                    if (t == tile)
                        continue;
                    if (t.tile_type - tile.tile_type == 1 && one_more == null)
                        one_more = t;
                    else if (t.tile_type - tile.tile_type == 2 && two_more == null)
                        two_more = t;
                    else
                        copy.add(t);
                }

                if (one_more != null && two_more != null)
                {
                    TileMeld m = new TileMeld(tile, one_more, two_more, true);
                    melds.add(m);
                    readings.add_all(hand_reading_recursion(copy, melds, tenpai_only, early_return));
                    melds.remove(m);

                    if (early_return && readings.size > 0)
                        return readings;
                }
            }

            // Last option is to find a pair, and see if we are waiting for our last combination (this can only be if we have 4 tiles left in the hand)
            if (hand.size == 4)
            {
                // Can only happen if we are tenpai_only
                hand.remove_at(i);

                Tile? t = null;
                if (hand[0].tile_type == hand[1].tile_type)
                    t = hand[2];
                else if (hand[0].tile_type == hand[2].tile_type)
                    t = hand[1];
                else if (hand[1].tile_type == hand[2].tile_type)
                    t = hand[0];

                if (t != null)
                {
                    if ((tile.tile_type == t.tile_type) || // We have two remanining pairs
                    (tile.is_same_sort(t) && tile.is_suit_tile() && ((int)(tile.tile_type - t.tile_type)).abs() <= 2)) // We have a pair and are waiting on the final triplet
                    {
                        readings.add(new HandReading.empty());
                        return readings;
                    }
                }

                hand.insert(i, tile);
            }
        }

        return readings;
    }

    public static ArrayList<Tile> tenpai_tiles(ArrayList<Tile> hand)
    {
        ArrayList<Tile> tenpai_tiles = new ArrayList<Tile>();
        ArrayList<Tile> tiles = new ArrayList<Tile>();

        foreach (Tile tile in hand)
        {
            bool cont = false;
            foreach (Tile t in tenpai_tiles)
                if (t.tile_type == tile.tile_type)
                {
                    tenpai_tiles.add(tile);
                    cont = true;
                    break;
                }
            if (cont) // Already checked this tile type
                continue;

            tiles.clear();
            tiles.add_all(hand);
            tiles.remove(tile);

            if (in_tenpai(tiles))
                tenpai_tiles.add(tile);
        }

        return tenpai_tiles;
    }

    public static bool can_win_with(ArrayList<Tile> hand, Tile tile)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add_all(hand);
        tiles.add(tile);

        return winning_hand(tiles);
    }
}

public class RoundStateCall
{
    public RoundStateCall(CallType type, ArrayList<Tile> tiles)
    {
        call_type = type;
        this.tiles = tiles;
    }

    public CallType call_type { get; private set; }
    public ArrayList<Tile> tiles { get; private set; }

    public enum CallType
    {
        CHII,
        PON,
        OPEN_KAN,
        CLOSED_KAN,
        LATE_KAN
    }
}

public class RoundStateContext
{
    public RoundStateContext
    (
        Wind round_wind,
        ArrayList<Tile> dora,
        ArrayList<Tile> ura_dora,
        bool ron,
        Tile win_tile,
        bool last_tile,
        bool rinshan,
        bool chankan,
        bool flow_interrupted,
        bool first_turn
    )
    {
        this.round_wind = round_wind;
        this.dora = dora;
        this.ura_dora = ura_dora;
        this.ron = ron;
        this.win_tile = win_tile;
        this.last_tile = last_tile;
        this.rinshan = rinshan;
        this.chankan = chankan;
        this.flow_interrupted = flow_interrupted;
        this.first_turn = first_turn;
    }

    public string to_string()
    {
        string str =
        "round_wind: " + round_wind.to_string() + "\n" +
        "ron: " + ron.to_string() + "\n" +
        "win_wile: " + win_tile.tile_type.to_string() + "\n" +
        "last_tile: " + last_tile.to_string() + "\n" +
        "rinshan: " + rinshan.to_string() + "\n" +
        "chankan: " + chankan.to_string() + "\n" +
        "flow_interrupted: " + flow_interrupted.to_string() + "\n" +
        "first_turn: " + first_turn.to_string() + "\n";

        str += "dora: \n";
        foreach (Tile t in dora)
            str += "\t" + t.tile_type.to_string() + "\n";

        str += "ura_dora: \n";
        foreach (Tile t in ura_dora)
            str += "\t" + t.tile_type.to_string() + "\n";

        return str;
    }

    public Wind round_wind { get; private set; }
    public ArrayList<Tile> dora { get; private set; }
    public ArrayList<Tile> ura_dora { get; private set; }
    public bool ron { get; private set; }
    public Tile win_tile { get; private set; }
    public bool last_tile { get; private set; }
    public bool rinshan { get; private set; }
    public bool chankan { get; private set; }
    public bool flow_interrupted { get; private set; }
    public bool first_turn { get; private set; }
}

public class PlayerStateContext
{
    public PlayerStateContext
    (
        ArrayList<Tile> hand, // Without the winning tile
        ArrayList<Tile> pond,
        ArrayList<RoundStateCall> calls,
        Wind wind,
        bool dealer,
        bool in_riichi,
        bool double_riichi,
        bool ippatsu,
        bool tiles_called_on
    )
    {
        this.hand = hand;
        this.pond = pond;
        this.calls = calls;
        this.wind = wind;
        this.dealer = dealer;
        this.in_riichi = in_riichi;
        this.double_riichi = double_riichi;
        this.ippatsu = ippatsu;
        this.tiles_called_on = tiles_called_on;
    }

    public string to_string()
    {
        string str =
        "wind: " + wind.to_string() + "\n" +
        "dealer: " + dealer.to_string() + "\n" +
        "in_riichi: " + in_riichi.to_string() + "\n" +
        "double_riichi: " + double_riichi.to_string() + "\n" +
        "ippatsu: " + ippatsu.to_string() + "\n" +
        "tiles_called_on: " + tiles_called_on.to_string() + "\n";

        str += "hand: \n";
        foreach (Tile t in hand)
            str += "\t" + t.tile_type.to_string() + "\n";

        /*str += "pond: \n";
        foreach (Tile t in pond)
            str += "\t" + t.tile_type.to_string() + "\n";*/

        return str;
    }

    public ArrayList<Tile> hand { get; private set; }
    public ArrayList<Tile> pond { get; private set; }
    public ArrayList<RoundStateCall> calls { get; private set; }
    public Wind wind { get; private set; }
    public bool dealer { get; private set; }
    public bool in_riichi { get; private set; }
    public bool double_riichi { get; private set; }
    public bool ippatsu { get; private set; }
    public bool tiles_called_on { get; private set; }
}

public class HandReading
{
    public HandReading
    (
        ArrayList<TileMeld> melds,
        TilePair pair
    )
    {
        tiles = new ArrayList<Tile>();
        this.melds = new ArrayList<TileMeld>();
        pairs = new ArrayList<TilePair>();

        foreach (TileMeld meld in melds)
            add_meld(meld);

        pairs.add(pair);
        tiles.add(pair[0]);
        tiles.add(pair[1]);

        is_kokushi = false;
    }

    public HandReading.chiitoi(ArrayList<TilePair> pairs)
    {
        tiles = new ArrayList<Tile>();
        melds = new ArrayList<TileMeld>();
        this.pairs = new ArrayList<TilePair>();

        foreach (TilePair pair in pairs)
        {
            tiles.add(pair[0]);
            tiles.add(pair[1]);
        }

        this.pairs.add_all(pairs);
        is_kokushi = false;
    }

    public HandReading.kokushi(ArrayList<Tile> tiles)
    {
        this.tiles = tiles;
        melds = new ArrayList<TileMeld>();
        pairs = new ArrayList<TilePair>();
        is_kokushi = true;
    }

    public HandReading.empty()
    {
        tiles = new ArrayList<Tile>();
        melds = new ArrayList<TileMeld>();
        pairs = new ArrayList<TilePair>();
        is_kokushi = false;
    }

    public void add_meld(TileMeld meld)
    {
        melds.add(meld);
        tiles.add(meld[0]);
        tiles.add(meld[1]);
        tiles.add(meld[2]);
    }

    public ArrayList<Tile> tiles { get; private set; }
    public ArrayList<TileMeld> melds { get; private set; }
    public ArrayList<TilePair> pairs { get; private set; }
    public bool is_kokushi { get; private set; }
}

public class TileMeld
{
    public TileMeld(Tile tile_1, Tile tile_2, Tile tile_3, bool is_closed)
    {
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
        this.tile_3 = tile_3;
        tile_4 = null;
        this.is_closed = is_closed;
        is_kan = false;

        is_triplet = tile_1.tile_type == tile_2.tile_type && tile_2.tile_type == tile_3.tile_type;
    }

    public TileMeld.kan(Tile tile_1, Tile tile_2, Tile tile_3, Tile tile_4, bool is_closed)
    {
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
        this.tile_3 = tile_3;
        this.tile_4 = tile_4;
        this.is_closed = is_closed;
        is_kan = true;

        is_triplet = tile_1.tile_type == tile_2.tile_type && tile_2.tile_type == tile_3.tile_type;
    }

    public Tile tile_1 { get; private set; }
    public Tile tile_2 { get; private set; }
    public Tile tile_3 { get; private set; }
    public Tile? tile_4 { get; private set; }
    public bool is_triplet { get; private set; } // This is also true for kans
    public bool is_kan { get; private set; }
    public bool is_closed { get; set; }

    public Tile? get(int i)
    {
        if (i == 0)
            return tile_1;
        else if (i == 1)
            return tile_2;
        else if (i == 2)
            return tile_3;
        else if (i == 3)
            return tile_4;
        else
            return null;
    }
}

public class TilePair
{
    public TilePair(Tile tile_1, Tile tile_2)
    {
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
    }

    public Tile tile_1 { get; private set; }
    public Tile tile_2 { get; private set; }

    public Tile? get(int i)
    {
        if (i == 0)
            return tile_1;
        else if (i == 1)
            return tile_2;
        else
            return null;
    }
}

public class Scoring
{
    public Scoring(RoundStateContext round, PlayerStateContext player, HandReading hand, ArrayList<Yaku> yaku)
    {
        valid = true;
        this.hand = hand;
        this.round = round;
        this.player = player;
        this.yaku = yaku;
        ron = round.ron;
        dealer = player.dealer;
        calculate_fu();
        tsumo_points_lower = 0;
        tsumo_points_higher = 0;
        ron_points = 0;
        score_type = ScoreType.NORMAL;

        bool riichi = false;

        foreach (Yaku y in yaku)
        {
            yakuman += y.yakuman;
            han += y.han;

            if (y.yaku_type == YakuType.RIICHI)
                riichi = true;
        }

        int dora = 0;
        int ura_dora = 0;

        foreach (Tile tile in hand.tiles)
            if (tile.dora)
                dora++;

        foreach (TileMeld meld in hand.melds)
        {
            foreach (Tile d in round.dora)
                if (meld.is_kan && meld[0].tile_type == d.dora_indicator())
                    dora++;
            if (riichi)
            {
                foreach (Tile d in round.ura_dora)
                    if (meld.is_kan && meld[0].tile_type == d.dora_indicator())
                        ura_dora++;
            }
        }

        foreach (Tile tile in hand.tiles)
        {
            foreach (Tile d in round.dora)
                if (tile.tile_type == d.dora_indicator())
                    dora++;
            if (riichi)
            {
                foreach (Tile d in round.ura_dora)
                    if (tile.tile_type == d.dora_indicator())
                        ura_dora++;
            }
        }

        han += dora + ura_dora;
        if (dora > 0)
            yaku.add(new Yaku(YakuType.DORA, dora, 0));
        if (ura_dora > 0)
            yaku.add(new Yaku(YakuType.URA_DORA, ura_dora, 0));

        int basic_points;
        if (yakuman > 0)
        {
            basic_points = 8000 * yakuman;
            han = 0;
            score_type = ScoreType.YAKUMAN;
        }
        else
        {
            basic_points = fu * (4 << han);
            basic_points = int.min(basic_points, 2000);

            if (han >= 13)
            {
                basic_points = 8000;
                score_type = ScoreType.KAZOE_YAKUMAN;
            }
            else if (han >= 11)
            {
                basic_points = 6000;
                score_type = ScoreType.SANBAIMAN;
            }
            else if (han >= 8)
            {
                basic_points = 4000;
                score_type = ScoreType.BAIMAN;
            }
            else if (han >= 6)
            {
                basic_points = 3000;
                score_type = ScoreType.HANEMAN;
            }
            else if (han >= 5)
            {
                basic_points = 2000;
                score_type = ScoreType.MANGAN;
            }
        }

        if (dealer)
        {
            if (ron)
                ron_points = basic_points * 6;
            else
                tsumo_points_lower = tsumo_points_higher = basic_points * 2;
        }
        else
        {
            if (ron)
                ron_points = basic_points * 4;
            else
            {
                tsumo_points_lower  = basic_points * 1;
                tsumo_points_higher = basic_points * 2;
            }
        }

        // Round up to next 100
        tsumo_points_lower  = (tsumo_points_lower  + 99) / 100 * 100;
        tsumo_points_higher = (tsumo_points_higher + 99) / 100 * 100;
        ron_points = (ron_points + 99) / 100 * 100;

        total_points = tsumo_points_lower * 2 + tsumo_points_higher + ron_points;
    }

    public Scoring.invalid()
    {
        valid = false;
        hand = null;
        round = null;
        player = null;
        yaku = null;
        ron = false;
        dealer = false;
        tsumo_points_lower = 0;
        tsumo_points_higher = 0;
        ron_points = 0;
        total_points = 0;
        han = 0;
        fu = 0;
        yakuman = 0;
        score_type = ScoreType.NONE;
    }

    public Scoring.nagashi(bool dealer)
    {
        valid = true;
        hand = null;
        yaku = null;
        ron = false;
        this.dealer = dealer;
        han = 5;
        fu = 0;
        yakuman = 0;
        ron_points = 0;
        score_type = ScoreType.NAGASHI_MANGAN;

        if (dealer)
            tsumo_points_lower = tsumo_points_higher = 4000;
        else
        {
            tsumo_points_lower  = 2000;
            tsumo_points_higher = 4000;
        }

        total_points = 2 * tsumo_points_lower + tsumo_points_higher;
    }

    public bool has_valid_yaku()
    {
        if (yaku == null)
            return false;

        foreach (Yaku y in yaku)
            if (y.yaku_type != YakuType.DORA && y.yaku_type != YakuType.URA_DORA)
                return true;

        return false;
    }

    private void calculate_fu()
    {
        // Chiitoi
        if (hand.pairs.size == 7)
        {
            fu = 25;
            return;
        }

        fu = 0;

        WaitType wait = WaitType.NONE;
        Tile win_tile = round.win_tile;

        foreach (TileMeld meld in hand.melds)
        {
            if (meld.is_triplet)
            {
                int f = 2;
                if (meld.is_closed)
                    f *= 2;
                if (meld.is_kan)
                    f *= 4;
                if (meld[0].is_dragon_tile() || meld[0].is_wind(round.round_wind) || meld[0].is_wind(player.wind))
                    f *= 2;

                fu += f;
            }

            if (wait != WaitType.AMBIGUOUS && (meld[0].tile_type == win_tile.tile_type || meld[1].tile_type == win_tile.tile_type || meld[2].tile_type == win_tile.tile_type))
            {
                WaitType w;
                if (meld.is_triplet)
                    w = WaitType.CLOSED;
                else if (meld[1].tile_type == win_tile.tile_type)
                    w = WaitType.CLOSED;
                else if (meld[0].tile_type == win_tile.tile_type && meld[2].is_terminal_tile())
                    w = WaitType.CLOSED;
                else if (meld[2].tile_type == win_tile.tile_type && meld[0].is_terminal_tile())
                    w = WaitType.CLOSED;
                else
                    w = WaitType.OPEN;

                if ((w == WaitType.OPEN && wait == WaitType.CLOSED) ||
                    (w == WaitType.CLOSED && wait == WaitType.OPEN))
                    wait = WaitType.AMBIGUOUS;
                else
                    wait = w;
            }
        }

        if (wait == WaitType.CLOSED || wait == WaitType.NONE) // None would mean a pair wait
            fu += 2;

        Tile pair_tile = hand.pairs[0][0];
        if (pair_tile.is_dragon_tile() || pair_tile.is_wind(round.round_wind) || pair_tile.is_wind(player.wind))
            fu += 2;

        bool closed = player.calls.size == 0;

        if (fu == 0)
        {
            // Pinfu
            if (closed)
                yaku.add(new Yaku(YakuType.PINFU, 1, 0));
            else
                fu += 2; // Open pinfu is awarded 2 fu
        }
        else
        {
            if (!round.ron)
                fu += 2; // Tsumo is awarded 2 fu
            if (wait == WaitType.AMBIGUOUS)
                fu += 2;
        }

        fu += 20;

        if (closed && round.ron)
            fu += 10;

        fu = (fu + 9) / 10 * 10;
    }

    public bool valid { get; private set; }
    public HandReading hand { get; private set; }
    public RoundStateContext round { get; private set; }
    public PlayerStateContext player { get; private set; }
    public ArrayList<Yaku> yaku { get; private set; }
    public bool ron { get; private set; }
    public bool dealer { get; private set; }
    public int tsumo_points_lower { get; private set; }
    public int tsumo_points_higher { get; private set; }
    public int ron_points { get; private set; }
    public int total_points { get; private set; }
    public int han { get; private set; }
    public int fu { get; private set; }
    public int yakuman { get; private set; }
    public ScoreType score_type { get; private set; }

    public enum ScoreType
    {
        NONE,
        NORMAL,
        MANGAN,
        HANEMAN,
        BAIMAN,
        SANBAIMAN,
        KAZOE_YAKUMAN,
        YAKUMAN,
        NAGASHI_MANGAN
    }

    private enum WaitType
    {
        NONE,
        AMBIGUOUS,
        CLOSED,
        OPEN
    }
}

public class Yaku
{
    public Yaku(YakuType yaku_type, int han, int yakuman)
    {
        this.yaku_type = yaku_type;
        this.han = han;
        this.yakuman = yakuman;
    }

    public YakuType yaku_type { get; private set; }
    public int han { get; private set; }
    public int yakuman { get; private set; }

    public static bool has_yaku(PlayerStateContext player, RoundStateContext round, HandReading hand)
    {
        return get_yaku(player, round, hand).size > 0;
    }

    public static ArrayList<Yaku> get_yaku(PlayerStateContext player, RoundStateContext round, HandReading hand)
    {
        ArrayList<Yaku> yaku = new ArrayList<Yaku>();

        bool closed_hand = player.calls.size == 0;

        // TODO: Fix Chankan / Nagashi mangan

        // Nagashi mangan (Should we do this here?)
        /*{
            bool nagashi = true;
            foreach (Tile tile in player.pond)
                if (!tile.is_honour_tile() || !tile.is_terminal_tile())
                {
                    nagashi = false;
                    break;
                }

            if (nagashi)
                yaku.add(new Yaku(YakuType.NAGAGSHI_MANGAN, 5, 0));
            return yaku;
        }*/

        // Tenhou / Chiihou / Renhou
        if (round.first_turn)
        {
            if (player.dealer)
                yaku.add(new Yaku(YakuType.TENHOU, 0, 1));
            else if (!round.ron)
                yaku.add(new Yaku(YakuType.CHIIHOU, 0, 1));
            else
                yaku.add(new Yaku(YakuType.RENHOU, 0, 1));
        }

        // Kokushi musou
        if (hand.is_kokushi)
        {
            bool pair_wait = false;
            bool one = false;

            foreach (Tile tile in hand.tiles)
                if (tile.tile_type == round.win_tile.tile_type)
                {
                    if (!one)
                        one = true;
                    else
                    {
                        pair_wait = true;
                        break;
                    }
                }

            yaku.add(new Yaku(YakuType.KOKUSHI_MUSOU, 0, pair_wait ? 2 : 1));

            // Can't pair this with anything below
            return yaku;
        }

        // Tsumo
        if (closed_hand && !round.ron)
            yaku.add(new Yaku(YakuType.MENZEN_TSUMO, 1, 0));

        // Riichi / Double riichi
        if (player.in_riichi)
        {
            if (player.double_riichi)
                yaku.add(new Yaku(YakuType.DOUBLE_RIICHI, 2, 0));
            else
                yaku.add(new Yaku(YakuType.RIICHI, 1, 0));

            if (player.ippatsu)
                yaku.add(new Yaku(YakuType.IPPATSU, 1, 0));
        }

        // Haitei raoyue / Houtei raoyui
        if (round.last_tile)
        {
            if (round.ron)
                yaku.add(new Yaku(YakuType.HOUTEI_RAOYUI, 1, 0));
            else
                yaku.add(new Yaku(YakuType.HAITEI_RAOYUE, 1, 0));
        }

        // Rinshan kaihou
        if (round.rinshan)
            yaku.add(new Yaku(YakuType.RINSHAN_KAIHOU, 1, 0));

        // Chankan
        if (round.chankan)
            yaku.add(new Yaku(YakuType.CHANKAN, 1, 0));

        // Tanyao
        {
            bool tanyao = true;

            foreach (Tile tile in hand.tiles)
                if (tile.is_honor_tile() || tile.is_terminal_tile())
                {
                    tanyao = false;
                    break;
                }

            if (tanyao)
                yaku.add(new Yaku(YakuType.TANYAO, 1, 0));
        }

        // Iipeikou/Ryanpeikou
        if (closed_hand)
        {
            int count = 0;
            ArrayList<TileMeld> melds = new ArrayList<TileMeld>();
            melds.add_all(hand.melds);

            for (int i = 0; i < melds.size - 1; i++)
            {
                TileMeld m1 = melds[i];
                if (m1.is_triplet)
                    continue;

                for (int j = i + 1; j < melds.size; j++)
                {
                    TileMeld m2 = melds[j];
                    if (m2.is_triplet)
                        continue;

                    if (m1[0].tile_type == m2[0].tile_type &&
                        m1[1].tile_type == m2[1].tile_type &&
                        m1[2].tile_type == m2[2].tile_type)
                    {
                        melds.remove(m1);
                        melds.remove(m2);
                        count++;
                        break;
                    }
                }

                if (count != 0)
                    break;
            }

            if (count != 0)
            {
                if (melds.size == 2)
                {
                    TileMeld m1 = melds[0];
                    TileMeld m2 = melds[1];

                    if (m1[0].tile_type == m2[0].tile_type &&
                        m1[1].tile_type == m2[1].tile_type &&
                        m1[2].tile_type == m2[2].tile_type)
                        count++;
                }

                if (count == 1)
                    yaku.add(new Yaku(YakuType.IIPEIKOU, 1, 0));
                else
                    yaku.add(new Yaku(YakuType.RYANPEIKOU, 3, 0));
            }
        }

        // Yakuhai
        {
            int count = 0;

            foreach (TileMeld meld in hand.melds)
            {
                if (!meld.is_triplet || !meld[0].is_honor_tile())
                    continue;

                if (meld[0].is_dragon_tile())
                    count++;
                else // Wind tile
                {
                    if (meld[0].is_wind(player.wind))
                        count++;
                    if (meld[0].is_wind(round.round_wind))
                        count++;
                }
            }

            if (count > 0)
                yaku.add(new Yaku(YakuType.YAKUHAI, count, 0));
        }

        // Sanshoku doujun
        if (hand.melds.size == 4)
        {
            for (int i = 0; i < 4; i++)
            {
                TileMeld m1 = hand.melds[i];
                TileMeld m2 = hand.melds[(i + 1) % 4];
                TileMeld m3 = hand.melds[(i + 2) % 4];

                if (m1.is_triplet || m2.is_triplet || m3.is_triplet)
                    continue;

                Tile t1 = m1[0];
                Tile t2 = m2[0];
                Tile t3 = m3[0];

                if (t1.is_suit_tile() && t2.is_suit_tile() && t3.is_suit_tile() &&
                    t1.get_number_index() == t2.get_number_index() && t2.get_number_index() == t3.get_number_index() &&
                    !t1.is_same_sort(t2) && !t1.is_same_sort(t3) && !t2.is_same_sort(t3))
                {
                    yaku.add(new Yaku(YakuType.SANSHOKU_DOUJUN, closed_hand ? 2 : 1, 0));
                    break;
                }
            }
        }

        // Ittsuu
        if (hand.melds.size == 4)
        {
            for (int i = 0; i < 4 ; i++)
            {
                TileMeld m1 = hand.melds[i];
                TileMeld m2 = hand.melds[(i + 1) % 4];
                TileMeld m3 = hand.melds[(i + 2) % 4];

                if (m1.is_triplet || m2.is_triplet || m3.is_triplet)
                    continue;

                Tile t1 = m1[0];
                Tile t2 = m2[0];
                Tile t3 = m3[0];

                if (!t1.is_suit_tile() || !t2.is_suit_tile() || !t3.is_suit_tile() ||
                    !t1.is_same_sort(t2) || !t1.is_same_sort(t3))
                    continue;

                bool[] l = new bool[7];

                l[t1.tile_type - t1.get_number_index()] = true;
                l[t2.tile_type - t1.get_number_index()] = true;
                l[t3.tile_type - t1.get_number_index()] = true;

                if (l[0] && l[3] && l[6])
                {
                    yaku.add(new Yaku(YakuType.ITTSUU, closed_hand ? 2 : 1, 0));
                    break;
                }
            }
        }

        // Honroutou / Junchan / Chanta / Chinroutou
        {
            bool honroutou = true; // Only honors / terminals
            bool junchan = true; // Terminals in each set
            bool chanta = true; // Honors / terminals in each set

            foreach (TileMeld meld in hand.melds)
            {
                if (!honroutou && !junchan && !chanta)
                    break;

                Tile low = meld[0];
                Tile high = meld[2];

                if (!low.is_honor_tile() && !low.is_terminal_tile())
                    honroutou = false;
                if (!high.is_honor_tile() && !high.is_terminal_tile())
                    honroutou = false;

                if (!low.is_terminal_tile() && !high.is_terminal_tile())
                    junchan = false;

                if (!low.is_honor_tile() && !low.is_terminal_tile() &&
                    !high.is_honor_tile() && !high.is_terminal_tile())
                    chanta = false;
            }

            foreach (TilePair pair in hand.pairs)
            {
                if (!honroutou && !junchan && !chanta)
                    break;

                Tile tile = pair[0];

                if (!tile.is_honor_tile() && !tile.is_terminal_tile())
                    honroutou = false;

                if (!tile.is_terminal_tile())
                    junchan = false;

                if (!tile.is_honor_tile() && !tile.is_terminal_tile())
                    chanta = false;
            }

            if (honroutou && junchan)
                yaku.add(new Yaku(YakuType.CHINROUTOU, 0, 1));
            else if (honroutou)
                yaku.add(new Yaku(YakuType.HONROUTOU, 4, 0));
            else if (junchan)
                yaku.add(new Yaku(YakuType.JUNCHAN, closed_hand ? 3 : 2, 0));
            else if (chanta)
                yaku.add(new Yaku(YakuType.CHANTA, closed_hand ? 2 : 1, 0));
        }

        // Toitoi / San ankou / Suu ankou / San kantsu / Suu kantsu
        if (hand.melds.size == 4)
        {
            int closed_count = 0;
            int kan_count = 0;
            bool toitoi = true;

            foreach (TileMeld meld in hand.melds)
            {
                if (!meld.is_triplet)
                {
                    toitoi = false;
                    continue;
                }

                if (meld.is_closed)
                    closed_count++;

                if (meld.is_kan)
                    kan_count++;
            }

            if (toitoi && closed_count == 4)
                yaku.add(new Yaku(YakuType.SUU_ANKOU, 0, 1));
            else
            {
                if (toitoi)
                    yaku.add(new Yaku(YakuType.TOITOI, 2, 0));
                if (closed_count == 3)
                    yaku.add(new Yaku(YakuType.SAN_ANKOU, 2, 0));
            }

            if (kan_count == 4)
                yaku.add(new Yaku(YakuType.SUU_KANTSU, 0, 1));
            else if (kan_count == 3)
                yaku.add(new Yaku(YakuType.SAN_KANTSU, 2, 0));
        }

        // Sanshoku doukou
        if (hand.melds.size == 4)
        {
            for (int i = 0; i < 4; i++)
            {
                TileMeld m1 = hand.melds[i];
                TileMeld m2 = hand.melds[(i + 1) % 4];
                TileMeld m3 = hand.melds[(i + 2) % 4];

                if (!m1.is_triplet || !m2.is_triplet || !m3.is_triplet)
                    continue;

                Tile t1 = m1[0];
                Tile t2 = m2[0];
                Tile t3 = m3[0];

                // Don't need to check for unique sorts, since there can only be a single triplet of a suit number
                if (t1.is_suit_tile() && t2.is_suit_tile() && t3.is_suit_tile() &&
                    t1.get_number_index() == t2.get_number_index() && t2.get_number_index() == t3.get_number_index())
                {
                    yaku.add(new Yaku(YakuType.SANSHOKU_DOUKOU, 2, 0));
                    break;
                }
            }
        }

        // Chiitoi
        if (hand.pairs.size == 7)
            yaku.add(new Yaku(YakuType.CHIITOI, 2, 0));

        // Shou sangen / Dai sangen
        {
            int count = 0;

            foreach (TileMeld meld in hand.melds)
                if (meld[0].is_dragon_tile())
                    count++;

            if (count == 3)
                yaku.add(new Yaku(YakuType.DAI_SANGEN, 0, 1));
            else if (count == 2 && hand.pairs[0][0].is_dragon_tile())
                yaku.add(new Yaku(YakuType.SHOU_SANGEN, 2, 0));
        }

        // Honitsu / Chinitsu
        {
            bool chin = true;
            bool hon = true;

            for (int i = 0; i < hand.tiles.size; i++)
            {
                if (hand.tiles[i].is_honor_tile())
                {
                    chin = false;
                    continue;
                }

                for (int j = i + 1; j < hand.tiles.size; j++)
                {
                    if (hand.tiles[j].is_honor_tile())
                    {
                        chin = false;
                        continue;
                    }

                    if (!hand.tiles[i].is_same_sort(hand.tiles[j]))
                    {
                        chin = false;
                        hon = false;
                        break;
                    }
                }

                break;
            }

            if (chin)
                yaku.add(new Yaku(YakuType.CHINITSU, closed_hand ? 6 : 5, 0));
            else if (hon)
                yaku.add(new Yaku(YakuType.HONITSU, closed_hand ? 3 : 2, 0));
        }

        // Shou suushii / Dai suushii
        if (hand.melds.size == 4)
        {
            int count = 0;

            foreach (TileMeld meld in hand.melds)
                if (meld[0].is_wind_tile())
                    count++;

            if (count == 4)
                yaku.add(new Yaku(YakuType.DAI_SUUSHII, 0, 2));
            else if (count == 3)
            {
                if (hand.pairs[0][0].is_wind_tile())
                    yaku.add(new Yaku(YakuType.SHOU_SUUSHII, 0, 1));
            }
        }

        // Chuuren poutou
        if (closed_hand)
        {
            bool chuuren = true;
            Tile tile = hand.tiles[0];

            for (int i = 1; i < hand.tiles.size; i++)
            {
                Tile t = hand.tiles[1];

                if (!t.is_suit_tile() || !tile.is_same_sort(t))
                {
                    chuuren = false;
                    break;
                }
            }

            if (chuuren)
            {
                int counts[9];

                foreach (Tile t in hand.tiles)
                    counts[t.get_number_index()]++;

                for (int i = 0; i < 9; i++)
                    if (counts[i] == 0)
                    {
                        chuuren = false;
                        break;
                    }
                if (counts[0] < 3 || counts[8] < 3)
                    chuuren = false;

                if (chuuren)
                {
                    bool pair_wait = counts[round.win_tile.get_number_index()] > 0;
                    yaku.add(new Yaku(YakuType.CHUUREN_POUTOU, 0, pair_wait ? 2 : 1));
                }
            }
        }

        // Ryuuiisou
        {
            bool ryuu = true;

            foreach (Tile tile in hand.tiles)
            {
                if (tile.tile_type != TileType.SOU2 &&
                    tile.tile_type != TileType.SOU3 &&
                    tile.tile_type != TileType.SOU4 &&
                    tile.tile_type != TileType.SOU6 &&
                    tile.tile_type != TileType.SOU8 &&
                    tile.tile_type != TileType.HATSU)
                {
                    ryuu = false;
                    break;
                }
            }

            if (ryuu)
                yaku.add(new Yaku(YakuType.RYUUIISOU, 0, 1));
        }

        // Tsuu iisou
        {
            bool tsuu = false;

            foreach (Tile tile in hand.tiles)
            {
                if (!tile.is_honor_tile())
                {
                    tsuu = false;
                    break;
                }
            }

            if (tsuu)
                yaku.add(new Yaku(YakuType.TSUU_IISOU, 0, 1));
        }

        return yaku;
    }
}

public enum YakuType // Han
{
    // Yaku situations
    MENZEN_TSUMO, // Closed tsumo
    RIICHI, // Reach
    IPPATSU, // One-shot
    DOUBLE_RIICHI, // Double reach
    HAITEI_RAOYUE, // Last tile tsumo
    HOUTEI_RAOYUI, // Last tile ron
    RINSHAN_KAIHOU, // Out on extra tile
    CHANKAN, // Robbing a quad
    NAGASHI_MANGAN, // Honorable discards

    // Yaku hands
    PINFU, // No points
    TANYAO, // All simples
    IIPEIKOU, // Double sequence
    YAKUHAI, // Special tiles
    SANSHOKU_DOUJUN, // Three color sequence
    ITTSUU, // Straight
    CHANTA, // Terminals or honours in each set
    HONROUTOU, // Terminals or honours
    TOITOI, // All triplets
    SAN_ANKOU, // Three concealed triplets
    SAN_KANTSU, // Three quads
    SANSHOKU_DOUKOU, // Three colour triplets
    CHIITOI, // Seven pairs
    SHOU_SANGEN, // Little three dragons
    HONITSU, // Half flush
    JUNCHAN, // Terminal in each set
    RYANPEIKOU, // Two double sequences
    CHINITSU, // Full flush

    // Yakuman situations
    TENHOU, // Heavenly hand
    CHIIHOU, // Earthly hand
    RENHOU, // Hand of man

    // Yakuman hands
    KOKUSHI_MUSOU, // Thirteen orphans
    DAI_SANGEN, // Big four winds
    SHOU_SUUSHII, // Little four winds
    DAI_SUUSHII, // Big four winds
    CHUUREN_POUTOU, // Nine gates
    SUU_ANKOU, // Four concealed triplets
    RYUUIISOU, // All green
    SUU_KANTSU, // Four kans
    TSUU_IISOU, // All honours
    CHINROUTOU, // All terminals

    // Dora
    DORA,
    URA_DORA
}
