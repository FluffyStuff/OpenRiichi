using Gee;

public class RenderPlayer
{
    private Vec3 center;
    //private Vec3 hand_position;
    //private Vec3 pond_position;
    //private Vec3 discard_position;
    private float player_offset;
    private float wall_offset;

    private RenderHand hand;
    private RenderPond pond;
    //private RenderCalls calls;

    public RenderPlayer(Vec3 center, int seat, float player_offset, float wall_offset, Vec3 tile_size)
    {
        this.center = center;
        this.player_offset = player_offset - 3 * tile_size.z;
        this.wall_offset = wall_offset + tile_size.z * 3;
        this.seat = seat;

        Vec3 pos = Vec3() { z = this.player_offset };
        pos = Calculations.rotate_y({}, (float)seat / 2, pos);
        pos = Calculations.vec3_plus(center, pos);

        hand = new RenderHand(pos, tile_size, seat);

        pos = Vec3() { z = this.wall_offset };
        pos = Calculations.rotate_y({}, (float)seat / 2, pos);
        pos = Calculations.vec3_plus(center, pos);

        pond = new RenderPond(pos, tile_size, seat);
        //calls = new RenderCalls();
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

    public void order_tiles()
    {
        hand.order_tiles();
    }

    public ArrayList<RenderTile> hand_tiles { get { return hand.tiles; } }
    public int seat { get; private set; }
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
        order_tiles();
    }

    public void remove(RenderTile tile)
    {
        tiles.remove(tile);
        order_tiles();
    }

    public void order_tiles()
    {

        CompareFunc<RenderTile> cmp = (t1, t2) =>
        {
            int a = (int)t1.tile_type.tile_type;
            int b = (int)t2.tile_type.tile_type;
            return (int) (a > b) - (int) (a < b);
        };

        tiles.sort(cmp);

        order_hand();
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
