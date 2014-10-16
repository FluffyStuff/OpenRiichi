using Gee;
using GL;

// TODO: Add classes for hand and calls
public class Player : Object
{
    private ArrayList<Tile> pond = new ArrayList<Tile>();
    private ArrayList<Tile> stolen_tiles = new ArrayList<Tile>();
    private ArrayList<Chi> chis = new ArrayList<Chi>();
    private ArrayList<Kan> kans = new ArrayList<Kan>();
    private float call_height = -2.9f;
    private float pond_height = -1.1f;
    private float hand_height = -2.43f;
    private Stick riichi_stick = new Stick("Ten1000", 1000);

    public Player(int position, string name)
    {
        this.name = name;
        this.position = position;
        riichi_turn = -1;
        hand = new ArrayList<Tile>();
        pons = new ArrayList<Pon>();
        calls = new ArrayList<Call>();
        state = PlayerState.READY;
        computer_player = true;
        riichi_stick.position = new Vector(0, -0.6f, 0);
    }

    public void add_tile(Tile t)
    {
        hand.add(t);
    }

    public void draw_tile(Tile t)
    {
        if (!computer_player)
        {
            if (hand.size <= 1)
            {
                t.position = new Vector(Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2 + Tile.TILE_SPACING, -2.6f, Tile.TILE_WIDTH / 2 - 0.05f);
                t.rotation = new Vector(40, 0, 90);
            }
            else if (hand.size <= 4)
            {
                t.position = new Vector(Tile.TILE_HEIGHT / 2, hand_height, Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2 - 0.14f);
                t.rotation = new Vector(40, 0, 90);
            }
            else
            {
                t.position = new Vector((Tile.TILE_WIDTH + Tile.TILE_SPACING) * ((hand.size - 2) / 2.0f) + Tile.TILE_HEIGHT / 2, hand_height, Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2 - 0.14f);
                t.rotation = new Vector(40, 0, 90);
            }
        }
        else
        {
            if (hand.size <= 1)
            {
                t.position = new Vector(Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2 + Tile.TILE_SPACING, -2.7f, Tile.TILE_WIDTH / 2);
                t.rotation = new Vector(90, 0, 90);
            }
            else if (hand.size <= 4)
            {
                t.position = new Vector(Tile.TILE_HEIGHT / 2, -2.7f, Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2);
                t.rotation = new Vector(90, 0, 90);
            }
            else
            {
                t.position = new Vector((Tile.TILE_WIDTH + Tile.TILE_SPACING) * ((hand.size - 2) / 2.0f) + Tile.TILE_HEIGHT / 2, -2.7f, Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2);
                t.rotation = new Vector(90, 0, 90);
            }
        }

        hand.add(t);
    }

    public void discard_tile(Tile t)
    {
        do_discard_tile(t, false);
    }

    private void do_discard_tile(Tile t, bool riichi)
    {
        Sound.play_sound("tile");
        t.position = new Vector.empty();
        t.rotation = new Vector.empty();
        hand.remove(t);
        pond.add(t);

        float x;
        float y;
        if (pond.size < 18)
        {
            x = ((pond.size - 1) % 6 - 2.5f) * Tile.TILE_WIDTH;
            y = pond_height - (pond.size - 1) / 6 * Tile.TILE_HEIGHT;
        }
        else
        {
            x = ((pond.size - 13) - 2.5f) * Tile.TILE_WIDTH;
            y = pond_height - 2 * Tile.TILE_HEIGHT;
        }

        t.position = new Vector(x, y, 0);
        t.rotation = new Vector.empty();

        arrange_hand();
    }

    public bool call_decision(Tile discard_tile, bool can_chi)
    {
        if (!Logic.can_win_with(hand, discard_tile) &&
            (in_riichi ||
            (!Logic.can_pon(discard_tile, hand) &&
            !Logic.can_open_kan(discard_tile, hand) &&
            (!can_chi || !Logic.can_chi(discard_tile, hand)))))
        {
            call_action = null;
            state = PlayerState.READY;
            return false;
        }

        state = PlayerState.DECIDING;

        if (computer_player)
            Threading.start3(call_decision_thread, this, discard_tile, new Obj<bool>(can_chi));


        return true;
    }

