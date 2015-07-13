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

        public void remove_tiles(ArrayList<Tile> tiles)
        {
            foreach (Tile tile in tiles)
                hand.remove(tile);
        }

        public int ID { get; private set; }
        public GameStateCallDecision? call_decision { get; set; }
        public PlayerState state { get; set; }

        public enum PlayerState
        {
            DONE,
            WAITING_CALL
        }
    }

    class GameStateCallDecision
    {
        public GameStateCallDecision(CallType type, ArrayList<Tile> tiles)
        {
            call_type = type;
            this.tiles = tiles;
        }

        public CallType call_type { get; private set; }
        public ArrayList<Tile> tiles { get; private set; }
    }

    enum CallType
    {
        RON,
        KAN,
        PON,
        CHI
    }
}
