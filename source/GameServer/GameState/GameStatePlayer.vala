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

        public bool can_call(Tile tile)
        {
            return false;
        }

        public Tile? get_tile(int ID)
        {
            foreach (Tile t in hand)
                if (t.ID == ID)
                    return t;
            return null;
        }

        public int ID { get; private set; }
    }
}
