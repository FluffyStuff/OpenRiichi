using Gee;

public class RenderWall
{
    private WallPart[] walls;
    //private DeadWall dead_wall;
    private int active_wall;

    public RenderWall(RenderTile[] tiles, Vec3 tile_size, Vec3 center, float offset, int starting_player, int split)
    {
        /*wall_tiles = new RenderTile[tiles.length];
        for (int i = 0; i < tiles.length; i++)
            wall_tiles[i] = tiles[i];*/

        active_wall = starting_player;

        walls = new WallPart[4];
        for (int i = 0; i < 4; i++)
        {
            RenderTile[] wt = new RenderTile[34];
            for (int j = 0; j < 34; j++)
                wt[j] = tiles[i * 34 + j];

            Vec3 pos = Calculations.vec3_plus(Calculations.rotate_y({}, -(float)i / 2, Vec3() { z = offset }), center);
            walls[i] = new WallPart(wt, tile_size, pos, i);
        }
    }

    public RenderTile? draw_wall()
    {
        if (walls[active_wall].empty)
            active_wall = (active_wall + 1) % 4;
        if (walls[active_wall].empty)
            return null;

        return walls[active_wall].draw();
    }

    private class WallPart
    {
        private ArrayList<RenderTile> wall;
        private Vec3 tile_size;
        private Vec3 position;
        private int rotation;

        public WallPart(RenderTile[] tiles, Vec3 tile_size, Vec3 position, int rotation)
        {
            wall = new ArrayList<RenderTile>();
            for (int i = 0; i < tiles.length; i++)
                wall.add(tiles[i]);

            this.tile_size = tile_size;
            this.position = position;
            this.rotation = rotation;

            order();
        }

        public RenderTile? draw()
        {
            if (empty)
                return null;

            RenderTile tile = wall.get(0);
            wall.remove_at(0);

            return tile;
        }

        private void order()
        {
            for (int i = 0; i < wall.size; i++)
            {
                RenderTile tile = wall.get(i);

                Vec3 pos = Vec3()
                {
                    x = (8 - i / 2) * tile_size.x,
                    y = ((i + 1) % 2 + 0.5f) * tile_size.y
                };

                tile.position = Calculations.vec3_plus(Calculations.rotate_y({}, -(float)rotation / 2, pos), position);

                tile.rotation = Vec3()
                {
                    x = 1,
                    y = (float)rotation / 2
                };
            }
        }

        public bool empty { get { return wall.size == 0; } }
    }

    private class DeadWall
    {

    }
}
