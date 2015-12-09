using Gee;

// This particular signal receiver must be an object (otherwise the application will crash randomly...)
// I'm guessing it has something to do with being subscribed to a signal in a list of objects, but I'm not sure. Either way it's a bug in Vala
public class RenderWall : Object
{
    private Vec3 tile_size;
    private WallPart[] walls;
    private DeadWall dead_wall;
    private int active_wall;
    private int last_wall;

    public RenderWall(RenderTile[] tiles, Vec3 tile_size, Vec3 center, float offset, int dealer, int split)
    {
        this.tile_size = tile_size;
        int start_wall = (4 - dealer) % 4;
        active_wall = last_wall = start_wall;

        walls = new WallPart[4];
        for (int i = 0; i < 4; i++)
        {
            RenderTile[] wt = new RenderTile[34];
            for (int j = 0; j < 34; j++)
                wt[j] = tiles[i * 34 + j];

            Vec3 pos = Calculations.rotate_y(Vec3.empty(), -(float)i / 2, Vec3(0, 0, offset)).plus(center);
            walls[i] = new WallPart(wt, tile_size, pos, i);
            walls[i].next_wall.connect(next_wall);
        }

        ArrayList<RenderTile> left = walls[start_wall].dead_split(split, true);
        ArrayList<RenderTile> right = walls[(start_wall + 3) % 4].dead_split(split, false);

        int rot = last_wall;
        if (left.size < 14)
            rot = (rot + 3) % 4;
        dead_wall = new DeadWall(left, right, split, rot, tile_size);
    }

    public RenderTile? draw_wall()
    {
        return walls[active_wall].draw();
    }

    public RenderTile? draw_dead_wall()
    {
        return dead_wall.draw();
    }

    public void flip_dora()
    {
        dead_wall.flip_dora();
    }

    public void flip_ura_dora()
    {
        dead_wall.flip_ura_dora();
        dead_tile_add();
    }

    public void dead_tile_add()
    {
        if (walls[last_wall].empty)
            last_wall = (last_wall + 3) % 4;

        RenderTile tile = walls[last_wall].remove_last();
        dead_wall.dead_tile_add(tile);
    }

    private void next_wall()
    {
        active_wall = (active_wall + 1) % 4;
    }

    public class WallPart
    {
        private ArrayList<RenderTile> wall_left = new ArrayList<RenderTile>();
        private ArrayList<RenderTile> wall_right = new ArrayList<RenderTile>();
        private Vec3 tile_size;
        private Vec3 position;
        private int rotation;
        private int removed_tiles = 0;

        public signal void next_wall();

        public WallPart(RenderTile[] tiles, Vec3 tile_size, Vec3 position, int rotation)
        {
            for (int i = 0; i < tiles.length; i++)
                wall_left.add(tiles[i]);

            this.tile_size = tile_size;
            this.position = position;
            this.rotation = rotation;

            order();
        }

        public ArrayList<RenderTile> dead_split(int index, bool first)
        {
            ArrayList<RenderTile> left = new ArrayList<RenderTile>();
            ArrayList<RenderTile> center = new ArrayList<RenderTile>();
            ArrayList<RenderTile> right = new ArrayList<RenderTile>();

            if (!first)
                index += 17;
            index *= 2;

            if (index <= 0 || index >= 48)
                return center;

            for (int i = index; i < 34; i++)
                left.add(wall_left[i]);
            for (int i = int.max(index - 14, 0); i < int.min(index, 34); i++)
                center.add(wall_left[i]);
            for (int i = 0; i < index - 14; i++)
                right.add(wall_left[i]);

            float offset = 1.5f * tile_size.x;
            float left_m = -1;
            float center_m = 0;
            float right_m = 1;

            if (left.size == 0)
            {
                left_m = 0;
                center_m -= 0.5f;
            }
            if (right.size == 0)
            {
                right_m = 0;
                center_m += 0.5f;
            }

            float r = -(float)rotation / 2;

            for (int i = 0; i < left.size; i++)
            {
                RenderTile t = left[i];
                Vec3 pos = Calculations.rotate_y(Vec3.empty(), r, {left_m * offset});
                pos = t.position.plus(pos);

                t.animate_towards(pos, t.rotation);
            }
            for (int i = 0; i < center.size; i++)
            {
                RenderTile t = center[i];
                Vec3 pos = Calculations.rotate_y(Vec3.empty(), r, {center_m * offset});
                pos = t.position.plus(pos);

                t.animate_towards(pos, t.rotation);
            }
            for (int i = 0; i < right.size; i++)
            {
                RenderTile t = right[i];
                Vec3 pos = Calculations.rotate_y(Vec3.empty(), r, {right_m * offset});
                pos = t.position.plus(pos);

                t.animate_towards(pos, t.rotation);
            }

            wall_left = left;
            wall_right = right;

            ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
            for (int i = center.size - 1; i >= 0; i--)
            {
                int a = i;
                if (i % 2 == 0)
                    a++;
                else
                    a--;
                tiles.add(center[a]);
            }

            return tiles;
        }

