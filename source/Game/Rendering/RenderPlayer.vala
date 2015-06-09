using Gee;

public class RenderPlayer
{
    private Vec3 center;
    private float player_offset;
    private float wall_offset;
    private int seat;

    private RenderHand hand;
    //private RenderPond pond;
    //private RenderCalls calls;

    public RenderPlayer(Vec3 center, int seat, float player_offset, float wall_offset)
    {
        this.center = center;
        this.player_offset = player_offset;
        this.wall_offset = wall_offset;
        this.seat = seat;

        Vec3 pos = center;
        pos.z -= player_offset;
        hand = new RenderHand(pos);
        //pond = new RenderPond();
        //calls = new RenderCalls();
    }

    public void add_to_hand(RenderTile tile)
    {
        hand.add_tile(tile);
    }

    //private void
}

private class RenderHand
{
    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
    private Vec3 tile_size;
    private Vec3 position;

    public RenderHand(Vec3 position)
    {
        this.position = position;
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
                x = (i - ((float)tiles.size + 1) / 2) * tile_size.x,
                y = tile_size.z / 2,
                z = tile_size.z * 5
            };
            pos.x += position.x;
            pos.y += position.y;
            pos.z += position.z;
            tiles[i].position = pos;

            Vec3 rot = Vec3()
            {
                x = -0.5f
            };

            tiles[i].rotation = rot;
        }
    }
}
