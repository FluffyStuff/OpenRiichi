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

        ArrayList<HandReading> readings = hand_readings(hand, player.calls, false, false);
        if (readings.size == 0)
            return new Scoring.invalid();

        Scoring? top = null;

        foreach (HandReading reading in readings)
        {
            if (round.ron)
            {
                foreach (TileMeld meld in reading.melds)
                {
                    if (meld.tile_1.ID == round.win_tile.ID ||
                        meld.tile_2.ID == round.win_tile.ID ||
                        meld.tile_3.ID == round.win_tile.ID ||
                        (meld.tile_4 != null && meld.tile_4.ID == round.win_tile.ID))
                        meld.is_closed = false;
                }
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

    public static bool can_late_kan(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls)
    {
        foreach (RoundStateCall call in calls)
            if (call.call_type == RoundStateCall.CallType.PON)
                foreach (Tile tile in hand)
                    if (tile.tile_type == call.tiles[0].tile_type)
                        return true;

        return false;
    }

    public static bool can_closed_kan(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls, bool in_riichi)
    {
        return get_closed_kan_groups(hand, calls, in_riichi).size > 0;
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

    public static ArrayList<Tile> get_late_kan_tiles(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls)
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

    public static ArrayList<ArrayList<Tile>> get_closed_kan_groups(ArrayList<Tile> hand_in, ArrayList<RoundStateCall>? calls, bool in_riichi)
    {
        ArrayList<ArrayList<Tile>> list = new ArrayList<ArrayList<Tile>>();

        ArrayList<Tile> hand = new ArrayList<Tile>();
        hand.add_all(hand_in);

        while (hand.size > 0)
        {
            ArrayList<Tile> tiles = new ArrayList<Tile>();
            for (int j = 0; j < hand.size; j++)
            {
                if (hand[0].tile_type == hand[j].tile_type)
                    tiles.add(hand[j]);
            }

            if (tiles.size == 4)
                list.add(tiles);

            hand.remove_at(0);
        }

        if (in_riichi && list.size > 0)
        {
            for (int i = 0; i < list.size; i++)
            {
                hand.clear();
                hand.add_all(hand_in);
                hand.remove(list[i][0]);
                ArrayList<HandReading> readings = hand_readings(hand, calls, true, false);

                if (readings.size == 0)
                {
                    list.remove_at(i--);
                    continue;
                }

                foreach (HandReading reading in readings)
                {
                    TileType type = list[i][0].tile_type;
                    bool found = false;

                    if (!reading.is_kokushi && reading.pairs.size == 1)
                    {
                        foreach (TileMeld meld in reading.melds)
                        {
                            if (!meld.is_triplet &&
                            (
                                meld.tile_1.tile_type == type ||
                                meld.tile_2.tile_type == type ||
                                meld.tile_3.tile_type == type)
                            )
                            {
                                found = true;
                                break;
                            }
                        }

                        if (reading.pairs[0].tile_1.tile_type == type)
                            found = true;
                    }
                    else
                        found = true;

                    if (found)
                    {
                        list.remove_at(i--);
                        break;
                    }
                }
            }
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

    public static bool in_furiten(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls, ArrayList<Tile> pond_in)
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

            if (winning_hand(tiles, calls))
                return true;

            tiles.remove(tile);
        }

        return false;
    }

    public static bool can_void_hand(ArrayList<Tile> hand_in)
    {
        ArrayList<Tile> hand = sort_tiles(hand_in);

        int count = 0;
        for (int i = 0; i < hand.size; i++)
        {
            Tile tile = hand[i];
            if (i != 0 && hand[i - 1].tile_type == tile.tile_type)
                continue;
            if (tile.is_terminal_tile() || tile.is_honor_tile())
                count++;
        }

        return count >= 9;
    }

    public static bool is_sekinin(ArrayList<RoundStateCall> calls, RoundStateCall new_call, Tile call_tile)
    {
        int wind_calls = 0;
        int dragon_calls = 0;
        int kans = 0;

        foreach (RoundStateCall call in calls)
        {
            Tile t = call.tiles[0];
            if (t.is_wind_tile())
                wind_calls++;
            else if (t.is_dragon_tile())
                dragon_calls++;
            if (call.tiles.size == 4) // If is kan
                kans++;
        }

        if (wind_calls == 3 && call_tile.is_wind_tile())
            return true;
        if (dragon_calls == 2 && call_tile.is_dragon_tile())
            return true;
        if (kans == 3 && new_call.tiles.size == 4)
            return true;

        return false;
    }

    public static bool in_tenpai(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls)
    {
        return hand_readings(hand, calls, true, true).size > 0;
    }

    public static bool winning_hand(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls)
    {
        return hand_readings(hand, calls, false, true).size > 0;
    }

    public static ArrayList<HandReading> hand_readings(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls, bool tenpai_only, bool early_return)
    {
        ArrayList<TileMeld> call_melds = new ArrayList<TileMeld>();

        if (calls != null)
        {
            foreach (RoundStateCall call in calls)
            {
                if (call.call_type == RoundStateCall.CallType.CHII || call.call_type == RoundStateCall.CallType.PON)
                    call_melds.add(new TileMeld(call.tiles[0], call.tiles[1], call.tiles[2], false));
                else if (call.call_type == RoundStateCall.CallType.OPEN_KAN || call.call_type == RoundStateCall.CallType.LATE_KAN)
                    call_melds.add(new TileMeld.kan(call.tiles[0], call.tiles[1], call.tiles[2], call.tiles[3], false));
                else if (call.call_type == RoundStateCall.CallType.CLOSED_KAN)
                    call_melds.add(new TileMeld.kan(call.tiles[0], call.tiles[1], call.tiles[2], call.tiles[3], true));
            }
        }

        return hand_reading_recursion(hand, call_melds, tenpai_only, early_return);
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
            Tile t = hand[0];
            TilePair pair = new TilePair(t, new Tile(-1, t.tile_type, false));

            HandReading reading = new HandReading(melds, pair);
            if (reading.valid_keishiki)
                readings.add(reading);

            return readings;
        }
        else if (hand.size == 2) // If we have a winning hand, then our last two tiles must be the same
        {
            if (hand[0].tile_type == hand[1].tile_type)
            {
                TilePair pair = new TilePair(hand[0], hand[1]);

                HandReading reading = new HandReading(melds, pair);
                if (reading.valid_keishiki)
                    readings.add(reading);
            }

            return readings;
        }

        if (hand.size == 13 || hand.size == 14)
        {
            // -------- Kokushi musou --------
            {
                int[] kokushi = new int[13];

                foreach (Tile tile in remaining_tiles)
                {
                         if (tile.tile_type == TileType.MAN1 ) kokushi[ 0]++;
                    else if (tile.tile_type == TileType.MAN9 ) kokushi[ 1]++;
                    else if (tile.tile_type == TileType.PIN1 ) kokushi[ 2]++;
                    else if (tile.tile_type == TileType.PIN9 ) kokushi[ 3]++;
                    else if (tile.tile_type == TileType.SOU1 ) kokushi[ 4]++;
                    else if (tile.tile_type == TileType.SOU9 ) kokushi[ 5]++;
                    else if (tile.tile_type == TileType.TON  ) kokushi[ 6]++;
                    else if (tile.tile_type == TileType.NAN  ) kokushi[ 7]++;
                    else if (tile.tile_type == TileType.SHAA ) kokushi[ 8]++;
                    else if (tile.tile_type == TileType.PEI  ) kokushi[ 9]++;
                    else if (tile.tile_type == TileType.HATSU) kokushi[10]++;
                    else if (tile.tile_type == TileType.HAKU ) kokushi[11]++;
                    else if (tile.tile_type == TileType.CHUN ) kokushi[12]++;
                }

                int unique = 0;
                int total = 0;

                for (int i = 0; i < kokushi.length; i++)
                {
                    if (kokushi[i] != 0)
                        unique++;
                    total += kokushi[i];
                }

                if (unique >= hand.size - 1 && total == hand.size)
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
                    if (tenpai_only)
                    {
                        ArrayList<TilePair> p = new ArrayList<TilePair>();
                        for (int i = 0; i < 13; i += 2)
                        {
                            if (i != 12 && hand[i].tile_type == hand[i+1].tile_type)
                                p.add(new TilePair(hand[i], hand[i+1]));
                            else
                            {
                                p.add(new TilePair(hand[i], new Tile(-1, hand[i].tile_type, false)));
                                i--;
                            }
                        }

                        readings.add(new HandReading.chiitoi(p));
                    }
                    else
                    {
                        ArrayList<TilePair> p = new ArrayList<TilePair>();
                        for (int i = 0; i < 13; i += 2)
                            p.add(new TilePair(hand[i], hand[i+1]));
                        readings.add(new HandReading.chiitoi(p));
                    }

                    if (early_return)
                        return readings;
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

                ArrayList<TileMeld> new_melds = new ArrayList<TileMeld>();
                new_melds.add_all(melds);
                new_melds.add(m);

                readings.add_all(hand_reading_recursion(copy, new_melds, tenpai_only, early_return));

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

                    ArrayList<TileMeld> new_melds = new ArrayList<TileMeld>();
                    new_melds.add_all(melds);
                    new_melds.add(m);

                    readings.add_all(hand_reading_recursion(copy, new_melds, tenpai_only, early_return));

                    if (early_return && readings.size > 0)
                        return readings;
                }
            }

            // Last option is to find a pair, and see if we are waiting for our last combination (this can only be if we have 4 tiles left in the hand, and are tenpai only)
            if (hand.size == 4)
            {
                int s = hand.size;
                Tile? t = null;
                Tile? n1 = null, n2 = null;
                if (hand[(i+1)%s].tile_type == hand[(i+2)%s].tile_type)
                {
                    n1 = hand[(i+1)%s];
                    n2 = hand[(i+2)%s];
                     t = hand[(i+3)%s];
                }
                else if (hand[(i+1)%s].tile_type == hand[(i+3)%s].tile_type)
                {
                    n1 = hand[(i+1)%s];
                     t = hand[(i+2)%s];
                    n2 = hand[(i+3)%s];
                }
                else if (hand[(i+2)%s].tile_type == hand[(i+3)%s].tile_type)
                {
                     t = hand[(i+1)%s];
                    n1 = hand[(i+2)%s];
                    n2 = hand[(i+3)%s];
                }

                if (t != null)
                {
                    if (tile.tile_type == t.tile_type) // We have two remaining pairs
                    {
                        TilePair pair = new TilePair(tile, t);
                        ArrayList<TileMeld> new_melds = new ArrayList<TileMeld>();
                        new_melds.add_all(melds);
                        new_melds.add(new TileMeld(n1, n2, new Tile(-1, n1.tile_type, false), true));

                        HandReading reading = new HandReading(new_melds, pair);
                        if (reading.valid_keishiki)
                            readings.add(reading);

                        pair = new TilePair(n1, n2);
                        new_melds.clear();
                        new_melds.add_all(melds);
                        new_melds.add(new TileMeld(tile, t, new Tile(-1, tile.tile_type, false), true));

                        reading = new HandReading(new_melds, pair);
                        if (reading.valid_keishiki)
                            readings.add(reading);

                        return readings;
                    }
                    else if (tile.is_neighbour(t) || tile.is_second_neighbour(t)) // We have a pair and are waiting on the final triplet
                    {
                        TilePair pair = new TilePair(n1, n2);

                        int v1 = (int)t.tile_type;
                        int v2 = (int)tile.tile_type;

                        Tile t1, t2;
                        if (v1 < v2)
                        {
                            t1 = t;
                            t2 = tile;
                        }
                        else
                        {
                            t1 = tile;
                            t2 = t;
                        }

                        v1 = (int)t1.tile_type;
                        v2 = (int)t2.tile_type;

                        ArrayList<TileMeld> new_melds = new ArrayList<TileMeld>();
                        new_melds.add_all(melds);

                        if (tile.is_second_neighbour(t))
                        {
                            int middle = (v1 + v2) / 2; // Need a new tile in the middle
                            new_melds.add(new TileMeld(t1, new Tile(-1, (TileType)middle, false), t2, true));

                            HandReading reading = new HandReading(new_melds, pair);
                            if (reading.valid_keishiki)
                                readings.add(reading);
                        }
                        else
                        {
                            if (!t1.is_terminal_tile())
                            {
                                new_melds.add(new TileMeld(new Tile(-1, (TileType)(v1 - 1), false), t1, t2, true));

                                HandReading reading = new HandReading(new_melds, pair);
                                if (reading.valid_keishiki)
                                    readings.add(reading);
                            }

                            if (!t2.is_terminal_tile())
                            {
                                new_melds.clear();
                                new_melds.add_all(melds);
                                new_melds.add(new TileMeld(t1, t2, new Tile(-1, (TileType)(v2 + 1), false), true));

                                HandReading reading = new HandReading(new_melds, pair);
                                if (reading.valid_keishiki)
                                    readings.add(reading);
                            }
                        }

                        return readings;
                    }
                }
            }
        }

        return readings;
    }

    public static bool is_nagashi_mangan(ArrayList<Tile> pond)
    {
        foreach (Tile tile in pond)
            if (!tile.is_honor_tile() && !tile.is_terminal_tile())
                return false;
        return true;
    }

    public static bool can_closed_chankan(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls)
    {
        if (hand.size != 14)
            return false;

        foreach (HandReading reading in hand_readings(hand, calls, false, false))
            if (reading.is_kokushi)
                return true;
        return false;
    }

    public static ArrayList<Tile> tenpai_tiles(ArrayList<Tile> hand, ArrayList<RoundStateCall>? calls)
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

            if (in_tenpai(tiles, calls))
                tenpai_tiles.add(tile);
        }

        return tenpai_tiles;
    }

    public static bool can_win_with(ArrayList<Tile> hand, ArrayList<RoundStateCall> calls, Tile tile)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        tiles.add_all(hand);
        tiles.add(tile);

        return winning_hand(tiles, calls);
    }
}

