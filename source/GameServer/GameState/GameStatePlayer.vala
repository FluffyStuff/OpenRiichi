using Gee;

namespace GameServer
{
    class GameStatePlayer
    {
        private ArrayList<Tile> hand = new ArrayList<Tile>();
        private ArrayList<Tile> pond = new ArrayList<Tile>();

        public GameStatePlayer(int ID)
        {
            this.ID = ID;
            call_decision = null;
            state = PlayerState.DONE;
            calls = new ArrayList<GameStateCall>();
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

        public bool can_ron(Tile tile)
        {
            return TileRules.can_ron(hand, tile);
        }

        /*public bool can_open_kan(Tile tile)
        {
            return TileRules.can_open_kan(hand, tile);
        }*/

        public bool can_pon(Tile tile)
        {
            return TileRules.can_pon(hand, tile);
        }

        public bool can_chi(Tile tile)
        {
            return TileRules.can_chi(hand, tile);
        }

        public bool do_late_kan(Tile tile)
        {
            for (int i = 0; i < calls.size; i++)
            {
                GameStateCall call = calls[i];

                if (call.call_type == GameStateCall.CallType.PON)
                {
                    if (call.tiles[0].tile_type == tile.tile_type)
                    {
                        calls.remove_at(i);
                        calls.insert(i, new GameStateCall(GameStateCall.CallType.LATE_KAN, call.tiles));
                        hand.remove(tile);

                        return true;
                    }
                }
            }

            return false;
        }

        public ArrayList<Tile>? do_closed_kan(TileType type)
        {
            ArrayList<Tile> kan = new ArrayList<Tile>();

            foreach (Tile t in hand)
                if (t.tile_type == type)
                {
                    kan.add(t);
                    if (kan.size == 4)
                    {
                        calls.add(new GameStateCall(GameStateCall.CallType.CLOSED_KAN, kan));
                        remove_hand_tiles(kan);
                        return kan;
                    }
                }

            return null;
        }

        public void do_open_kan(Tile discard_tile, ArrayList<Tile> tiles)
        {
            ArrayList<Tile> kan = new ArrayList<Tile>();
            kan.add_all(tiles);
            remove_hand_tiles(tiles);

            calls.add(new GameStateCall(GameStateCall.CallType.OPEN_KAN, kan));
        }

        public void do_pon(Tile discard_tile, ArrayList<Tile> tiles)
        {
            ArrayList<Tile> pon = new ArrayList<Tile>();
            pon.add_all(tiles);
            remove_hand_tiles(tiles);

            calls.add(new GameStateCall(GameStateCall.CallType.PON, pon));
        }

        public void do_chi(Tile discard_tile, ArrayList<Tile> tiles)
        {
            ArrayList<Tile> chi = new ArrayList<Tile>();
            chi.add_all(tiles);
            remove_hand_tiles(tiles);

            calls.add(new GameStateCall(GameStateCall.CallType.CHI, chi));
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

        public int ID { get; private set; }
        public GameStateCallDecision? call_decision { get; set; }
        public PlayerState state { get; set; }
        public ArrayList<GameStateCall> calls { get; private set; }

        public enum PlayerState
        {
            DONE,
            WAITING_CALL
        }
    }

    class GameStateCallDecision
    {
        public GameStateCallDecision(CallDecisionType type, ArrayList<Tile> tiles)
        {
            call_type = type;
            this.tiles = tiles;
        }

        public CallDecisionType call_type { get; private set; }
        public ArrayList<Tile> tiles { get; private set; }

        public enum CallDecisionType
        {
            RON,
            KAN,
            PON,
            CHI
        }
    }
}
