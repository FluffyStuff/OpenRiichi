using Gee;

public class GameMenuView : View2D
{
    private ScoringView score_view;

    private ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

    private Sound hint_sound;
    private int decision_time;
    private float start_time;
    private LabelControl timer;

    private MenuTextButton chii;
    private MenuTextButton pon;
    private MenuTextButton kan;
    private MenuTextButton riichi;
    private MenuTextButton tsumo;
    private MenuTextButton ron;
    private MenuTextButton conti;

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

    public GameMenuView(int decision_time)
    {
        this.decision_time = decision_time;
    }

    public override void added()
    {
        hint_sound = store.audio_player.load_sound("hint");

        int padding = 30;
        timer = new LabelControl();
        add_child(timer);
        timer.inner_anchor = Vec2(1, 0);
        timer.outer_anchor = Vec2(1, 0);
        timer.position = Vec2(-padding, padding);
        timer.font_size = 60;
        timer.visible = false;

        chii = new MenuTextButton("MenuButtonSmall", "Chii");
        pon = new MenuTextButton("MenuButtonSmall", "Pon");
        kan = new MenuTextButton("MenuButtonSmall", "Kan");
        riichi = new MenuTextButton("MenuButtonSmall", "Riichi");
        tsumo = new MenuTextButton("MenuButtonSmall", "Tsumo");
        ron = new MenuTextButton("MenuButtonSmall", "Ron");
        conti = new MenuTextButton("MenuButtonSmall", "Continue");

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

        float scale = 1;
        float width = 0;

        foreach (var button in buttons)
        {
            add_child(button);
            button.enabled = false;
            button.inner_anchor = Vec2(0.5f, 0);
            button.outer_anchor = Vec2(0.5f, 0);
            button.font_size = 24;
            //button.size = Size2(scale, scale);

            width += button.size.width / 2 * scale;
        }

        float p = 0;
        foreach (var button in buttons)
        {
            button.position = Vec2(button.size.width / 2 * scale - width + p, 0);
            p += button.size.width * scale;
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
        if (enabled)
            hint_sound.play();
        conti.enabled = enabled;
    }

    public void set_timer(bool enabled)
    {
        start_time = 0;
        timer.visible = enabled;
    }

    public void display_score(RoundScoreState score, int player_index, int round_time, int hanchan_time, int game_time)
    {
        score_view = new ScoringView(score, player_index, round_time, hanchan_time, game_time);
        add_child(score_view);
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (start_time == 0)
            start_time = delta.time;

        if (!timer.visible)
            return;

        int t = int.max((int)(start_time + decision_time - delta.time), 0);
        timer.color = t < 3 ? Color.red() : Color.white();

        string str = t.to_string();

        if (str != timer.text)
            timer.text = str;
    }
}