    private static void call_decision_thread(Object player_obj, Object tile_obj, Object can_chi_obj)
    {
        Player p = (Player)player_obj;
        Tile discard_tile = (Tile)tile_obj;
        bool can_chi = ((Obj<bool>)can_chi_obj).obj;

        p.call_action = Bot.make_call(0, p, discard_tile, can_chi);
        p.state = PlayerState.READY;
    }

    public bool turn_decision()
    {
        if (in_riichi &&
            !Logic.winning_hand(hand) &&
            !Logic.can_riichi_closed_kan(hand))
        {
            turn_action = new TurnAction.discard(hand[hand.size - 1]);
            state = PlayerState.READY;
            return false;
        }

        state = PlayerState.DECIDING;

        if (computer_player)
            Threading.start1(turn_decision_thread, this);

        if (in_riichi)
            return Logic.can_riichi_closed_kan(hand) || Logic.winning_hand(hand);
        else
            return
            Logic.can_closed_kan(hand) ||
            Logic.can_late_kan(hand, pons) ||
            (!open_hand && Logic.can_tenpai(hand).size != 0) ||
            Logic.winning_hand(hand);
    }

    private static void turn_decision_thread(Object player_obj)
    {
        Player p = (Player)player_obj;

        p.turn_action = Bot.make_move(0, p);

        if (p.turn_action != null)
            p.state = PlayerState.READY;
    }

    public void arrange_hand()
    {
        Tile.sort_tiles(hand);

        for (int i = 0; i < hand.size; i++)
        {
            hand[i].position = new Vector((i - (hand.size - 1) / 2.0f) * (Tile.TILE_WIDTH + Tile.TILE_SPACING), -2.7f, 0);
            hand[i].rotation = new Vector(computer_player ? 90 : 40, 0, 0);
        }
    }

    public void do_chi(Tile[] tiles, Tile discard_tile)
    {
        Sound.play_sound("chi");

        if (tiles[0].tile_type > tiles[1].tile_type)
        {
            Tile t = tiles[0];
            tiles[0] = tiles[1];
            tiles[1] = t;
        }

        Tile[] chi = new Tile[] { discard_tile, tiles[0], tiles[1] };
        Chi call = new Chi(chi);
        chis.add(call);
        calls.add(call);
        float x = 2.5f;
        float y = call_height;
        call_height += Tile.TILE_HEIGHT;

        float extra = (discard_tile.tile_type > tiles[0].tile_type ? Tile.TILE_WIDTH : 0) + (discard_tile.tile_type > tiles[1].tile_type ? Tile.TILE_WIDTH : 0);
        discard_tile.position = new Vector(x + extra, y + Tile.TILE_WIDTH / 2, 0);
        tiles[0].position = new Vector(x + Tile.TILE_WIDTH / 2 - (tiles[0].tile_type < discard_tile.tile_type ? Tile.TILE_HEIGHT : 0), y, 0);
        tiles[1].position = new Vector(x + Tile.TILE_WIDTH / 2 * 3 - (tiles[1].tile_type < discard_tile.tile_type ? Tile.TILE_HEIGHT : 0), y, 0);

        discard_tile.rotation = new Vector(0, 0, 90);
        tiles[0].rotation = new Vector.empty();
        tiles[1].rotation = new Vector.empty();

        hand.remove(tiles[0]);
        hand.remove(tiles[1]);
        arrange_hand();
    }

