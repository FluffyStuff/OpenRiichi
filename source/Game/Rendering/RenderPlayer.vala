using Gee;

public class RenderPlayer
{
    private Vec3 center;
    private Vec3 tile_size;
    private float player_offset;
    private float wall_offset;
    private bool observed;

    private int draw_count = 0;

    private RenderHand hand;
    private RenderPond pond;
    private RenderCalls calls;
    private RenderRiichi render_riichi;
    private RenderGeometry3D? wind_indicator = null;

    public RenderPlayer(ResourceStore store, Vec3 center, bool dealer, int seat, float player_offset, float wall_offset, Vec3 tile_size, bool observed, Wind round_wind)
    {
        this.center = center;
        this.player_offset = player_offset;
        this.wall_offset = wall_offset;
        this.seat = seat;
        this.tile_size = tile_size;
        this.observed = observed;

        Vec3 pos = Vec3(0, 0, this.player_offset);
        pos = Calculations.rotate_y(Vec3.empty(), (float)seat / 2, pos);
        pos = center.plus(pos);

        hand = new RenderHand(pos, tile_size, seat, observed ? 0.44f : 0);

        pos = Vec3(0, 0, 3 * tile_size.x);
        pos = Calculations.rotate_y(Vec3.empty(), (float)seat / 2, pos);
        pos = center.plus(pos);

        pond = new RenderPond(pos, tile_size, seat);

        pos = Vec3(this.player_offset + tile_size.z / 2, 0, this.player_offset + tile_size.y / 2);
        pos = Calculations.rotate_y(Vec3.empty(), (float)seat / 2, pos);
        pos = center.plus(pos);

        calls = new RenderCalls(pos, tile_size, seat);

        render_riichi = new RenderRiichi(store, tile_size, seat, center, player_offset, tile_size.x * 2.4f);

        if (dealer)
        {
            string wind_string;
            if (round_wind == Wind.SOUTH)
                wind_string = "South";
            else if (round_wind == Wind.WEST)
                wind_string = "West";
            else if (round_wind == Wind.NORTH)
                wind_string = "North";
            else
                wind_string = "East";

            wind_indicator = store.load_geometry_3D("wind_indicator", false);
            RenderBody3D body = ((RenderBody3D)wind_indicator.geometry[0]);
            body.texture = store.load_texture("WindIndicators/" + wind_string);

            pos = Vec3(this.player_offset - body.model.size.x / 2 - (tile_size.x * 2.5f + tile_size.z), 0, this.player_offset);
            pos = Calculations.rotate_y(Vec3.empty(), (float)seat / 2, pos);
            pos = center.plus(pos);
            wind_indicator.position = Vec3(pos.x, pos.y + body.model.size.y / 2, pos.z);
            wind_indicator.rotation = new Quat.from_euler_vec(Vec3(0, -(float)seat / 2, 0));
        }
    }

    public void process(DeltaArgs args)
    {
        render_riichi.process(args);
    }

    public void render(RenderScene3D scene)
    {
        render_riichi.render(scene);

        if (wind_indicator != null)
            scene.add_object(wind_indicator);
    }

