using Engine;
using Gee;

public class RenderCalls : WorldObject
{
    private ArrayList<RenderCall> calls = new ArrayList<RenderCall>();

    private GameRenderContext context;
    private Vec3 tile_size;

    public RenderCalls(GameRenderContext context)
    {
        this.context = context;
        this.tile_size = context.tile_size;
    }

    public void add_call(RenderCall call)
    {
        add_object(call);
        calls.add(call);
        arrange();
    }

    public RenderCallPon? get_pon(TileType type)
    {
        foreach (RenderCall call in calls)
            if (call is RenderCallPon &&
                ((RenderCallPon)call).tiles[0].tile_type.tile_type == type)
                    return (RenderCallPon)call;

        return null;
    }

    public void late_kan(RenderCallPon pon, RenderCallLateKan kan)
    {
        int index = calls.index_of(pon);
        calls.remove_at(index);
        calls.insert(index, kan);
        add_object(kan);

        arrange();
        remove_object(pon);
    }

    private void arrange()
    {
        float height = 0;

        foreach (RenderCall call in calls)
        {
            call.animate_to(-height, context.server_times.tile_discard);
            height += call.height;
            call.arrange(context.server_times.tile_discard);
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

    public abstract class RenderCall : WorldObject
    {
        public abstract void arrange(AnimationTime time);
        public abstract float height { get; }
        public abstract float width { get; }
        public ArrayList<RenderTile> tiles { get; protected set; }

        protected void animate_tile(RenderTile tile, Vec3 pos, Quat rot, AnimationTime? time)
        {
            if (time != null)
                tile.animate_towards(pos, rot, time);
            else
                tile.set_absolute_location(pos, rot);
        }

        public void animate_to(float height, AnimationTime time)
        {
            WorldObjectAnimation animation = new WorldObjectAnimation(time);
            Path3D path = new LinearPath3D(Vec3(0, 0, height));
            animation.do_absolute_position(path);
            animation.curve = new SmoothApproachCurve();
            
            cancel_buffered_animations();
            animate(animation, true);
        }
    }

    public class RenderCallLateKan : RenderCall
    {
        private Vec3 tile_size;
        private Alignment alignment;

        public RenderCallLateKan(ArrayList<RenderTile> tiles, RenderTile kan_tile, Vec3 tile_size, Alignment alignment)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            this.alignment = alignment;

            int n;
            switch (alignment)
            {
            case Alignment.RIGHT:
                n = 1;
                break;
            case Alignment.CENTER:
            default:
                n = 2;
                break;
            case Alignment.LEFT:
                n = 3;
                break;
            }

            tiles.insert(n, kan_tile);
        }

        protected override void arrange(AnimationTime time = new AnimationTime.zero())
        {
            foreach (RenderTile tile in tiles)
                convert_object(tile);
        
            float width = 0;
            float bottom = 0;
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
                float rotation = 0;

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

                Vec3 pos = Vec3(-x, 0, -z);
                Quat rot = Quat.from_euler(rotation, 0, 0);

                animate_tile(tile, pos, rot, time);
            }
        }

        public override float height { get { return float.max(tile_size.z, 2 * tile_size.x); } }
        public override float width { get { return tile_size.x * 2 + tile_size.z; } }
    }

    public class RenderCallClosedKan : RenderCall
    {
        private Vec3 tile_size;

        public RenderCallClosedKan(ArrayList<RenderTile> tiles, Vec3 tile_size)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
        }

