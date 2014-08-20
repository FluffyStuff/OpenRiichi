using Gee;

#if LINUX
public class Logic
#else
public static class Logic
#endif
{
    public static bool can_pon(Tile played_tile, ArrayList<Tile> hand)
    {
        int count = 0;
        foreach (Tile t in hand)
        {
            if (t.tile_type == played_tile.tile_type)
            {
                count++;
                if (count == 2)
                    return true;
            }
        }

        return false;
    }

    public static bool can_open_kan(Tile played_tile, ArrayList<Tile> hand)
    {
        int count = 0;
        foreach (Tile t in hand)
        {
            if (t.tile_type == played_tile.tile_type)
            {
                count++;
                if (count == 3)
                    return true;
            }
        }

        return false;
    }

    public static bool can_closed_kan(ArrayList<Tile> hand)
    {
        foreach (Tile t in hand)
        {
            int count = 0;
            foreach (Tile o in hand)
            {
                if (t.tile_type == o.tile_type)
                    count++;

                if (count == 4)
                    return true;
            }
        }

        return false;
    }

    public static bool can_riichi_closed_kan(ArrayList<Tile> hand)
    {
        return false;
    }

    public static bool can_late_kan(ArrayList<Tile> hand, ArrayList<Pon> pons)
    {
        foreach (Pon p in pons)
            foreach (Tile t in hand)
                if (t.tile_type == p.tiles[0].tile_type)
                    return true;

        return false;
    }

    public static bool can_chi(Tile played_tile, ArrayList<Tile> hand)
    {
        if (played_tile.tile_type > 26)
            return false;

        bool two_less = false;
        bool one_less = false;
        bool one_more = false;
        bool two_more = false;

        int type = played_tile.tile_type - (played_tile.tile_type % 9);

        foreach (Tile t in hand)
        {
            if (t.tile_type < type || t.tile_type >= type + 9 || t.tile_type > 26)
                continue;

            switch (t.tile_type - played_tile.tile_type)
            {
            case -2:
                two_less = true;
                break;
            case -1:
                one_less = true;
                break;
            case 1:
                one_more = true;
                break;
            case 2:
                two_more = true;
                break;
            }
        }

        return (two_less && one_less) || (one_less && one_more) || (one_more && two_more);
    }

    public static Tile[]? auto_chi(Tile discard_tile, ArrayList<Tile> hand)
    {
        if (discard_tile.tile_type > 26)
            return null;

        int type = discard_tile.tile_type - (discard_tile.tile_type % 9);

        Tile? two_less = null;
        Tile? one_less = null;
        Tile? one_more = null;
        Tile? two_more = null;

        foreach (Tile t in hand)
        {
            if (t.tile_type < type || t.tile_type >= type + 9 || t.tile_type > 26)
                continue;

            switch (t.tile_type - discard_tile.tile_type)
            {
            case -2:
                two_less = t;
                break;
            case -1:
                one_less = t;
                break;
            case 1:
                one_more = t;
                break;
            case 2:
                two_more = t;
                break;
            }
        }

        if (two_less != null && one_less != null && one_more == null)
            return new Tile[] { two_less, one_less };
        else if (two_less == null && one_less != null && one_more != null && two_more == null)
            return new Tile[] { one_less, one_more };
        else if (one_less == null && one_more != null && two_more != null)
            return new Tile[] { one_more, two_more };
        else
            return null;
    }

    public static Tile? chi_combination(Tile discard_tile, Tile selected_tile, ArrayList<Tile> hand)
    {
        if (discard_tile.tile_type > 26 || selected_tile.tile_type > 26)
            return null;

        int discard_type = discard_tile.tile_type - (discard_tile.tile_type % 9);
        int selected_type = selected_tile.tile_type - (selected_tile.tile_type % 9);

        if (discard_type != selected_type)
            return null;

        Tile? two_less = null;
        Tile? one_less = null;
        Tile? one_more = null;
        Tile? two_more = null;

        foreach (Tile t in hand)
        {
            if (t.tile_type < discard_type || t.tile_type >= discard_type + 9 || t.tile_type > 26)
                continue;

            switch (t.tile_type - discard_tile.tile_type)
            {
            case -2:
                two_less = t;
                break;
            case -1:
                one_less = t;
                break;
            case 1:
                one_more = t;
                break;
            case 2:
                two_more = t;
                break;
            }
        }

        if (selected_tile == two_less && one_less != null)
            return one_less;
        else if (selected_tile == two_more && one_more != null)
            return one_more;
        else if (selected_tile == one_less)
        {
            if (one_more != null)
                return one_more;
            else if (two_less != null)
                return two_less;
        }
        else if (selected_tile == one_more)
        {
            if (one_less != null)
                return one_less;
            else if (two_more != null)
                return two_more;
        }

        return null;
    }

    public static bool in_tenpai(ArrayList<Tile> hand)
    {
        return tenpai_or_winning_hand(hand, true);
    }

    public static bool winning_hand(ArrayList<Tile> hand)
    {
        return tenpai_or_winning_hand(hand, false);
    }

    private static bool tenpai_or_winning_hand(ArrayList<Tile> hand_in, bool tenpai_only)
    {
        //stdout.printf("Entering function with " + hand_in.size.to_string() + " tiles.\n");

        // Need to copy to a new list because we are going to sort our list
        ArrayList<Tile> hand = new ArrayList<Tile>();
        foreach (Tile t in hand_in)
            hand.add(t);
        Tile.sort_tiles(hand);

        // -------- Chi-toi ---------

        if ((tenpai_only && hand_in.size == 13) || (!tenpai_only && hand_in.size == 14) && false)
        {
            bool same = true;
            bool offset = false;
            for (int i = 0; i < 12; i += 2)
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
            if (same && (tenpai_only || hand[12].tile_type == hand[13].tile_type))
                return true;
        }

        // -------- /Chi-toi --------

        // Pons/kans/chis remove tile count by 3, so we should always have mod 3 + 1 tiles in our tenpai hand (+2 if it's a winning hand)
        if (hand == null ||
            (tenpai_only && (hand.size % 3 != 1 || hand.size > 13)) ||
            (!tenpai_only && (hand.size % 3 != 2 || hand.size > 14)))
            return false;
        else if (hand.size == 1) // If there is a single tile left then we are in a single tile pair wait
            return true;
        else if (hand.size == 2 && hand[0].tile_type == hand[1].tile_type) // If we have a winning hand, then our last two tiles must be the same
            return true;

        for (int i = 0; i < hand.size; i++)
        {
            if (i != 0 && hand[i].tile_type == hand[i-1].tile_type)
                continue;

            // See if we can make a triplet with our tile
            Tile tile = hand[i];
            //stdout.printf("Looping with " + tile.name + ".\n");

            int count = 0;
            ArrayList<Tile> copy = new ArrayList<Tile>(); // A list which contains all the tiles from our hand, minus the triplet which we are going to make

            foreach (Tile t in hand)
            {
                if (count < 3 && tile.tile_type == t.tile_type)
                    count++;
                else
                    copy.add(t);
            }

            if (count == 3)
            {
                //stdout.printf("Trying pon.\n");
                if (tenpai_or_winning_hand(copy, tenpai_only))
                    return true;
                //stdout.printf("Pon failed.\n");
            }

            int type = tile.tile_type - (tile.tile_type % 9);
            if (type <= 26 && tile.tile_type + 2 - (tile.tile_type + 2) % 9 == type)
            {
                // See if we can make a row with our tile being the lowest number (only lowest in order to skip redundant row permutations)
                bool one_more = false;
                bool two_more = false;
                copy.clear();

                foreach (Tile t in hand)
                {
                    if (t == tile)
                        continue;
                    if (t.tile_type - tile.tile_type == 1 && !one_more)
                        one_more = true;
                    else if (t.tile_type - tile.tile_type == 2 && !two_more)
                        two_more = true;
                    else
                        copy.add(t);
                }

                if (one_more && two_more)
                {
                    //stdout.printf("Trying chi.\n");
                    if (tenpai_or_winning_hand(copy, tenpai_only))
                        return true;
                    //stdout.printf("Chi failed.\n");
                }
            }

            // Last option is to find a pair, and see if we are waiting for our last combination (this can only be if we have 4 tiles left in the hand)
            if (hand.size == 4)
            {
                hand.remove_at(i);

                Tile? t = null;
                if (hand[0].tile_type == hand[1].tile_type)
                    t = hand[2];
                else if (hand[0].tile_type == hand[2].tile_type)
                    t = hand[1];
                else if (hand[1].tile_type == hand[2].tile_type)
                    t = hand[0];

                if (t != null &&
                    type == t.tile_type - (t.tile_type % 9) &&
                    type <= 26 &&
                    (tile.tile_type - t.tile_type).abs() <= 2)
                    return true; // We are in tenpai for our last combination

                hand.insert(i, tile);
            }
        }

        return false;
    }

    public static ArrayList<Tile> can_tenpai(ArrayList<Tile> hand)
    {
        ArrayList<Tile> tenpai_tiles = new ArrayList<Tile>();

        foreach (Tile tile in hand)
        {
            bool cont = false;
            foreach (Tile t in tenpai_tiles)
                if (t.tile_type == tile.tile_type)
                {
                    cont = true;
                    break;
                }
            if (cont) // Already checked this tile type
                continue;

            ArrayList<Tile> tiles = new ArrayList<Tile>();
            foreach (Tile t in hand)
                if (tile != t)
                    tiles.add(t);

            if (in_tenpai(tiles))
                tenpai_tiles.add(tile);
        }

        return tenpai_tiles;
    }

    public static bool can_win_with(ArrayList<Tile> hand, Tile tile)
    {
        hand.add(tile);
        bool win = winning_hand(hand);
        hand.remove(tile);
        return win;
    }

    public static bool has_yaku(ArrayList<Tile> hand, ArrayList<Call> calls, bool last_piece, bool kan_piece)
    {
        return true;
    }
}
