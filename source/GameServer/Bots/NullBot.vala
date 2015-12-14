using Gee;

class NullBot : Bot
{
    private Rand rnd = new Rand();

    protected override void do_turn_decision()
    {
        turn_delay();

        if (round_state.can_tsumo())
        {
            do_tsumo();
        }
        else if(round_state.self.can_riichi())
        {
            do_riichi();

            ArrayList<Tile> tiles = round_state.get_tenpai_tiles(round_state.self);
            Tile tile = tiles[rnd.int_range(0, tiles.size)];

            do_discard(tile);
        }
        else if (round_state.can_late_kan())
        {
            ArrayList<Tile> tiles = TileRules.get_late_kan_tiles(round_state.self.hand, round_state.self.calls);
            do_late_kan(tiles[0]);
        }
        else if (round_state.can_closed_kan())
        {
            ArrayList<ArrayList<Tile>> groups = TileRules.get_closed_kan_groups(round_state.self.hand);
            do_closed_kan(groups[0][0].tile_type);
        }
        else
        {
            Tile tile;
            if (round_state.self.in_riichi)
                tile = round_state.self.last_drawn_tile;
            else
                tile = round_state.self.hand[rnd.int_range(0, round_state.self.hand.size)];

            do_discard(tile);
        }
    }

    protected override void do_call_decision(RoundStatePlayer discarding_player, Tile tile)
    {
        if (round_state.can_ron(round_state.self))
        {
            call_delay();
            call_ron();
        }
        /*else if (TileRules.can_open_kan(round_state.self.hand, tile))
        {
            action_delay();
            call_open_kan();
        }
        else if (TileRules.can_pon(round_state.self.hand, tile))
        {
            action_delay();
            call_pon();
        }
        else if (round_state.can_chii(tile, round_state.self, round_state.discard_player))
        {
            action_delay();

            ArrayList<ArrayList<Tile>> groups = TileRules.get_chii_groups(round_state.self.hand, tile);
            ArrayList<Tile> tiles = groups[0];

            call_chii(tiles[0], tiles[1]);
        }*/
        else
        {
            call_nothing();
        }
    }

    private void turn_delay()
    {
        Thread.usleep(1 * 1000 * 1000);
    }

    private void call_delay()
    {
        Thread.usleep(500 * 1000);
    }

    public override string name { get { return "NullBot"; } }
}
