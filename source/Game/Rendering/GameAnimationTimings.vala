using Engine;

public class GameRenderContext
{
    public GameRenderContext(AnimationTimings server_times, float tile_scale, Vec3 tile_size, int observer_index, int dealer, int wall_split)
    {
        this.server_times = server_times;
        this.tile_scale = tile_scale;
        this.tile_size = tile_size;
        this.observer_index = observer_index;
        this.dealer = dealer;
        this.wall_split = wall_split;
    }

    public float tile_scale { get; private set; }
    public Vec3 tile_size { get; private set; }
    public int observer_index { get; private set; }
    public int dealer { get; private set; }
    public int wall_split { get; private set; }

    public AnimationTimings server_times { get; private set; }
    /*public AnimationTime hand_angle { get; private set; }
    public AnimationTime hand_order { get; private set; }*/
}