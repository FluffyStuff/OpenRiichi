using Gee;

class NullBot : Bot
{
    private Rand rnd = new Rand();

    protected override void do_turn_decision()
    {
        action_delay();

        if (state.can_tsumo(state.self) && state.self.in_riichi)
        {
            do_tsumo();
        }
        else if(state.self.can_riichi())
        {
            do_riichi();

            ArrayList<Tile> tiles = state.get_tenpai_tiles(state.self);
            Tile tile = tiles[rnd.int_range(0, tiles.size)];

            do_discard(tile);
        }
        else if (state.self.can_late_kan())
        {
            ArrayList<Tile> tiles = TileRules.get_late_kan_tiles(state.self.hand, state.self.calls);
            do_late_kan(tiles[0]);
        }
        else if (state.self.can_closed_kan())
        {
            ArrayList<ArrayList<Tile>> groups = TileRules.get_closed_kan_groups(state.self.hand);
            do_closed_kan(groups[0][0].tile_type);
        }
        else
        {
            Tile tile;
            if (state.self.in_riichi)
                tile = state.self.last_drawn_tile;
            else
                tile = state.self.hand[rnd.int_range(0, state.self.hand.size)];

            do_discard(tile);
        }
    }

    protected override void do_call_decision(ClientGameStatePlayer discarding_player, Tile tile)
    {
        if (state.can_ron(state.self, tile) && state.self.in_riichi)
        {
            action_delay();
            call_ron();
        }
        /*else if (TileRules.can_open_kan(state.self.hand, tile))
        {
            action_delay();
            call_open_kan();
        }
        else if (TileRules.can_pon(state.self.hand, tile))
        {
            action_delay();
            call_pon();
        }
        else if (state.can_chii(tile, state.self, state.discard_player))
        {
            action_delay();

            ArrayList<ArrayList<Tile>> groups = TileRules.get_chii_groups(state.self.hand, tile);
            ArrayList<Tile> tiles = groups[0];

            call_chii(tiles[0], tiles[1]);
        }*/
        else
        {
            call_nothing();
        }
    }

    private void action_delay()
    {
        Thread.usleep(1 * 1000000);
    }

    public override string name { get { return "NullBot"; } }
}
