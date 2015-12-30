using Gee;

class SimpleBot : Bot
{
    private Rand rnd = new Rand();

    protected override void do_turn_decision()
    {
        turn_delay();

        if (round_state.can_tsumo())
        {
            do_tsumo();
        }
        else if(round_state.can_riichi())
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
            ArrayList<ArrayList<Tile>> groups = round_state.self.get_closed_kan_groups();
            do_closed_kan(groups[0][0].tile_type);
        }
        else
        {
            Tile tile;
            if (round_state.self.in_riichi)
                tile = round_state.self.newest_tile;
            else
                tile = get_discard_tile();

            do_discard(tile);
        }
    }

    protected override void do_call_decision(RoundStatePlayer discarding_player, Tile tile)
    {
        if (round_state.can_ron(round_state.self))
        {
            call_delay();
            call_ron();
            return;
        }
        else if (round_state.can_pon(round_state.self))
        {
            if (tile.is_dragon_tile() || tile.is_wind(round_state.self.wind) || tile.is_wind(round_state.round_wind))
            {
                call_delay();
                call_pon();
                return;
            }
        }
        /*else if (round_state.can_chii(tile, round_state.self, round_state.discard_player))
        {
            action_delay();

            ArrayList<ArrayList<Tile>> groups = TileRules.get_chii_groups(round_state.self.hand, tile);
            ArrayList<Tile> tiles = groups[0];

            call_chii(tiles[0], tiles[1]);
        }*/

        call_nothing();
    }

    private Tile get_discard_tile()
    {
        ArrayList<Tile> tiles = round_state.self.get_discard_tiles();

        ArrayList<Tile> copy = new ArrayList<Tile>();
        foreach (Tile tile in tiles)
        {
            copy.add_all(tiles);
            copy.remove(tile);

            if (TileRules.in_tenpai(copy))
                return tile;

            copy.clear();
        }

        ArrayList<Tile> backup = new ArrayList<Tile>();
        backup.add_all(tiles);

        for (int i = 0; i < tiles.size; i++)
        {
            Tile tile = tiles[i];
            if (count(tile) >= 3)
                tiles.remove_at(i--);
        }

        if (tiles.size == 0)
            return random(backup);

        foreach (Tile tile in tiles)
        {
            if (tile.is_wind_tile())
            {
                if (!tile.is_wind(round_state.self.wind) && !tile.is_wind(round_state.round_wind))
                    return tile;
                else if (count(tile) <= 1)
                    return tile;
            }
            if (tile.is_dragon_tile())
            {
                if(count(tile) <= 1)
                    return tile;
            }
        }

        backup.clear();
        backup.add_all(tiles);

        for (int i = 0; i < tiles.size; i++)
        {
            Tile tile = tiles[i];
            if (tile.is_dragon_tile() || tile.is_wind(round_state.self.wind) || tile.is_wind(round_state.round_wind))
                tiles.remove_at(i--);
        }

        if (tiles.size == 0)
            return random(backup);

        backup.clear();
        backup.add_all(tiles);

        for (int i = 0; i < tiles.size; i++)
        {
            Tile tile = tiles[i];
            if (has_neighbours(tile))
                tiles.remove_at(i--);
        }

        if (tiles.size == 0)
            return random(backup);

        backup.clear();
        backup.add_all(tiles);

        for (int i = 0; i < tiles.size; i++)
        {
            Tile tile = tiles[i];
            if (count(tile) >= 2)
                tiles.remove_at(i--);
        }

        if (tiles.size == 0)
            return random(backup);

        backup.clear();
        backup.add_all(tiles);

        for (int i = 0; i < tiles.size; i++)
        {
            Tile tile = tiles[i];
            if (has_second_neighbours(tile))
                tiles.remove_at(i--);
        }

        if (tiles.size == 0)
            return random(backup);

        backup.clear();
        backup.add_all(tiles);

        for (int i = 0; i < tiles.size; i++)
        {
            Tile tile = tiles[i];
            if (!tile.is_terminal_tile())
                tiles.remove_at(i--);
        }

        if (tiles.size == 0)
            return random(backup);

        return random(tiles);
    }

    private Tile random(ArrayList<Tile> tiles)
    {
        return tiles[rnd.int_range(0, tiles.size)];
    }

    private int count(Tile tile)
    {
        int count = 0;
        foreach (Tile t in round_state.self.hand)
            if (t.tile_type == tile.tile_type)
                count++;
        return count;
    }

    private bool has_neighbours(Tile tile)
    {
        if (!tile.is_suit_tile())
            return false;

        foreach (Tile t in round_state.self.hand)
        {
            if (tile == t)
                continue;

            if (tile.is_neighbour(t))
                return true;
        }

        return false;
    }

    private bool has_second_neighbours(Tile tile)
    {
        if (!tile.is_suit_tile())
            return false;

        foreach (Tile t in round_state.self.hand)
        {
            if (tile == t)
                continue;

            if (tile.is_second_neighbour(t))
                return true;
        }

        return false;
    }

    private void turn_delay()
    {
        Thread.usleep(1 * 1000 * 1000);
    }

    private void call_delay()
    {
        Thread.usleep(500 * 1000);
    }

    public override string name { get { return "SimpleBot"; } }
}
