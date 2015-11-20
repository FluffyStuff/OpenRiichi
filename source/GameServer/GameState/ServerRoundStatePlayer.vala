using Gee;

namespace GameServer
{
    class ServerRoundStatePlayer
    {
        private ArrayList<Tile> pond = new ArrayList<Tile>();

        private Wind wind;
        private bool dealer;
        private bool double_riichi = false;
        private bool can_double_riichi = true;
        private bool ippatsu = false;
        private bool tiles_called_on = false;
        private bool temporary_furiten = false; // Temporary/Permanent temporary furiten

        public ServerRoundStatePlayer(int index, Wind wind, bool dealer)
        {
            this.index = index;
            call_decision = null;
            state = PlayerState.DONE;
            hand = new ArrayList<Tile>();
            calls = new ArrayList<RoundStateCall>();
            in_riichi = false;
            this.wind = wind;
            this.dealer = dealer;
            last_drawn_tile = null;
        }

        public void draw(Tile tile)
        {
            hand.add(tile);
            last_drawn_tile = tile;

            if (!in_riichi) // Check for permanent temporary furiten
                temporary_furiten = false;
        }

        public bool discard(Tile tile)
        {
            bool do_ippatsu = false;

            if (state == PlayerState.WAITING_RIICHI_DISCARD)
            {
                bool found = false;
                ArrayList<Tile> tiles = TileRules.tenpai_tiles(hand);
                foreach (Tile t in tiles)
                    if (t == tile)
                    {
                        found = true;
                        break;
                    }
                if (!found)
                    return false;

                state = PlayerState.DONE;
                do_ippatsu = true;
            }
            else if (in_riichi && tile != last_drawn_tile)
                return false;

            hand.remove(tile);
            pond.add(tile);

            ippatsu = do_ippatsu;
            can_double_riichi = false;

            return true;
        }

        public void rob_tile(Tile tile)
        {
            tiles_called_on = true;
        }

        public void check_temporary_furiten(Tile tile)
        {
            ArrayList<Tile> hand = new ArrayList<Tile>();
            hand.add_all(this.hand);
            hand.add(tile);

            if (TileRules.winning_hand(hand))
                temporary_furiten = true;
        }

        public bool can_ron(RoundStateContext context)
        {
            return !temporary_furiten && !TileRules.in_furiten(hand, pond) && TileRules.can_ron(create_context(false), context);
        }

        public bool can_tsumo(RoundStateContext context)
        {
            return TileRules.can_tsumo(create_context(true), context);
        }

        private PlayerStateContext create_context(bool tsumo)
        {
            ArrayList<Tile> hand = new ArrayList<Tile>();
            hand.add_all(this.hand);
            if (tsumo)
                hand.remove(last_drawn_tile);

            return new PlayerStateContext
            (
                hand,
                pond,
                calls,
                wind,
                dealer,
                in_riichi,
                double_riichi,
                ippatsu,
                tiles_called_on
            );
        }

        public bool can_riichi()
        {
            if (in_riichi)
                return false;

            foreach (RoundStateCall call in calls)
                if (call.call_type != RoundStateCall.CallType.CLOSED_KAN)
                    return false;

            return TileRules.tenpai_tiles(hand).size > 0;
        }

        /*public bool can_open_kan(Tile tile)
        {
            return TileRules.can_open_kan(hand, tile);
        }*/

        public bool can_pon(Tile tile)
        {
            return !in_riichi && TileRules.can_pon(hand, tile);
        }

        public bool can_chii(Tile tile)
        {
            return !in_riichi && TileRules.can_chii(hand, tile);
        }

        public bool do_riichi()
        {
            if (!can_riichi())
                return false;

            in_riichi = true;
            if (can_double_riichi)
                double_riichi = true;

            return true;
        }

        public bool do_late_kan(Tile tile)
        {
            if (in_riichi)
                return false;

            for (int i = 0; i < calls.size; i++)
            {
                RoundStateCall call = calls[i];

                if (call.call_type == RoundStateCall.CallType.PON)
                {
                    if (call.tiles[0].tile_type == tile.tile_type)
                    {
                        calls.remove_at(i);
                        ArrayList<Tile> kan = new ArrayList<Tile>();
                        kan.add_all(call.tiles);
                        kan.add(tile);
                        calls.insert(i, new RoundStateCall(RoundStateCall.CallType.LATE_KAN, kan));
                        hand.remove(tile);

                        can_double_riichi = false;
                        return true;
                    }
                }
            }

            return false;
        }

