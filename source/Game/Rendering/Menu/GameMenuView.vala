using Gee;

public class GameMenuView : View2D
{
    private ScoringView score_view;

    private ArrayList<GameMenuButton> buttons = new ArrayList<GameMenuButton>();

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

        float scale = 0.8f;
        float width = 0;

        foreach (GameMenuButton button in buttons)
        {
            add_control(button);
            button.enabled = false;
            button.inner_anchor = Vec2(0.5f, 0);
            button.outer_anchor = Vec2(0.5f, 0);
            button.scale = Size2(scale, scale);

            width += button.size.x / 2 * scale;
        }

        float p = 0;
        foreach (GameMenuButton button in buttons)
        {
            button.position = Vec2(button.size.x / 2 * scale - width + p, 0);
            p += button.size.x * scale;
        }
    }

    /*public override void do_render(RenderState state)
    {
        RenderScene2D scene = new RenderScene2D(state.screen_size);

        foreach (GameMenuButton button in buttons)
            button.render(scene);

        state.add_scene(scene);
    }*/

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

    public void display_score(RoundScoreState score, int player_index, int round_time, int hanchan_time, int game_time)
    {
        score_view = new ScoringView(score, player_index, round_time, hanchan_time, game_time);
        add_child(score_view);
    }
}