using Gee;

namespace GameServer
{
    class GameStateWall
    {
        private Tile[] tiles = new Tile[136];

        private ArrayList<Tile> wall_tiles = new ArrayList<Tile>();
        private ArrayList<Tile> dead_wall_tiles = new ArrayList<Tile>();
        private int dora_index = 4;

        public GameStateWall(int dealer, int start_index, Rand rnd)
        {
            doras = new ArrayList<Tile>();
            ura_doras = new ArrayList<Tile>();

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
                if (i % 2 == 0)
                    t++;
                else
                    t--;

                dead_wall_tiles.insert(0, tiles[t]);
            }
        }

        public Tile flip_dora()
        {
            Tile tile = dead_wall_tiles[dora_index];
            doras.add(tile);
            ura_doras.add(dead_wall_tiles[dora_index + 1]);

            dora_index += 2;

            return tile;
        }

        public Tile draw_wall()
        {
            return wall_tiles.remove_at(0);
        }

        public Tile draw_dead_wall()
        {
            Tile tile = dead_wall_tiles.remove_at(0);
            dora_index--;
            return tile;
        }

        public Tile dead_tile_add()
        {
            Tile tile = wall_tiles.remove_at(wall_tiles.size - 1);
            dead_wall_tiles.insert(dead_wall_tiles.size, tile);
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
        public ArrayList<Tile> doras { get; private set; }
        public ArrayList<Tile> ura_doras { get; private set; }
    }
}
