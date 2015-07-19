using Gee;

public class RenderPlayer
{
    private Vec3 center;
    private Vec3 tile_size;
    private float player_offset;
    private float wall_offset;

    private RenderHand hand;
    private RenderPond pond;
    private RenderCalls calls;

    public RenderPlayer(Vec3 center, int seat, float player_offset, float wall_offset, Vec3 tile_size)
    {
        this.center = center;
        this.player_offset = player_offset;
        this.wall_offset = wall_offset;
        this.seat = seat;
        this.tile_size = tile_size;

        Vec3 pos = Vec3() { z = this.player_offset };
        pos = Calculations.rotate_y({}, (float)seat / 2, pos);
        pos = Calculations.vec3_plus(center, pos);

        hand = new RenderHand(pos, tile_size, seat);

        pos = Vec3() { z = (this.wall_offset + this.player_offset) / 2 - tile_size.z };
        pos = Calculations.rotate_y({}, (float)seat / 2, pos);
        pos = Calculations.vec3_plus(center, pos);

        pond = new RenderPond(pos, tile_size, seat);

        pos = Vec3() { x = this.player_offset, z = this.player_offset };
        pos = Calculations.rotate_y({}, (float)seat / 2, pos);
        pos = Calculations.vec3_plus(center, pos);

        calls = new RenderCalls(pos, tile_size, seat);
    }

    public void add_to_hand(RenderTile tile)
    {
        hand.add_tile(tile);
    }

    public void discard(RenderTile tile)
    {
        hand.remove(tile);
        pond.add(tile);
    }

    public void rob_tile(RenderTile tile)
    {
        pond.remove(tile);
    }

    public void late_kan(RenderTile tile)
    {
        RenderCalls.RenderCallPon pon = calls.get_pon(tile.tile_type.tile_type);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add_all(pon.tiles);
        tiles.add(tile);

        hand.remove(tile);

        RenderCalls.RenderCallLateKan kan = new RenderCalls.RenderCallLateKan(tiles, tile_size, pon.alignment);
        calls.late_kan(pon, kan);
    }

    public void closed_kan(TileType type)
    {
        ArrayList<RenderTile> tiles = hand.get_tiles_type(type);

        foreach (RenderTile tile in tiles)
            hand.remove(tile);

        RenderCalls.RenderCallClosedKan kan = new RenderCalls.RenderCallClosedKan(tiles, tile_size);
        calls.add(kan);
    }

    public void open_kan(RenderPlayer discard_player, RenderTile discard_tile, RenderTile tile_1, RenderTile tile_2, RenderTile tile_3)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);
        hand.remove(tile_3);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);
        tiles.add(tile_3);

        RenderCalls.RenderCallOpenKan kan = new RenderCalls.RenderCallOpenKan(tiles, tile_size, RenderCalls.players_to_alignment(this, discard_player));
        calls.add(kan);
    }

    public void pon(RenderPlayer discard_player, RenderTile discard_tile, RenderTile tile_1, RenderTile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add(discard_tile);
        tiles.add(tile_1);
        tiles.add(tile_2);

        RenderCalls.RenderCallPon pon = new RenderCalls.RenderCallPon(tiles, tile_size, RenderCalls.players_to_alignment(this, discard_player));
        calls.add(pon);
    }

    public void chi(RenderPlayer discard_player, RenderTile discard_tile, RenderTile tile_1, RenderTile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add(tile_1);
        tiles.add(tile_2);

        RenderCalls.RenderCallChi chi = new RenderCalls.RenderCallChi(discard_tile, tiles, tile_size);
        calls.add(chi);
    }

    public ArrayList<RenderTile> hand_tiles { get { return hand.tiles; } }
    public int seat { get; private set; }

    public static ArrayList<RenderTile> sort_tiles(ArrayList<RenderTile> list)
    {
        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add_all(list);

        CompareFunc<RenderTile> cmp = (t1, t2) =>
        {
            int a = (int)t1.tile_type.tile_type;
            int b = (int)t2.tile_type.tile_type;
            return (int) (a > b) - (int) (a < b);
        };

        tiles.sort(cmp);

        return tiles;
    }
}