public class RoundStateCall : Object
{
    public RoundStateCall(CallType call_type, ArrayList<Tile> tiles, Tile? call_tile, int discarder_index)
    {
        this.call_type = call_type;
        this.tiles = tiles;
        this.call_tile = call_tile;
        this.discarder_index = discarder_index;
    }

    public CallType call_type { get; private set; }
    public ArrayList<Tile> tiles { get; private set; }
    public Tile? call_tile { get; private set; }
    public int discarder_index { get; private set; }

    public enum CallType
    {
        CHII,
        PON,
        OPEN_KAN,
        CLOSED_KAN,
        LATE_KAN
    }
}

public class RoundStateContext : Object
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
        bool flow_interrupted
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
        "flow_interrupted: " + flow_interrupted.to_string() + "\n";

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
}

public class PlayerStateContext : Object
{
    public PlayerStateContext
    (
        int index,
        ArrayList<Tile> hand, // Without the winning tile
        ArrayList<Tile> pond,
        ArrayList<RoundStateCall> calls,
        Wind wind,
        bool dealer,
        bool in_riichi,
        bool double_riichi,
        bool open,
        bool ippatsu,
        bool tiles_called_on,
        bool first_turn,
        int sekinin_index
    )
    {
        this.index = index;
        this.hand = hand;
        this.pond = pond;
        this.calls = calls;
        this.wind = wind;
        this.dealer = dealer;
        this.in_riichi = in_riichi;
        this.double_riichi = double_riichi;
        this.open = open;
        this.ippatsu = ippatsu;
        this.tiles_called_on = tiles_called_on;
        this.first_turn = first_turn;
        this.sekinin_index = sekinin_index;
    }