    public void draw_tile(RenderTile tile)
    {
        if (++draw_count >= 14)
            hand.draw_tile(tile);
        else
            hand.add_tile(tile);

        last_drawn_tile = tile;
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

    public void ron(RenderTile tile)
    {
        hand.winning_tile = tile;
        hand.order_hand(true);
    }

    public void tsumo()
    {
        hand.winning_tile = last_drawn_tile;
        hand.order_hand(true);
        hand.remove(last_drawn_tile);
    }

    public void open_hand()
    {
        hand.sort_hand();
        hand.order_hand(false);
        hand.view_angle = 0.5f;
        hand.order_hand(true);
    }

    public void close_hand()
    {
        hand.view_angle = -0.5f;
        hand.order_hand(true);
    }

    public void riichi(bool open)
    {
        this.open = open;

        if (open)
            open_hand();

        render_riichi.animate();
        pond.riichi();
        in_riichi = true;
    }

    public void return_riichi()
    {
        render_riichi.animate_return();
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

    public void chii(RenderPlayer discard_player, RenderTile discard_tile, RenderTile tile_1, RenderTile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add(tile_1);
        tiles.add(tile_2);

        RenderCalls.RenderCallChii chii = new RenderCalls.RenderCallChii(discard_tile, tiles, tile_size);
        calls.add(chii);
    }

    public ArrayList<RenderTile> hand_tiles { get { return hand.tiles; } }
    public RenderTile last_drawn_tile { get; private set; }
    public int seat { get; private set; }
    public bool in_riichi { get; private set; }
    public bool open { get { return hand.open; } set { hand.open = value; } } // Open riichi

    public static ArrayList<RenderTile> sort_tiles(ArrayList<RenderTile> list)
    {
        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add_all(list);

        tiles.sort
        (
            (t1, t2) =>
            {
                int a = (int)t1.tile_type.tile_type;
                int b = (int)t2.tile_type.tile_type;
                return (int) (a > b) - (int) (a < b);
            }
        );

        return tiles;
    }
}

private class RenderHand
{
    private Vec3 position;
    private Vec3 tile_size;
    private int seat;

    public RenderHand(Vec3 position, Vec3 tile_size, int seat, float view_angle)
    {
        tiles = new ArrayList<RenderTile>();
        this.position = position;
        this.tile_size = tile_size;
        this.seat = seat;
        this.view_angle = view_angle;
        winning_tile = null;
    }

    public void add_tile(RenderTile tile)
    {
        tiles.add(tile);
        sort_hand();
        order_hand(true);
    }

    public void draw_tile(RenderTile tile)
    {
        winning_tile = null;

        if (tiles.size > 1)
        {
            sort_hand();
            order_hand(true);
            order_draw_tile(tile);
            tiles.add(tile);
        }
        else
        {
            tiles.add(tile);
            sort_hand();
            order_hand(true);
        }
    }

    public void remove(RenderTile tile)
    {
        tiles.remove(tile);
        sort_hand();
        order_hand(true);
    }

    public ArrayList<RenderTile> get_tiles_type(TileType type)
    {
        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();

        foreach (RenderTile tile in this.tiles)
            if (tile.tile_type.tile_type == type)
                tiles.add(tile);

        return tiles;
    }

    public void sort_hand()
    {
        tiles = RenderPlayer.sort_tiles(tiles);
    }

    public void order_hand(bool animate)
    {
        for (int i = 0; i < tiles.size; i++)
            order_tile(tiles[i], i, animate);

        if (winning_tile != null)
            order_tile(winning_tile, tiles.size + 0.5f, animate);
    }

    private void order_tile(RenderTile tile, float tile_position, bool animate)
    {
        Vec3 pos = Vec3
        (
            (tile_position - ((float)tiles.size - 1) / 2) * tile_size.x,
            tile_size.z / 2,
            0
        );

        float anc = -tile_size.y / 2;
        if (view_angle < 0)
            anc *= -1;

        Vec3 anchor = Vec3(0, 0, anc);
        pos = Calculations.rotate_x(anchor, -view_angle, pos);

        pos = Calculations.rotate_y(Vec3.empty(), (float)seat / 2, pos);
        pos = position.plus(pos);

        Quat rot = new Quat.from_euler(0.5f - view_angle, 0, 0).mul(new Quat.from_euler(0, 1 - (float)seat / 2, 0));

        if (animate)
            tile.animate_towards(pos, rot);
        else
            tile.set_absolute_location(pos, rot);
    }

    private void order_draw_tile(RenderTile tile)
    {
        Vec3 pos = Vec3
        (
            (((float)tiles.size - 2) / 2) * tile_size.x,
            tile_size.z + tile_size.x / 2,
            0
        );

        float anc = -tile_size.y / 2;
        if (view_angle < 0)
            anc *= -1;

        Vec3 anchor = Vec3(0, 0, anc);
        pos = Calculations.rotate_x(anchor, -view_angle, pos);

        pos = Calculations.rotate_y({}, (float)seat / 2, pos);
        pos = position.plus(pos);

        Quat rot =
        new Quat.from_euler(0, -0.5f, 0).mul(
        new Quat.from_euler(0.5f - view_angle, 0, 0).mul(
        new Quat.from_euler(0, 1 - (float)seat / 2, 0)));

        tile.animate_towards(pos, rot);
    }

    public ArrayList<RenderTile> tiles { get; private set; }
    public float view_angle { get; set; }
    public RenderTile? winning_tile { get; set; }
    public bool open { get; set; }  // Open riichi
}

private class RenderPond
{
    private Vec3 position;
    private Vec3 tile_size;
    private int seat;

    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
    private RenderTile? riichi_tile = null;
    private bool do_riichi = false;

    public RenderPond(Vec3 position, Vec3 tile_size, int seat)
    {
        this.position = position;
        this.tile_size = tile_size;
        this.seat = seat;
    }

    public void add(RenderTile tile)
    {
        if (do_riichi)
        {
            riichi_tile = tile;
            do_riichi = false;
        }

        tiles.add(tile);
        arrange_pond();
    }

    public void remove(RenderTile tile)
    {
        tiles.remove(tile);
        arrange_pond();

        if (tile == riichi_tile)
            do_riichi = true;
    }

    public void riichi()
    {
        do_riichi = true;
    }

    private void arrange_pond()
    {
        // Top left corner
        float width = -3 * tile_size.x;
        float height = 0;

        for (int i = 0; i < tiles.size; i++)
        {
            RenderTile tile = tiles[i];

            if (i == 6)
            {
                width = -3 * tile_size.x;
                height = tile_size.z;
            }
            else if (i == 12)
            {
                width = -3 * tile_size.x;
                height = 2 * tile_size.z;
            }

            float x;
            float y;
            float r = 0;

            if (tile == riichi_tile)
            {
                x = width + tile_size.z / 2;
                y = height + tile_size.z - tile_size.x / 2;
                r = -0.5f;

                width += tile_size.z;
            }
            else
            {
                x = width + tile_size.x / 2;
                y = height + tile_size.z / 2;

                width += tile_size.x;
            }

            Vec3 pos = Vec3
            (
                x,
                tile_size.y / 2,
                y
            );

            pos = Calculations.rotate_y({}, (float)seat / 2, pos);
            pos = position.plus(pos);
            Quat rot = new Quat.from_euler(0, 1 - (float)seat / 2 + r, 0);

            tile.animate_towards(pos, rot);
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

        x_dir = Vec3(1, 0, 0);
        z_dir = Vec3(0, 0, 1);
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
            Vec3 pos = z_dir.mul_scalar(-height);
            c.arrange(position.plus(pos), x_dir, z_dir, 1 - (float)seat / 2);
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
        public abstract float width { get; }
        public ArrayList<RenderTile> tiles { get; protected set; }
    }

    public class RenderCallLateKan : RenderCall
    {
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

                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus({0, tile_size.y / 2, 0});
                pos = position.plus(pos);
                Quat rot = new Quat.from_euler(0, rotation, 0);

                tile.animate_towards(pos, rot);
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

        public override void arrange(Vec3 position, Vec3 x_dir, Vec3 z_dir, float y_rotation)
        {
            for (int i = 0; i < tiles.size; i++)
            {
                RenderTile tile = tiles[tiles.size - i - 1];

                float rotation = 1;
                if (i == 1 || i == 2)
                    rotation = 1 - rotation;

                Vec3 pos = x_dir.mul_scalar(-tile_size.x * i);
                pos = pos.plus(Vec3(0, tile_size.y / 2, 0));
                pos = position.plus(pos);
                Quat rot = new Quat.from_euler(rotation, y_rotation, 0);

                tile.animate_towards(pos, rot);
            }
        }

        public override float height { get { return tile_size.z; } }
        public override float width { get { return tile_size.x * 4; } }
    }


    public class RenderCallOpenKan : RenderCall
    {
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
                n = 3;
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

                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus(Vec3(0, tile_size.y / 2, 0));
                pos = position.plus(pos);
                Quat rot = new Quat.from_euler(0, rotation, 0);

                tile.animate_towards(pos, rot);
            }
        }

        public override float height { get { return tile_size.z; } }
        public override float width { get { return tile_size.x * 3 + tile_size.z; } }
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

                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus(Vec3(0, tile_size.y / 2, 0));
                pos = position.plus(pos);

                Quat rot = new Quat.from_euler(0, rotation, 0);

                tile.animate_towards(pos, rot);
            }
        }