private class RenderHand
{
    private Vec3 position;
    private Vec3 tile_size;
    private int seat;

    public RenderHand(Vec3 position, Vec3 tile_size, int seat)
    {
        tiles = new ArrayList<RenderTile>();
        this.position = position;
        this.tile_size = tile_size;
        this.seat = seat;
    }

    public void add_tile(RenderTile tile)
    {
        tiles.add(tile);
        tiles = RenderPlayer.sort_tiles(tiles);
        order_hand();
    }

    public void remove(RenderTile tile)
    {
        tiles.remove(tile);
        tiles = RenderPlayer.sort_tiles(tiles);
        order_hand();
    }

    public ArrayList<RenderTile> get_tiles_type(TileType type)
    {
        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();

        foreach (RenderTile tile in this.tiles)
            if (tile.tile_type.tile_type == type)
                tiles.add(tile);

        return tiles;
    }

    private void order_hand()
    {
        for (int i = 0; i < tiles.size; i++)
        {
            Vec3 pos = Vec3()
            {
                x = (i - ((float)tiles.size - 1) / 2) * tile_size.x,
                y = tile_size.z / 2
            };

            pos = Calculations.rotate_y({}, (float)seat / 2, pos);
            pos = Calculations.vec3_plus(position, pos);
            tiles[i].position = pos;

            Vec3 rot = Vec3()
            {
                x = 0.5f,
                y = 1 - (float)seat / 2
            };

            tiles[i].rotation = rot;
        }
    }

    public ArrayList<RenderTile> tiles { get; private set; }
}

private class RenderPond
{
    private Vec3 position;
    private Vec3 tile_size;
    private int seat;

    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();

    public RenderPond(Vec3 position, Vec3 tile_size, int seat)
    {
        this.position = position;
        this.tile_size = tile_size;
        this.seat = seat;
    }

    public void add(RenderTile tile)
    {
        tiles.add(tile);
        arrange_pond();
    }

    public void remove(RenderTile tile)
    {
        tiles.remove(tile);
        arrange_pond();
    }

    public void arrange_pond()
    {
        for (int i = 0; i < tiles.size; i++)
        {
            RenderTile tile = tiles[i];

            int row = 0;
            int col = i;

            if (i >= 6)
            {
                row++;
                col -= 6;
            }
            if (i >= 12)
            {
                row++;
                col -= 6;
            }

            Vec3 pos = Vec3()
            {
                x = (col - 2.5f) * tile_size.x,
                y = tile_size.y / 2,
                z = row * tile_size.z
            };

            pos = Calculations.rotate_y({}, (float)seat / 2, pos);
            pos = Calculations.vec3_plus(position, pos);
            tile.position = pos;

            Vec3 rot = Vec3()
            {
                y = 1 - (float)seat / 2
            };

            tile.rotation = rot;
        }
    }
}

public class RenderCalls
{
    private ArrayList<RenderCall> calls = new ArrayList<RenderCall>();

    private Vec3 position;
    private Vec3 tile_size;
    private int seat;

    private Vec3 x_dir;
    private Vec3 z_dir;

    public RenderCalls(Vec3 position, Vec3 tile_size, int seat)
    {
        this.position = position;
        this.tile_size = tile_size;
        this.seat = seat;

        x_dir = Vec3() { x = 1 };
        z_dir = Vec3() { z = 1 };
        x_dir = Calculations.rotate_y({}, (float)seat / 2, x_dir);
        z_dir = Calculations.rotate_y({}, (float)seat / 2, z_dir);
    }

    public void add(RenderCall call)
    {
        calls.add(call);
        arrange();
    }

    public RenderCallPon? get_pon(TileType type)
    {
        foreach (RenderCall call in calls)
            if (call.get_type() == typeof(RenderCallPon) &&
                ((RenderCallPon)call).tiles[0].tile_type.tile_type == type)
                    return (RenderCallPon)call;

        return null;
    }