    public string to_string()
    {
        string str =
        "index: " + index.to_string() + "\n" +
        "wind: " + wind.to_string() + "\n" +
        "dealer: " + dealer.to_string() + "\n" +
        "in_riichi: " + in_riichi.to_string() + "\n" +
        "double_riichi: " + double_riichi.to_string() + "\n" +
        "open: " + open.to_string() + "\n" +
        "ippatsu: " + ippatsu.to_string() + "\n" +
        "tiles_called_on: " + tiles_called_on.to_string() + "\n" +
        "first_turn: " + first_turn.to_string() + "\n" +
        "sekinin_index: " + sekinin_index.to_string() + "\n";

        str += "hand: \n";
        foreach (Tile t in hand)
            str += "\t" + t.tile_type.to_string() + "\n";

        /*str += "pond: \n";
        foreach (Tile t in pond)
            str += "\t" + t.tile_type.to_string() + "\n";*/

        return str;
    }

    public int index { get; private set; }
    public ArrayList<Tile> hand { get; private set; }
    public ArrayList<Tile> pond { get; private set; }
    public ArrayList<RoundStateCall> calls { get; private set; }
    public Wind wind { get; private set; }
    public bool dealer { get; private set; }
    public bool in_riichi { get; private set; }
    public bool double_riichi { get; private set; }
    public bool open { get; private set; }
    public bool ippatsu { get; private set; }
    public bool tiles_called_on { get; private set; }
    public bool first_turn { get; private set; }
    public int sekinin_index { get; private set; }
}