        public override float height { get { return tile_size.z; } }
        public override float width { get { return tile_size.x * 2 + tile_size.z; } }
        public Alignment alignment { get; private set; }
    }

    public class RenderCallChii : RenderCall
    {
        private Vec3 tile_size;
        private Alignment alignment;

        public RenderCallChii(RenderTile discard_tile, ArrayList<RenderTile> tiles, Vec3 tile_size)
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

                Vec3 pos = x_dir.mul_scalar(-x);
                pos = pos.plus(z_dir.mul_scalar(-z));
                pos = pos.plus(Vec3(0, tile_size.y / 2, 0));
                pos = position.plus(pos);
                Quat rot = new Quat.from_euler(0, rotation, 0);

                tile.animate_towards(pos, rot);
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

class RenderRiichi
{
    private RenderGeometry3D stick;
    private bool visible = false;

    private bool return_animation;
    private bool animation_started = false;
    private bool animation_set_time = false;
    private float animation_time = 0.15f;
    private Vec3 animation_start_position;
    private Vec3 animation_end_position;
    private float animation_start_time = 0;
    private float animation_end_time = 0;

    public RenderRiichi(ResourceStore store, Vec3 tile_size, int seat, Vec3 center, float start_offset, float end_offset)
    {
        stick = store.load_geometry_3D("stick", false);
        RenderBody3D body = ((RenderBody3D)stick.geometry[0]);
        body.texture = store.load_texture("Sticks/Stick1000");

        stick.rotation = new Quat.from_euler_vec(Vec3(0, (float)seat / 2, 0));

        animation_start_position = center.plus(Calculations.rotate_y(Vec3.empty(), (float)seat / 2, Vec3(0, body.model.size.y / 2, start_offset )));
        animation_end_position = center.plus(Calculations.rotate_y(Vec3.empty(), (float)seat / 2, Vec3(0, body.model.size.y / 2, end_offset )));

        float scale = tile_size.x * 0.6f;
        stick.scale = Vec3(scale, scale, scale);
    }

    public void process(DeltaArgs args)
    {
        if (!animation_started)
            return;

        if (animation_set_time)
        {
            animation_start_time = args.time;
            animation_end_time = args.time + animation_time;
            animation_set_time = false;
            visible = true;
        }

        if (args.time >= animation_end_time)
        {
            if (return_animation)
            {
                stick.position = animation_start_position;
                //stick.diffuse_color = Color.with_alpha(0);
            }
            else
            {
                stick.position = animation_end_position;
                //stick.diffuse_color = Color.with_alpha(1);
            }

            return;
        }

        float duration = animation_end_time - animation_start_time;
        float current = args.time - animation_start_time;
        float lerp = current / duration;

        if (return_animation)
            lerp = 1 - lerp;

        Vec3 pos = Vec3.lerp(animation_start_position, animation_end_position, lerp);

        stick.position = pos;
        //stick.diffuse_color = Color.with_alpha(lerp);
    }

    public void render(RenderScene3D scene)
    {
        if (visible)
            scene.add_object(stick);
    }

    public void animate()
    {
        return_animation = false;
        animation_set_time = true;
        animation_started = true;
    }

    public void animate_return()
    {
        return_animation = true;
        animation_set_time = true;
        animation_started = true;
    }
}
