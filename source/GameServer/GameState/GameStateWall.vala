using Gee;

namespace GameServer
{
    class GameStateWall
    {
        private Tile[] tiles = new Tile[136];

        private ArrayList<Tile> wall_tiles = new ArrayList<Tile>();
        private ArrayList<Tile> dead_wall_tiles = new ArrayList<Tile>();
        private ArrayList<Tile> doras = new ArrayList<Tile>();
        private int new_dora_index = 5;

        public GameStateWall(int dealer, int start_index, Rand rnd)
        {
            for (int i = 0; i < tiles.length; i++)
            {
                int type = (i / 4) + 1;
                tiles[i] = new Tile(-1, (TileType)type, false);
            }

            shuffle(tiles, rnd);

            int start_wall = (4 - dealer) % 4;
            int index = start_wall * 34 + start_index * 2;

            for (int i = 0; i < tiles.length; i++)
                tiles[i].ID = i;

            for (int i = 0; i < 122; i++)
            {
                int t = (index + i) % 136;
                wall_tiles.add(tiles[t]);
            }

            for (int i = 0; i < 14; i++)
            {
                int t = (index + i + 122) % 136;
                dead_wall_tiles.insert(0, tiles[t]);
            }
        }

        public Tile flip_dora()
        {
            Tile tile = dead_wall_tiles.get(new_dora_index);
            doras.add(tile);
            new_dora_index += 2;

            return tile;
        }

        public Tile draw_wall()
        {
            return wall_tiles.remove_at(0);
        }

        public Tile draw_dead_wall()
        {
            Tile tile = dead_wall_tiles.remove_at(0);
            new_dora_index--;
            return tile;
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

        public bool empty { get { return wall_tiles.size == 0; } }
    }
}