    public void late_kan(RenderCallPon pon, RenderCallLateKan kan)
    {
        int index = calls.index_of(pon);
        calls.remove_at(index);
        calls.insert(index, kan);

        arrange();
    }

    private void arrange()
    {
        float height = 0;

        foreach (RenderCall c in calls)
        {
            Vec3 pos = Calculations.vec3_mul_scalar(z_dir, -height);
            c.arrange(Calculations.vec3_plus(position, pos), x_dir, z_dir, 1 - (float)seat / 2);
            height += c.height;
        }
    }

    public static Alignment players_to_alignment(RenderPlayer caller, RenderPlayer discarder)
    {
        int diff = (discarder.seat - caller.seat + 4) % 4;

        switch (diff)
        {
        case 1:
            return Alignment.RIGHT;
        case 2:
        default:
            return Alignment.CENTER;
        case 3:
            return Alignment.LEFT;
        }
    }

    public abstract class RenderCall : Object
    {
        public abstract void arrange(Vec3 position, Vec3 x_dir, Vec3 z_dir, float y_rotation);
        public abstract float height { get; }
    }

    public class RenderCallLateKan : RenderCall
    {
        private ArrayList<RenderTile> tiles;
        private Vec3 tile_size;
        private Alignment alignment;

        public RenderCallLateKan(ArrayList<RenderTile> tiles, Vec3 tile_size, Alignment alignment)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            this.alignment = alignment;
        }

        public override void arrange(Vec3 position, Vec3 x_dir, Vec3 z_dir, float y_rotation)
        {
            float width = -tile_size.x / 2;
            float bottom = -tile_size.z / 2;
            int n;

            switch (alignment)
            {
            case Alignment.RIGHT:
                n = 0;
                break;
            case Alignment.CENTER:
            default:
                n = 1;
                break;
            case Alignment.LEFT:
                n = 2;
                break;
            }

            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[i];

                float x = width;
                float z = bottom;
                float rotation = y_rotation;

                if (i == n)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2;

                    rotation += 0.5f;
                }
                else if (i == n+1)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2 * 3;