public class HandReading : Object
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
        tiles.add(pair.tile_1);
        tiles.add(pair.tile_2);

        is_kokushi = false;
        valid_keishiki = check_keishiki(tiles);
    }

    public HandReading.chiitoi(ArrayList<TilePair> pairs)
    {
        tiles = new ArrayList<Tile>();
        melds = new ArrayList<TileMeld>();
        this.pairs = new ArrayList<TilePair>();

        foreach (TilePair pair in pairs)
        {
            tiles.add(pair.tile_1);
            tiles.add(pair.tile_2);
        }

        this.pairs.add_all(pairs);
        is_kokushi = false;
        valid_keishiki = true;
    }

    public HandReading.kokushi(ArrayList<Tile> tiles)
    {
        this.tiles = new ArrayList<Tile>();
        this.tiles.add_all(tiles);

        melds = new ArrayList<TileMeld>();
        pairs = new ArrayList<TilePair>();
        is_kokushi = true;
        valid_keishiki = true;
    }

    public HandReading.empty()
    {
        tiles = new ArrayList<Tile>();
        melds = new ArrayList<TileMeld>();
        pairs = new ArrayList<TilePair>();
        is_kokushi = false;
        valid_keishiki = false;
    }

    public void add_meld(TileMeld meld)
    {
        melds.add(meld);
        tiles.add(meld.tile_1);
        tiles.add(meld.tile_2);
        tiles.add(meld.tile_3);

        if (meld.is_kan)
            tiles.add(meld.tile_4);
    }

    private static bool check_keishiki(ArrayList<Tile> tiles)
    {
        // Double loop arguably faster than using mutations
        foreach (Tile tile in tiles)
        {
            int count = 0;
            foreach (Tile t in tiles)
                if (tile.tile_type == t.tile_type)
                    count++;
            if (count > 4)
                return false;
        }

        return true;
    }

    public string to_string()
    {
        string str =

        "tiles:\n";
        foreach (Tile tile in tiles)
            str += "\t" + tile.to_string() + "\n";
        str += "melds:";
        foreach (TileMeld meld in melds)
            str += meld.to_string() + "\n";
        str += "pairs:";
        foreach (TilePair pair in pairs)
            str += pair.to_string() + "\n";

        str +=
        "is_kokushi: " + is_kokushi.to_string() + "\n" +
        "valid_keishkiki: " + valid_keishiki.to_string();

        return str;
    }

    public ArrayList<Tile> tiles { get; private set; }
    public ArrayList<TileMeld> melds { get; private set; }
    public ArrayList<TilePair> pairs { get; private set; }
    public bool is_kokushi { get; private set; }
    public bool valid_keishiki { get; private set; }
}

