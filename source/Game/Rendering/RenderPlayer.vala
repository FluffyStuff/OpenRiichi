using Gee;

public class RenderPlayer
{
    private Vec3 center;
    //private Vec3 hand_position;
    //private Vec3 pond_position;
    //private Vec3 discard_position;
    private float player_offset;
    private float wall_offset;
    private int seat;

    private RenderHand hand;
    //private RenderPond pond;
    //private RenderCalls calls;

    public RenderPlayer(Vec3 center, int seat, float player_offset, float wall_offset, Vec3 tile_size)
    {
        this.center = center;
        this.player_offset = player_offset - 3 * tile_size.z;
        this.wall_offset = wall_offset;
        this.seat = seat;

        Vec3 pos = Vec3() { z = - this.player_offset };

        pos = Calculations.rotate_y({}, (float)seat / 2, pos);
        pos = Calculations.vec3_plus(center, pos);
        print("Seat: " + seat.to_string() + " PosX: " + pos.x.to_string() + " PosY: " + pos.y.to_string() + " PosZ: " + pos.z.to_string() + "\n");

        hand = new RenderHand(pos, seat);
        //pond = new RenderPond();
        //calls = new RenderCalls();
    }

    public void add_to_hand(RenderTile tile)
    {
        hand.add_tile(tile);
    }

    public ArrayList<RenderTile> hand_tiles { get { return hand.tiles; } }
}

private class RenderHand
{
    private Vec3 tile_size;
    private Vec3 position;
    private int seat;

    public RenderHand(Vec3 position, int seat)
    {
        tiles = new ArrayList<RenderTile>();
        this.position = position;
        this.seat = seat;
    }

    public void add_tile(RenderTile tile)
    {
        tile_size = tile.object_size;
        tiles.add(tile);
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
                x = -0.5f/*,
                y = (float)seat / 2*/
            };

            tiles[i].rotation = {0,0,0};
            tiles[i].rotation = rot;
        }
    }

    public ArrayList<RenderTile> tiles { get; private set; }
}