        public ArrayList<Tile>? do_closed_kan(TileType type)
        {
            // TODO: Fix
            if (in_riichi)
                return null;

            ArrayList<Tile> kan = new ArrayList<Tile>();

            foreach (Tile t in hand)
                if (t.tile_type == type)
                {
                    kan.add(t);
                    if (kan.size == 4)
                    {
                        calls.add(new RoundStateCall(RoundStateCall.CallType.CLOSED_KAN, kan));
                        remove_hand_tiles(kan);

                        can_double_riichi = false;
                        return kan;
                    }
                }

            return null;
        }

        public void do_open_kan(Tile discard_tile, ArrayList<Tile> tiles)
        {
            ArrayList<Tile> kan = new ArrayList<Tile>();
            kan.add_all(tiles);
            kan.add(discard_tile);
            remove_hand_tiles(tiles);

            calls.add(new RoundStateCall(RoundStateCall.CallType.OPEN_KAN, kan));
            can_double_riichi = false;
        }

        public void do_pon(Tile discard_tile, ArrayList<Tile> tiles)
        {
            ArrayList<Tile> pon = new ArrayList<Tile>();
            pon.add_all(tiles);
            pon.add(discard_tile);
            remove_hand_tiles(tiles);

            calls.add(new RoundStateCall(RoundStateCall.CallType.PON, pon));
            can_double_riichi = false;
        }

        public void do_chii(Tile discard_tile, ArrayList<Tile> tiles)
        {
            ArrayList<Tile> chii = new ArrayList<Tile>();
            chii.add_all(tiles);
            chii.add(discard_tile);
            remove_hand_tiles(tiles);

            calls.add(new RoundStateCall(RoundStateCall.CallType.CHII, chii));
            can_double_riichi = false;
        }

        public ArrayList<Tile>? get_open_kan_tiles(Tile tile)
        {
            ArrayList<Tile> kan = new ArrayList<Tile>();

            foreach (Tile t in hand)
                if (t.tile_type == tile.tile_type)
                {
                    kan.add(t);
                    if (kan.size == 3)
                        return kan;
                }

            return null;
        }

        public ArrayList<Tile>? get_pon_tiles(Tile tile)
        {
            ArrayList<Tile> pon = new ArrayList<Tile>();

            foreach (Tile t in hand)
                if (t.tile_type == tile.tile_type)
                {
                    pon.add(t);
                    if (pon.size == 2)
                        return pon;
                }

            return null;
        }

        public Tile? get_tile(int ID)
        {
            foreach (Tile t in hand)
                if (t.ID == ID)
                    return t;
            return null;
        }

        public void remove_hand_tiles(ArrayList<Tile> tiles)
        {
            foreach (Tile tile in tiles)
                hand.remove(tile);
        }

        public bool in_tenpai()
        {
            return TileRules.in_tenpai(hand);
        }

        public Scoring get_ron_score(RoundStateContext context)
        {
            return TileRules.get_score(create_context(false), context);
        }

        public Scoring get_tsumo_score(RoundStateContext context)
        {
            return TileRules.get_score(create_context(true), context);
        }

        public int index { get; private set; }
        public RoundStateCallDecision? call_decision { get; set; }
        public PlayerState state { get; set; }
        public ArrayList<Tile> hand { get; private set; }
        public ArrayList<RoundStateCall> calls { get; private set; }
        public bool in_riichi { get; private set; }
        public Tile? last_drawn_tile { get; private set; }

        public enum PlayerState
        {
            DONE,
            WAITING_CALL,
            WAITING_RIICHI_DISCARD
        }
    }

    class RoundStateCallDecision
    {
        public RoundStateCallDecision(CallDecisionType type, ArrayList<Tile>? tiles)
        {
            call_type = type;
            this.tiles = tiles;
        }

        public CallDecisionType call_type { get; private set; }
        public ArrayList<Tile>? tiles { get; private set; }

        public enum CallDecisionType
        {
            RON,
            KAN,
            PON,
            CHII
        }
    }
}