        protected override void arrange(AnimationTime time = new AnimationTime.zero())
        {
            foreach (RenderTile tile in tiles)
                convert_object(tile);
        
            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[tiles.size - i - 1];

                Vec3 pos = Vec3(-tile_size.x * (i + 0.5f), 0, -tile_size.z / 2);
                Quat rot = Quat.from_euler(0, (i == 1 || i == 2) ? 1 : 0, 0);

                animate_tile(tile, pos, rot, time);
            }
        }

        public override float height { get { return tile_size.z; } }
        public override float width { get { return tile_size.x * 4; } }
    }

    public class RenderCallOpenKan : RenderCall
    {
        private Vec3 tile_size;
        private Alignment alignment;

        public RenderCallOpenKan(ArrayList<RenderTile> tiles, RenderTile discard_tile, Vec3 tile_size, Alignment alignment)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            this.alignment = alignment;

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
                n = 3;
                break;
            }

            tiles.insert(n, discard_tile);
        }

        protected override void arrange(AnimationTime time = new AnimationTime.zero())
        {
            foreach (RenderTile tile in tiles)
                convert_object(tile);
        
            float width = 0;
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
                n = 3;
                break;
            }

            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[i];

                float x = width;
                float z = 0;
                float rotation = 0;

                if (i == n)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2;

                    rotation = 0.5f;
                    width += tile_size.z;
                }
                else
                {
                    x += tile_size.x / 2;
                    z += tile_size.z / 2;

                    width += tile_size.x;
                }

                Vec3 pos = Vec3(-x, 0, -z);
                Quat rot = Quat.from_euler(rotation, 0, 0);

                animate_tile(tile, pos, rot, time);
            }
        }

        public override float height { get { return tile_size.z; } }
        public override float width { get { return tile_size.x * 3 + tile_size.z; } }
    }

    public class RenderCallPon : RenderCall
    {
        private Vec3 tile_size;

        public RenderCallPon(ArrayList<RenderTile> tiles, RenderTile discard_tile, Vec3 tile_size, Alignment alignment)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            this.alignment = alignment;

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

            tiles.insert(n, discard_tile);
        }

        protected override void arrange(AnimationTime time = new AnimationTime.zero())
        {
            foreach (RenderTile tile in tiles)
                convert_object(tile);

            float width = 0;
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
                float z = 0;
                float rotation = 0;

                if (i == n)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2;

                    rotation = 0.5f;
                    width += tile_size.z;
                }
                else
                {
                    x += tile_size.x / 2;
                    z += tile_size.z / 2;

                    width += tile_size.x;
                }

                Vec3 pos = Vec3(-x, 0, -z);
                Quat rot = Quat.from_euler(rotation, 0, 0);

                animate_tile(tile, pos, rot, time);
            }
        }

        public override float height { get { return tile_size.z; } }
        public override float width { get { return tile_size.x * 2 + tile_size.z; } }
        public Alignment alignment { get; private set; }
    }

    public class RenderCallChii : RenderCall
    {
        private Vec3 tile_size;

        public RenderCallChii(ArrayList<RenderTile> tiles, RenderTile discard_tile, Vec3 tile_size)
        {
            this.tiles = tiles;
            this.tile_size = tile_size;
            ArrayList<RenderTile> sort = RenderTile.sort_tiles(tiles);
            this.tiles = new ArrayList<RenderTile>();

            for (int i = sort.size - 1; i >= 0; i--)
                this.tiles.add(sort[i]);
                
            this.tiles.add(discard_tile);
        }

        protected override void arrange(AnimationTime time = new AnimationTime.zero())
        {
            foreach (RenderTile tile in tiles)
                convert_object(tile);

            float width = 0;
            int n = 2;

            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[i];

                float x = width;
                float z = 0;
                float rotation = 0;

                if (i == n)
                {
                    x += tile_size.z / 2;
                    z += tile_size.x / 2;

                    rotation = 0.5f;
                    width += tile_size.z;
                }
                else
                {
                    x += tile_size.x / 2;
                    z += tile_size.z / 2;

                    width += tile_size.x;
                }

                Vec3 pos = Vec3(-x, 0, -z);
                Quat rot = Quat.from_euler(rotation, 0, 0);

                animate_tile(tile, pos, rot, time);
            }
        }

        public override float height { get { return tile_size.z; } }
        public override float width { get { return tile_size.x * 2 + tile_size.z; } }
    }

    public enum Alignment
    {
        SELF = 0,
        RIGHT = 1,
        CENTER = 2,
        LEFT = 3
    }
}