using Gee;

namespace GameServer
{
    class GameStateWall
    {
        private Tile[] tiles = new Tile[136];

        private ArrayList<Tile> wall_tiles = new ArrayList<Tile>();
        private ArrayList<Tile> dead_wall_tiles = new ArrayList<Tile>();

        public GameStateWall()
        {
            for (int i = 0; i < tiles.length; i++)
            {
                int type = (i / 4) + 1;
                tiles[i] = new Tile(-1, (TileType)type, false);
            }

            shuffle(tiles, new Rand());

            for (int i = 0; i < tiles.length; i++)
            {
                tiles[i].ID = i;
                wall_tiles.add(tiles[i]);
            }
        }

        public Tile draw_wall()
        {
            return wall_tiles.remove_at(0);
        }

        private static void shuffle(Tile[] tiles, Rand rnd)
        {
            for (int i = 0; i < tiles.length; i++)
            {
                int tmp = rnd.int_range(0, tiles.length);
                Tile t = tiles[i];
                tiles[i] = tiles[tmp];
                tiles[tmp] = t;
            }
        }
    }
}
