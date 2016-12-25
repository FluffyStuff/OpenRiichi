class ScoringPlayerElement : Control
{
    private Wind wind;
    private string player_name;
    private int points;
    private int transfer;
    private int score;
    private AnimationTimings delays;
    private bool _animate;
    private bool _highlighted = false;

    private bool animation_started;
    private DeltaTimer timer = new DeltaTimer();

    private ImageControl background;
    private LabelControl wind_label;
    private LabelControl score_label;
    private LabelControl points_label;
    private LabelControl transfer_label;
    private int padding = 10;

    public ScoringPlayerElement(int player_index, Wind wind, string player_name, int points, int transfer, int score, AnimationTimings delays, bool animate)
    {
        this.player_index = player_index;
        this.wind = wind;
        this.player_name = player_name;
        this.points = points;
        this.transfer = transfer;
        this.score = score;
        this.delays = delays;
        _animate = animate;
    }

    public override void added()
    {
        resize_style = ResizeStyle.ABSOLUTE;

        background = new ImageControl("Menu/score_background");
        add_child(background);
        size = background.end_size;

        wind_label = new LabelControl();
        add_child(wind_label);
        wind_label.text = WIND_TO_STRING(wind);
        wind_label.inner_anchor = Vec2(0, 0.5f);
        wind_label.outer_anchor = Vec2(0, 0.5f);
        wind_label.font_size = 50;
        wind_label.position = Vec2(padding, 0);
        wind_label.color = Color.blue();

        LabelControl name_label = new LabelControl();
        add_child(name_label);
        name_label.text = player_name;
        name_label.font_size = 40;
        name_label.color = wind_label.color;
        name_label.inner_anchor = Vec2(0, 0);
        name_label.outer_anchor = Vec2(0, 0.5f);
        name_label.position = Vec2(wind_label.size.width + padding * 2, 0);

        points_label = new LabelControl();
        add_child(points_label);
        points_label.font_size = 20;
        points_label.inner_anchor = Vec2(0, 1);
        points_label.outer_anchor = Vec2(0, 0.5f);
        points_label.position = Vec2(wind_label.size.width + padding * 2, 0);
        points_label.color = Color.white();

        transfer_label = new LabelControl();
        add_child(transfer_label);
        transfer_label.inner_anchor = Vec2(0, 1);
        transfer_label.outer_anchor = Vec2(0, 0.5f);
        transfer_label.font_size = 20;

        int p = points;
        if (_animate)
            p -= transfer;
        set_points_text(p, transfer);
        if (_animate)
            transfer_label.visible = false;

        string score_text = score.to_string();
        if (score > 0)
            score_text = "+" + score_text;

        score_label = new LabelControl();
        add_child(score_label);
        score_label.text = score_text;
        score_label.font_size = 40;
        score_label.inner_anchor = Vec2(1, 0);
        score_label.outer_anchor = Vec2(1, 0);
        score_label.visible = false;
        score_label.position = Vec2(-padding, padding);
        if (score >= 0)
            score_label.color = Color.white();
        else
            score_label.color = Color.red();
    }

    public void animate()
    {
        if (transfer == 0)
            return;

        animation_started = true;
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (!animation_started)
            return;

        float time = timer.elapsed(delta) / delays.score_counting_time;

        if (time >= 1)
        {
            animation_started = false;
            time = 1;
        }

        int transfer = (int)Math.roundf(this.transfer * time);
        int points = this.points - this.transfer + transfer;

        set_points_text(points, transfer);
    }

    private void set_points_text(int points, int transfer)
    {
        points_label.text = points.to_string();

        if (transfer > 0)
        {
            transfer_label.text = " (+" + transfer.to_string() + ")";
            transfer_label.color = Color.green();
            transfer_label.visible = true;
        }
        else if (transfer < 0)
        {
            transfer_label.text = " (-" + (-transfer).to_string() + ")";
            transfer_label.color = Color.red();
            transfer_label.visible = true;
        }
        else
            transfer_label.visible = false;

        transfer_label.position = Vec2(wind_label.size.width + padding * 2 + points_label.size.width, 0);
    }

    public bool highlighted
    {
        get { return _highlighted; }
        set
        {
            _highlighted = value;

            if (value)
                background.diffuse_color = Color(0, 0.04f, 0, 1.0f);
            else
                background.diffuse_color = Color(0, 0, 0, 1);
        }
    }

    public bool show_score
    {
        get { return score_label.visible; }
        set { score_label.visible = value; }
    }

    public int player_index { get; private set; }
}