                    rotation += 0.5f;
                    width += tile_size.z;
                }
                else
                {
                    x += tile_size.x / 2;
                    z += tile_size.z / 2;

                    width += tile_size.x;
                }

                tile.rotation = {0, rotation, 0};
                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus({0, tile_size.y / 2, 0});
                tile.position = Calculations.vec3_plus(position, pos);
            }
        }

        public override float height { get { return float.max(tile_size.z, 2 * tile_size.x); } }
    }

    public class RenderCallClosedKan : RenderCall
    {
        private ArrayList<RenderTile> tiles;
        private Vec3 tile_size;

        public RenderCallClosedKan(ArrayList<RenderTile> tiles, Vec3 tile_size)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
        }

        public override void arrange(Vec3 position, Vec3 x_dir, Vec3 z_dir, float y_rotation)
        {
            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[i];

                float rotation = 1;
                if (i == 1 || i == 2)
                    rotation = 1 - rotation;

                tile.rotation = {rotation, y_rotation, 0};
                Vec3 pos = x_dir.mul_scalar(-tile_size.x * i);
                pos = pos.plus({0, tile_size.y / 2, 0});
                tile.position = Calculations.vec3_plus(position, pos);
            }
        }

        public override float height { get { return tile_size.z; } }
    }


    public class RenderCallOpenKan : RenderCall
    {
        private ArrayList<RenderTile> tiles;
        private Vec3 tile_size;
        private Alignment alignment;

        public RenderCallOpenKan(ArrayList<RenderTile> tiles, Vec3 tile_size, Alignment alignment)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            this.alignment = alignment;
        }

        public override void arrange(Vec3 position, Vec3 x_dir, Vec3 z_dir, float y_rotation)
        {
            float width = -tile_size.x / 2;
            float bottom = -tile_size.z / 2;
            int n;

            switch (alignment)
            {
            case Alignment.RIGHT:
                n = 0;
                break;
            case Alignment.CENTER:
            default:
                n = 1;
                break;
            case Alignment.LEFT:
                n = 2;
                break;
            }

            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[i];

                float x = width;
                float z = bottom;
                float rotation = y_rotation;

                if (i == n)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2;

                    rotation += 0.5f;
                    width += tile_size.z;
                }
                else
                {
                    x += tile_size.x / 2;
                    z += tile_size.z / 2;

                    width += tile_size.x;
                }

                tile.rotation = {0, rotation, 0};
                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus({0, tile_size.y / 2, 0});
                tile.position = Calculations.vec3_plus(position, pos);
            }
        }

        public override float height { get { return tile_size.z; } }
    }

    public class RenderCallPon : RenderCall
    {
        private Vec3 tile_size;

        public RenderCallPon(ArrayList<RenderTile> tiles, Vec3 tile_size, Alignment alignment)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            this.alignment = alignment;
        }

        public override void arrange(Vec3 position, Vec3 x_dir, Vec3 z_dir, float y_rotation)
        {
            float width = -tile_size.x / 2;
            float bottom = -tile_size.z / 2;
            int n;

            switch (alignment)
            {
            case Alignment.RIGHT:
                n = 0;
                break;
            case Alignment.CENTER:
            default:
                n = 1;
                break;
            case Alignment.LEFT:
                n = 2;
                break;
            }

            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[i];

                float x = width;
                float z = bottom;
                float rotation = y_rotation;

                if (i == n)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2;

                    rotation += 0.5f;
                    width += tile_size.z;
                }
                else
                {
                    x += tile_size.x / 2;
                    z += tile_size.z / 2;

                    width += tile_size.x;
                }

                tile.rotation = {0, rotation, 0};
                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus({0, tile_size.y / 2, 0});
                tile.position = Calculations.vec3_plus(position, pos);
            }
        }

        public override float height { get { return tile_size.z; } }
        public ArrayList<RenderTile> tiles { get; private set; }
        public Alignment alignment { get; private set; }
    }

    public class RenderCallChi : RenderCall
    {
        private ArrayList<RenderTile> tiles;
        private Vec3 tile_size;
        private Alignment alignment;

        public RenderCallChi(RenderTile discard_tile, ArrayList<RenderTile> tiles, Vec3 tile_size)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            tiles.add(discard_tile);
            ArrayList<RenderTile> sort = RenderPlayer.sort_tiles(tiles);
            this.tiles = new ArrayList<RenderTile>();

            for (int i = sort.size - 1; i >= 0; i--)
                this.tiles.add(sort[i]);

            int index = this.tiles.index_of(discard_tile);

            switch (index)
            {
            case 0:
                alignment = Alignment.RIGHT;
                break;
            case 1:
            default:
                alignment = Alignment.CENTER;
                break;
            case 2:
                alignment = Alignment.LEFT;
                break;
            }
        }

        public override void arrange(Vec3 position, Vec3 x_dir, Vec3 z_dir, float y_rotation)
        {
            float width = -tile_size.x / 2;
            float bottom = -tile_size.z / 2;
            int n;

            switch (alignment)
            {
            case Alignment.RIGHT:
                n = 0;
                break;
            case Alignment.CENTER:
            default:
                n = 1;
                break;
            case Alignment.LEFT:
                n = 2;
                break;
            }

            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[i];

                float x = width;
                float z = bottom;
                float rotation = y_rotation;

                if (i == n)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2;

                    rotation += 0.5f;
                    width += tile_size.z;
                }
                else
                {
                    x += tile_size.x / 2;
                    z += tile_size.z / 2;

                    width += tile_size.x;
                }

                tile.rotation = {0, rotation, 0};
                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus({0, tile_size.y / 2, 0});
                tile.position = Calculations.vec3_plus(position, pos);
            }
        }

        public override float height { get { return tile_size.z; } }
    }

    public enum Alignment
    {
        LEFT,
        CENTER,
        RIGHT
    }
}