    public void do_pon(Tile[] tiles, Tile discard_tile, int discard_player)
    {
        Sound.play_sound("pon");

        int direction;

        if ((position + 1) % 4 == discard_player)
            direction = Direction.RIGHT;
        else if ((position + 2) % 4 == discard_player)
            direction = Direction.FRONT;
        else
            direction = Direction.LEFT;

        Tile[] pon;
        if (direction == Direction.LEFT)
             pon = new Tile[] { discard_tile, tiles[0], tiles[1] };
        else if (direction == Direction.FRONT)
             pon = new Tile[] { tiles[0], discard_tile, tiles[1] };
        else
             pon = new Tile[] { tiles[0], tiles[1], discard_tile };

        Pon call = new Pon(pon, direction);
        pons.add(call);
        calls.add(call);
        float x = 2.5f;
        float y = call_height;
        call_height += Tile.TILE_HEIGHT;

        discard_tile.position = new Vector(x + (direction + 1) * Tile.TILE_WIDTH, y + Tile.TILE_WIDTH / 2, 0);
        tiles[0].position = new Vector(x + Tile.TILE_WIDTH / 2 - (direction != Direction.LEFT ? Tile.TILE_HEIGHT : 0), y, 0);
        tiles[1].position = new Vector(x + Tile.TILE_WIDTH / 2 * 3 - (direction == Direction.RIGHT ? Tile.TILE_HEIGHT : 0), y, 0);

        discard_tile.rotation = new Vector(0, 0, 90);
        tiles[0].rotation = new Vector.empty();
        tiles[1].rotation = new Vector.empty();

        hand.remove(tiles[0]);
        hand.remove(tiles[1]);
        arrange_hand();
    }

    public void do_open_kan(Tile[] tiles, Tile discard_tile, int discard_player)
    {
        Sound.play_sound("kan");

        int direction;

        if ((position + 1) % 4 == discard_player)
            direction = Direction.RIGHT;
        else if ((position + 2) % 4 == discard_player)
            direction = Direction.FRONT;
        else
            direction = Direction.LEFT;

        Tile[] kan = new Tile[] { discard_tile, tiles[0], tiles[1], tiles[2] };
        Kan call = new Kan(kan, 0, true);
        kans.add(call);
        calls.add(call);
        float x = 2.5f - Tile.TILE_WIDTH;
        float y = call_height;
        call_height += Tile.TILE_HEIGHT;

        float extra = 0;
        if (direction == Direction.FRONT)
            extra = Tile.TILE_WIDTH;
        else if (direction == Direction.RIGHT)
            extra = Tile.TILE_WIDTH * 3;

        discard_tile.position = new Vector(x + extra, y + Tile.TILE_WIDTH / 2, 0);
        tiles[0].position = new Vector(x + Tile.TILE_WIDTH / 2 - (direction != Direction.LEFT ? Tile.TILE_HEIGHT : 0), y, 0);
        tiles[1].position = new Vector(x + Tile.TILE_WIDTH / 2 * 3 - (direction == Direction.RIGHT ? Tile.TILE_HEIGHT : 0), y, 0);
        tiles[2].position = new Vector(x + Tile.TILE_WIDTH / 2 * 5 - (direction == Direction.RIGHT ? Tile.TILE_HEIGHT : 0), y, 0);

        discard_tile.rotation = new Vector(0, 0, 90);
        tiles[0].rotation = new Vector.empty();
        tiles[1].rotation = new Vector.empty();
        tiles[2].rotation = new Vector.empty();

        hand.remove(tiles[0]);
        hand.remove(tiles[1]);
        hand.remove(tiles[2]);
        arrange_hand();
    }

    public void do_closed_kan(Tile[] tiles)
    {
        Sound.play_sound("kan");
        Tile[] kan = new Tile[] { tiles[0], tiles[1], tiles[2], tiles[3] };
        Kan call = new Kan(kan, 0, false);
        kans.add(call);
        calls.add(call);
        float x = 2.5f - Tile.TILE_WIDTH;
        float y = call_height;
        call_height += Tile.TILE_HEIGHT;

        tiles[0].position = new Vector(x - Tile.TILE_WIDTH / 2, y, 0);
        tiles[1].position = new Vector(x + Tile.TILE_WIDTH / 2, y, Tile.TILE_LENGTH);
        tiles[2].position = new Vector(x + Tile.TILE_WIDTH / 2 * 3, y, Tile.TILE_LENGTH);
        tiles[3].position = new Vector(x + Tile.TILE_WIDTH / 2 * 5, y, 0);

        tiles[0].rotation = new Vector(0, 0, 0);
        tiles[1].rotation = new Vector(0, 180, 0);
        tiles[2].rotation = new Vector(0, 180, 0);
        tiles[3].rotation = new Vector(0, 0, 0);

        hand.remove(tiles[0]);
        hand.remove(tiles[1]);
        hand.remove(tiles[2]);
        hand.remove(tiles[3]);
        arrange_hand();
    }