public class TileMeld : Object
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

    /*public new Tile? get(int i)
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
    }*/

    public string to_string()
    {
        string str =

        "tile_1: " + tile_1.to_string() + "\n" +
        "tile_2: " + tile_2.to_string() + "\n" +
        "tile_3: " + tile_3.to_string() + "\n" +
        "tile_4: " + (tile_4 == null ? "(null)" : tile_2.to_string()) + "\n" +
        "is_triplet: " + is_triplet.to_string() + "\n" +
        "is_kan: " + is_kan.to_string() + "\n" +
        "is_closed: " + is_closed.to_string();

        return str;
    }
}

public class TilePair : Object
{
    public TilePair(Tile tile_1, Tile tile_2)
    {
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
    }

    public Tile tile_1 { get; private set; }
    public Tile tile_2 { get; private set; }

    /*public new Tile? get(int i)
    {
        if (i == 0)
            return tile_1;
        else if (i == 1)
            return tile_2;
        else
            return null;
    }*/

    public string to_string()
    {
        string str =

        "tile_1: " + tile_1.to_string() + "\n" +
        "tile_2: " + tile_2.to_string();

        return str;
    }
}

public class Scoring : Object
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
        this.dora = true;
        score_type = ScoreType.NORMAL;

        bool riichi = false;

        foreach (Yaku y in yaku)
        {
            yakuman += y.yakuman;
            han += y.han;

            if (y.yaku_type == YakuType.RIICHI || y.yaku_type == YakuType.OPEN_RIICHI)
                riichi = true;
        }

        this.ura_dora = riichi;

        int dora = 0;
        int ura_dora = 0;
        int aka_dora = 0;

        foreach (Tile tile in hand.tiles)
            if (tile.dora)
                aka_dora++;

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

        han += dora + ura_dora + aka_dora;
        if (dora > 0)
            yaku.add(new Yaku(YakuType.DORA, dora, 0));
        if (ura_dora > 0)
            yaku.add(new Yaku(YakuType.URA_DORA, ura_dora, 0));
        if (aka_dora > 0)
            yaku.add(new Yaku(YakuType.AKA_DORA, aka_dora, 0));

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
        dora = false;
        ura_dora = false;
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
        dora = false;
        ura_dora = false;
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
            if (y.yaku_type != YakuType.DORA && y.yaku_type != YakuType.URA_DORA && y.yaku_type != YakuType.AKA_DORA)
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

        if (hand.is_kokushi)
        {
            fu = 20;
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
                if (meld.tile_1.is_honor_tile() || meld.tile_1.is_terminal_tile())
                    f *= 2;

                fu += f;
            }

            if (wait != WaitType.AMBIGUOUS && (meld.tile_1.tile_type == win_tile.tile_type || meld.tile_1.tile_type == win_tile.tile_type || meld.tile_3.tile_type == win_tile.tile_type))
            {
                WaitType w;
                if (meld.is_triplet)
                    w = WaitType.CLOSED;
                else if (meld.tile_2.tile_type == win_tile.tile_type)
                    w = WaitType.CLOSED;
                else if (meld.tile_1.tile_type == win_tile.tile_type && meld.tile_3.is_terminal_tile())
                    w = WaitType.CLOSED;
                else if (meld.tile_3.tile_type == win_tile.tile_type && meld.tile_1.is_terminal_tile())
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

        Tile pair_tile = hand.pairs[0].tile_1;
        if (pair_tile.is_dragon_tile())
            fu += 2;
        else
        {
            if (pair_tile.is_wind(round.round_wind))
                fu += 2;
            if (pair_tile.is_wind(player.wind))
                fu += 2;
        }

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
    public bool dora { get; private set; }
    public bool ura_dora { get; private set; }
    public ScoreType score_type { get; private set; }

    public string to_string()
    {
        string str =

        "valid: " + valid.to_string() + "\n" +
        "hand: " + hand.to_string() + "\n" +
        "round: " + round.to_string() + "\n" +
        "player: " + player.to_string() + "\n";

        foreach (Yaku y in yaku)
            str += "yaku: " + y.to_string() + "\n";

        str +=
        "ron: " + ron.to_string() + "\n" +
        "dealer: " + dealer.to_string() + "\n" +
        "tsumo_points_lower: " + tsumo_points_lower.to_string() + "\n" +
        "tsumo_points_higher: " + tsumo_points_higher.to_string() + "\n" +
        "ron_points: " + ron_points.to_string() + "\n" +
        "total_points: " + total_points.to_string() + "\n" +
        "han: " + han.to_string() + "\n" +
        "fu: " + fu.to_string() + "\n" +
        "yakuman: " + yakuman.to_string() + "\n" +
        "score_type: " + score_type.to_string();

        return str;
    }

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

public class Yaku : Object
{
    public Yaku(YakuType yaku_type, int han, int yakuman)
    {
        this.yaku_type = yaku_type;
        this.han = han;
        this.yakuman = yakuman;
    }

    public string to_string()
    {
        string str =

        "yaku_type: " + yaku_type.to_string() + "\n" +
        "han: " + han.to_string() + "\n" +
        "yakuman: " + yakuman.to_string();

        return str;
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

        // Tenhou / Chiihou / Renhou
        if (!round.flow_interrupted && player.first_turn)
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
            if (player.open)
                yaku.add(new Yaku(YakuType.OPEN_RIICHI, player.double_riichi ? 3 : 2, 0));
            else if (player.double_riichi)
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

                    if (m1.tile_1.tile_type == m2.tile_1.tile_type &&
                        m1.tile_2.tile_type == m2.tile_2.tile_type &&
                        m1.tile_3.tile_type == m2.tile_3.tile_type)
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

                    if (m1.tile_1.tile_type == m2.tile_1.tile_type &&
                        m1.tile_2.tile_type == m2.tile_2.tile_type &&
                        m1.tile_3.tile_type == m2.tile_3.tile_type)
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
                if (!meld.is_triplet || !meld.tile_1.is_honor_tile())
                    continue;

                if (meld.tile_1.is_dragon_tile())
                    count++;
                else // Wind tile
                {
                    if (meld.tile_1.is_wind(player.wind))
                        count++;
                    if (meld.tile_1.is_wind(round.round_wind))
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

                Tile t1 = m1.tile_1;
                Tile t2 = m2.tile_1;
                Tile t3 = m3.tile_1;

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

                Tile t1 = m1.tile_1;
                Tile t2 = m2.tile_1;
                Tile t3 = m3.tile_1;

                if (!t1.is_suit_tile() || !t2.is_suit_tile() || !t3.is_suit_tile() ||
                    !t1.is_same_sort(t2) || !t1.is_same_sort(t3))
                    continue;

                bool[] l = new bool[9];

                l[t1.get_number_index()] = true;
                l[t2.get_number_index()] = true;
                l[t3.get_number_index()] = true;

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

                Tile low = meld.tile_1;
                Tile high = meld.tile_3;

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

                Tile tile = pair.tile_1;

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
            {
                bool pair_wait = (hand.pairs[0].tile_1.tile_type == round.win_tile.tile_type);
                yaku.add(new Yaku(YakuType.SUU_ANKOU, 0, pair_wait ? 2 : 1));
            }
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

                Tile t1 = m1.tile_1;
                Tile t2 = m2.tile_1;
                Tile t3 = m3.tile_1;

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
                if (meld.tile_1.is_dragon_tile())
                    count++;

            if (count == 3)
                yaku.add(new Yaku(YakuType.DAI_SANGEN, 0, 1));
            else if (count == 2 && hand.pairs[0].tile_1.is_dragon_tile())
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
                if (meld.tile_1.is_wind_tile())
                    count++;

            if (count == 4)
                yaku.add(new Yaku(YakuType.DAI_SUUSHII, 0, 2));
            else if (count == 3)
            {
                if (hand.pairs[0].tile_1.is_wind_tile())
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
                Tile t = hand.tiles[i];

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
                    int index = round.win_tile.get_number_index();
                    bool nine_wait =
                        (index > 0 && index < 8 && counts[index] == 2) ||
                        ((index == 0 || index == 8) && counts[index] == 4);

                    yaku.add(new Yaku(YakuType.CHUUREN_POUTOU, 0, nine_wait ? 2 : 1));
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
            bool tsuu = true;

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
    OPEN_RIICHI, // Open reach
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
    URA_DORA,
    AKA_DORA
}
