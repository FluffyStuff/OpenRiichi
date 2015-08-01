using Gee;

public class GameMenuView : View
{
    private ScoringView score_view;

    private ArrayList<GameMenuButton> buttons = new ArrayList<GameMenuButton>();

    private GameMenuButton? mouse_down_button;

    private GameMenuButton chii;
    private GameMenuButton pon;
    private GameMenuButton kan;
    private GameMenuButton riichi;
    private GameMenuButton tsumo;
    private GameMenuButton ron;
    private GameMenuButton conti;

    public signal void chii_pressed();
    public signal void pon_pressed();
    public signal void kan_pressed();
    public signal void riichi_pressed();
    public signal void tsumo_pressed();
    public signal void ron_pressed();
    public signal void continue_pressed();
    public signal void quit();

    private void press_chii() { chii_pressed(); }
    private void press_pon() { pon_pressed(); }
    private void press_kan() { kan_pressed(); }
    private void press_riichi() { riichi_pressed(); }
    private void press_tsumo() { tsumo_pressed(); }
    private void press_ron() { ron_pressed(); }
    private void press_continue() { continue_pressed(); }

    public GameMenuView()
    {

    }

    public override void added()
    {
        float scale = 0.8f;

        chii = new GameMenuButton(store, "Chii");
        pon = new GameMenuButton(store, "Pon");
        kan = new GameMenuButton(store, "Kan");
        riichi = new GameMenuButton(store, "Riichi");
        tsumo = new GameMenuButton(store, "Tsumo");
        ron = new GameMenuButton(store, "Ron");
        conti = new GameMenuButton(store, "Continue");

        chii.clicked.connect(press_chii);
        pon.clicked.connect(press_pon);
        kan.clicked.connect(press_kan);
        riichi.clicked.connect(press_riichi);
        tsumo.clicked.connect(press_tsumo);
        ron.clicked.connect(press_ron);
        conti.clicked.connect(press_continue);

        buttons.add(chii);
        buttons.add(pon);
        buttons.add(kan);
        buttons.add(riichi);
        buttons.add(tsumo);
        buttons.add(ron);
        buttons.add(conti);

        float width = 0;
        foreach (GameMenuButton button in buttons)
        {
            width += button.size.x / 2 * scale;
            button.scale = scale;
        }

        float p = 0;
        foreach (GameMenuButton button in buttons)
        {
            button.position = { button.size.x / 2 * scale - width + p, button.size.y / 2 * scale };
            button.anchor = { 0, -1 };
            p += button.size.x * scale;
        }
    }

    public override void do_process(DeltaArgs delta)
    {
    }

    public override void do_render(RenderState state)
    {
        RenderScene2D scene = new RenderScene2D(state.screen_width, state.screen_height);

        foreach (GameMenuButton button in buttons)
            button.render(scene, { state.screen_width, state.screen_height });

        state.add_scene(scene);
    }

    private GameMenuButton? get_hover_button(Vec2 position)
    {
        foreach (GameMenuButton button in buttons)
            if (button.hover_check(position))
                return button;

        return null;
    }

    protected override void do_mouse_move(MouseMoveArgs mouse)
    {
        Vec2 pos = Vec2() { x = mouse.pos_x, y = mouse.pos_y };

        GameMenuButton? button = null;
        if (!mouse.handled)
            button = get_hover_button(pos);

        foreach (GameMenuButton b in buttons)
        {
            if ((b.hovering = (b == button)))
            {
                mouse.cursor_type = CursorType.HOVER;
                mouse.handled = true;
            }
        }
    }

    protected override void do_mouse_event(MouseEventArgs mouse)
    {
        if (mouse.button == MouseEventArgs.Button.LEFT)
        {
            if (mouse.handled)
            {
                mouse_down_button = null;
                return;
            }

            GameMenuButton? button = get_hover_button({mouse.pos_x, mouse.pos_y});

            if (mouse.down)
                mouse_down_button = button;
            else
            {
                if (button != null && button == mouse_down_button)
                    button.click();

                mouse_down_button = null;
            }
        }
    }

    protected override void do_key_press(KeyArgs key)
    {
        if (key.handled)
            return;

        key.handled = true;

        switch (key.key)
        {
        case 'r':
            quit();
            break;
        default:
            key.handled = false;
            break;
        }
    }

    public void set_chii(bool enabled)
    {
        chii.enabled = enabled;
    }

    public void set_pon(bool enabled)
    {
        pon.enabled = enabled;
    }

    public void set_kan(bool enabled)
    {
        kan.enabled = enabled;
    }

    public void set_riichi(bool enabled)
    {
        riichi.enabled = enabled;
    }

    public void set_tsumo(bool enabled)
    {
        tsumo.enabled = enabled;
    }

    public void set_ron(bool enabled)
    {
        ron.enabled = enabled;
    }

    public void set_continue(bool enabled)
    {
        conti.enabled = enabled;
    }

    public void display_score(ArrayList<Yaku> score)
    {
        score_view = new ScoringView(score);
        add_child(score_view);
    }
}