    public void do_late_kan(Tile tile, Pon pon)
    {
        Sound.play_sound("kan");

        pons.remove(pon);
        Tile[] kan = new Tile[] { tile, pon.tiles[0], pon.tiles[1], pon.tiles[2] };
        Kan call = new Kan(kan, 0, true);
        kans.add(call);

        float add = float.max(0, Tile.TILE_WIDTH * 2 - Tile.TILE_HEIGHT);

        if (add > 0)
        {
            for (int i = calls.index_of(pon) + 1; i < calls.size; i++)
                foreach (Tile t in calls[i].tiles)
                    t.position.y += add;
            call_height += add;
        }

        calls.insert(calls.index_of(pon), call);
        calls.remove(pon);

        tile.position = new Vector(pon.tiles[pon.direction + 1].position.x, pon.tiles[pon.direction + 1].position.y + Tile.TILE_WIDTH, 0);
        tile.rotation = new Vector(0, 0, 90);

        hand.remove(tile);

        arrange_hand();
    }

    public void do_riichi(bool open, int turn, Tile tile)
    {
        Sound.play_sound("riichi");
        riichi_turn = turn;
        riichi_stick.visible = true;
        do_discard_tile(tile, true);
    }

    public void do_tsumo()
    {
        Sound.play_sound("tsumo");
        show_hand();
    }

    public void do_ron(Tile tile)
    {
        Sound.play_sound("ron");
        hand.add(tile);
        show_hand();
    }

    private void show_hand()
    {
        Sound.play_sound("tile");
        arrange_hand();

        foreach (Tile t in hand)
            t.rotation = new Vector.empty();
    }

    public void steal_tile(Tile t)
    {
        pond.remove(t);
        stolen_tiles.add(t);
    }

    public void render()
    {
        glPushMatrix();

        // TODO: This kind of rotation is really stupid, since the pieces already have position information,
        // but this is good for quickly seeing something visual.
        glRotatef(90 * position, 0, 0, 1);

        foreach (Tile t in hand)
            t.render();
        foreach (Tile t in pond)
            t.render();
        foreach (Call c in calls)
            foreach (Tile t in c.tiles)
                t.render();
        riichi_stick.render();
        glPopMatrix();
    }

    public void render_selection()
    {
        glPushMatrix();
        glRotatef(90 * position, 0, 0, 1);
        foreach (Tile t in hand)
            t.render_selection();
        glPopMatrix();
    }

    public Tile? tile_press(uint color_ID)
    {
        foreach (Tile t in hand)
            if ((t.hovering = (t.color_ID == color_ID)))
            {
                return t;
            }

        return null;
    }

    public bool hover(uint tile_ID)
    {
        bool hovering = false;

        foreach (Tile t in hand)
            if ((t.hovering = (t.color_ID == tile_ID)))
                hovering = true;

        return hovering;
    }

    public void clear_hover()
    {
        foreach (Tile t in hand)
            t.hovering = false;
    }

    public string name { get; private set; }
    public int position { get; private set; }
    public ArrayList<Tile> hand { get; private set; }
    public ArrayList<Pon> pons { get; private set; }
    public ArrayList<Call> calls { get; private set; }
    public PlayerState state { get; set; }

    // TODO: Change from bool to enum or even a class
    public bool computer_player { get; set; }
    //public int computer_level { get; set; }
    public CallAction? call_action { get; set; }
    public TurnAction? turn_action { get; set; }
    public int riichi_turn { get; private set; }
    public bool in_riichi { get { return riichi_turn != -1; } }
    public bool open_hand
    {
        get
        {
            if (chis.size != 0 || pons.size != 0)
                return true;

            foreach (Kan kan in kans)
                if (kan.open)
                    return true;

            return false;
        }
    }

    public enum PlayerState
    {
        READY,
        DECIDING,
        WAITING_PON,
        WAITING_KAN,
        WAITING_CHI
    }
}
