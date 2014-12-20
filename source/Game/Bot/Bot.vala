#if LINUX
public class Bot
#else
public static class Bot
#endif
{
    #if DEBUG
        private static ulong decision_delay = 700000;//10;
    #else
        private static ulong decision_delay = 700000;
    #endif

    public static CallAction make_call(int bot_level, ComputerPlayer player, Tile discard_tile, bool can_chi)
    {
        return new CallAction.none();
        delay();

        // TODO: Fix winning...
        if (Logic.can_win_with(player.hand, discard_tile) && Logic.has_yaku(player, discard_tile, false, false))
            return new CallAction.ron(discard_tile.id);
        else if (Logic.can_open_kan(discard_tile, player.hand))
        {
            Tile[] tiles = new Tile[3];

            int a = 0;
            foreach (Tile t in player.hand)
            {
                if (t.tile_type == discard_tile.tile_type)
                    tiles[a++] = t;

                if (a == 3)
                    return new CallAction(CallAction.CallActionEnum.OPEN_KAN, Tile.tiles_to_ints(tiles));
            }
        }
        else if (Logic.can_pon(discard_tile, player.hand))
        {
            Tile[] tiles = new Tile[2];

            int a = 0;
            foreach (Tile t in player.hand)
            {
                if (t.tile_type == discard_tile.tile_type)
                    tiles[a++] = t;

                if (a == 2)
                    return new CallAction(CallAction.CallActionEnum.PON, Tile.tiles_to_ints(tiles));
            }
        }
        else if (Logic.can_chi(discard_tile, player.hand))
        {
            Tile? two_less = null;
            Tile? one_less = null;
            Tile? one_more = null;
            Tile? two_more = null;

            int type = discard_tile.tile_type - (discard_tile.tile_type % 9);

            foreach (Tile t in player.hand)
            {
                if (t.tile_type < type || t.tile_type >= type + 9 || t.tile_type > 26)
                    continue;

                switch (discard_tile.tile_type - t.tile_type)
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

            Tile[] tiles = new Tile[2];

            if (two_less != null && one_less != null)
            {
                tiles[0] = two_less;
                tiles[1] = one_less;
            }
            else if (one_less != null && one_more != null)
            {
                tiles[0] = one_less;
                tiles[1] = one_more;
            }
            else if (one_more != null && two_more != null)
            {
                tiles[0] = one_more;
                tiles[1] = two_more;
            }

            return new CallAction(CallAction.CallActionEnum.CHI, Tile.tiles_to_ints(tiles));
        }

        return new CallAction.none();
    }

    public static TurnAction? make_move(int bot_level, ComputerPlayer player)
    {
        delay();
        return new TurnAction.discard(player.hand[Environment.random.int_range(0, 1)].id);

        if (Logic.winning_hand(player.hand) && Logic.has_yaku(player, null, false, false))
            return new TurnAction.tsumo();
        else if (player.in_riichi)
            return new TurnAction.discard(player.hand[player.hand.size - 1].id);

        var tenpai_tiles = Logic.can_tenpai(player.hand);

        if (tenpai_tiles.size != 0 && !player.open_hand)
            return new TurnAction.riichi(tenpai_tiles[0].id);
        else if (Logic.can_closed_kan(player.hand))
        {
            Tile[] kan = new Tile[4];
            foreach (Tile t in player.hand)
            {
                int count = 0;
                foreach (Tile o in player.hand)
                {
                    if (t.tile_type == o.tile_type)
                        kan[count++] = o;

                    if (count == 4)
                        return new TurnAction.closed_kan(Tile.tiles_to_ints(kan));
                }
            }
        }
        else if (Logic.can_late_kan(player.hand, player.pons))
        {
            for (uint8 i = 0; i < player.pons.size; i++)
                foreach (Tile t in player.hand)
                    if (t.tile_type == player.pons[i].tiles[0].tile_type)
                        return new TurnAction.late_kan(t.id, i);
        }

        if (player.hand.size != 0)
        {
            foreach (Tile tile in player.hand)
            {
                int count = 0;
                foreach (Tile t in player.hand)
                    if (tile.tile_type == t.tile_type)
                        count++;
                if (count != 2 && count != 4)
                    return new TurnAction.discard(tile.id);
            }

            //return new TurnAction.discard(player.hand[Environment.random.int_range(0, player.hand.size - 1)].id);
            return new TurnAction.discard(player.hand[Environment.random.int_range(0, 1)].id);
        }

        return null;
    }

    private static void delay()
    {
        Thread.usleep(decision_delay);
    }
}