        public RenderTile remove_last()
        {
            ArrayList<RenderTile> list;
            if (wall_right.size != 0)
                list = wall_right;
            else
                list = wall_left;

            RenderTile tile = list.remove_at(list.size - 1);

            if (removed_tiles % 2 == 0)
            {
                RenderTile t = list[list.size - 1];
                t.animate_towards(tile.position, tile.rotation);
            }

            removed_tiles++;
            return tile;
        }

        public RenderTile? draw()
        {
            if (empty)
                return null;

            if (wall_left.size > 0)
            {
                RenderTile t = wall_left.remove_at(0);
                if (wall_left.size == 0)
                    next_wall();

                return t;
            }

            RenderTile t = wall_right.remove_at(0);
            if (wall_right.size == 0)
                next_wall();
            return t;
        }

        private void order()
        {
            for (int i = 0; i < wall_left.size; i++)
            {
                RenderTile tile = wall_left[i];

                Vec3 pos = Vec3
                (
                    (8 - i / 2) * tile_size.x,
                    ((i + 1) % 2 + 0.5f) * tile_size.y,
                    0
                );

                pos = Calculations.rotate_y(Vec3.empty(), -(float)rotation / 2, pos).plus(position);

                Vec3 rot = Vec3
                (
                    1,
                    (float)rotation / 2 + 1,
                    0
                );

                tile.set_absolute_location(pos, rot);
            }
        }

        public bool empty { get { return wall_left.size + wall_right.size == 0; } }
    }

    private class DeadWall
    {
        private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        private ArrayList<RenderTile> doras = new ArrayList<RenderTile>();
        private ArrayList<RenderTile> ura_doras = new ArrayList<RenderTile>();
        private int rotation;
        private int split;
        private Vec3 tile_size;

        private int dora_index = 4;
        private int tiles_added = 0;

        public DeadWall(ArrayList<RenderTile> left, ArrayList<RenderTile> right, int split, int rotation, Vec3 tile_size)
        {
            this.rotation = rotation;
            this.split = split;
            this.tile_size = tile_size;

            for (int i = 0; i < left.size; i++)
                tiles.add(left[i]);
            for (int i = 0; i < right.size; i++)
                tiles.add(right[i]);
        }

        public RenderTile draw()
        {
            dora_index--;
            return tiles.remove_at(0);
        }

        public void flip_dora()
        {
            RenderTile t = tiles[dora_index];
            doras.add(t);
            ura_doras.add(tiles[dora_index + 1]);

            Vec3 rot = t.rotation;
            rot = { 0, rot.y, rot.z };

            t.animate_towards(t.position, rot);

            dora_index += 2;
        }

        public void flip_ura_dora()
        {
            for (int i = 0; i < doras.size; i++)
            {
                RenderTile tile = doras[i];
                Vec3 pos = { 0, -tile_size.y, 0 };
                pos = pos.plus(tile.position);
                tile.animate_towards(pos, tile.rotation);
            }

            for (int i = 0; i < ura_doras.size; i++)
            {
                RenderTile tile = ura_doras[i];
                int rotation = this.rotation;
                float dir = -0.001f;
                if (split >= 7)
                    rotation--;
                if (3 + i <= split)
                {
                    rotation--;
                    dir = -dir;
                }

                Vec3 pos = Vec3(0, 0, -tile_size.z);
                pos = Calculations.rotate_y(Vec3.empty(), -(float)rotation / 2, pos).plus(tile.position);

                Vec3 rot = tile.rotation;
                rot = Vec3(dir, rot.y, rot.z); // Not 0, so it flips in the right direction
                tile.animate_towards(pos, rot);
            }
        }

        public void dead_tile_add(RenderTile tile)
        {
            Vec3 pos;

            if (tiles_added % 2 == 0)
            {
                float y = tiles_added > 0 ? -tile_size.y : 0;
                pos = Vec3(tile_size.x, y, 0);
                pos = Calculations.rotate_y(Vec3.empty(), -(float)rotation / 2, pos);
            }
            else
                pos = Vec3(0, tile_size.y, 0);

            pos = tiles[tiles.size - 1].position.plus(pos);

            Vec3 rot = Vec3
            (
                1,
                (float)rotation / 2 + 1,
                0
            );

            tile.animate_towards(pos, rot);

            tiles_added++;
            tiles.insert(tiles.size, tile);
        }
    }
}
