using Gee;

class ScoringView : View2D
{
	private RoundScoreState[] scores;
    private int player_index;
    private AnimationTimings delays;
    private int score_index;
    private LabelControl time_label;
    private LabelControl score_label;
    private RectangleControl rectangle;
    private MenuTextButton ready_button;
    private GameMenuButton next_score_button;
    private GameMenuButton prev_score_button;
    private ScoringInnerView scoring_view;
    private int padding = 10;
    private bool display_timer;
    private float time;
    private float start_time;

    public signal void score_finished();

    public ScoringView(int player_index, AnimationTimings delays)
    {
        this.player_index = player_index;
        this.delays = delays;
        relative_size = Size2(0.9f, 0.9f);
    }

    public override void added()
    {
        ResetContainer reset = new ResetContainer();
        add_child(reset);
        rectangle = new RectangleControl();
        reset.add_child(rectangle);
        rectangle.resize_style = ResizeStyle.RELATIVE;
        rectangle.color = Color.with_alpha(0.7f);
        rectangle.selectable = true;
        rectangle.cursor_type = CursorType.NORMAL;

        time_label = new LabelControl();
        add_child(time_label);
        time_label.inner_anchor = Vec2(1, 0);
        time_label.outer_anchor = Vec2(1, 0);
        time_label.position = Vec2(-padding, padding);
        time_label.font_size = 60;
		time_label.visible = false;

        score_label = new LabelControl();
        add_child(score_label);
        score_label.inner_anchor = Vec2(0.5f, 1);
        score_label.outer_anchor = Vec2(0.5f, 1);
        score_label.position = Vec2(0, -padding);
        score_label.font_size = 40;
        score_label.text = "Scores";

        ready_button = new MenuTextButton("MenuButtonSmall", "Ready");
        add_child(ready_button);
        ready_button.clicked.connect(ready_clicked);
        ready_button.inner_anchor = Vec2(0, 0);
        ready_button.outer_anchor = Vec2(0, 0);
        ready_button.position = Vec2(padding, padding);
        ready_button.visible = false;
        ready_button.enabled = false;

        next_score_button = new GameMenuButton("Next");
        add_child(next_score_button);
        next_score_button.clicked.connect(next_score_clicked);
        next_score_button.inner_anchor = Vec2(0, 0.5f);
        next_score_button.outer_anchor = Vec2(0.5f, 1);
        next_score_button.size = Size2(score_label.size.height, score_label.size.height);
        next_score_button.position = Vec2(score_label.size.width / 2 + padding, -(score_label.size.height / 2 + padding));
        next_score_button.enabled = false;

        prev_score_button = new GameMenuButton("Prev");
        add_child(prev_score_button);
        prev_score_button.clicked.connect(prev_score_clicked);
        prev_score_button.inner_anchor = Vec2(1, 0.5f);
        prev_score_button.outer_anchor = Vec2(0.5f, 1);
        prev_score_button.size = Size2(score_label.size.height, score_label.size.height);
        prev_score_button.position = Vec2(-(score_label.size.width / 2 + padding), -(score_label.size.height / 2 + padding));
        prev_score_button.enabled = false;

        visible = false;
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (start_time == 0)
            start_time = delta.time;

        int t = (int)(start_time + time - delta.time);

        if (t < 0)
        {
            display_timer = false;
            time_label.visible = false;
            return;
        }

        string str = t.to_string();

        if (str != time_label.text)
            time_label.text = str;
    }

    protected override void resized()
    {
        if (scoring_view == null)
            return;

        scoring_view.resize_style = ResizeStyle.ABSOLUTE;
        scoring_view.size = Size2(size.width - padding * 2, size.height - padding * 3 - score_label.size.height);
        scoring_view.inner_anchor = Vec2(0, 0);
        scoring_view.outer_anchor = Vec2(0, 0);
        scoring_view.position = Vec2(padding, padding);
    }

    public void update_scores(RoundScoreState[] scores)
    {
        this.scores = scores;
        score_index = scores.length - 1;
    }

    public void display(bool round_finished)
    {
        if (scores == null || scores.length == 0)
            return;

        visible = true;

        if (round_finished)
        {
            busy = true;
            ready_button.visible = true;
        }

        update_score_view(round_finished);

        next_score_button.visible = !round_finished;
        prev_score_button.visible = !round_finished;
    }

    private void update_score_view(bool round_finished)
    {
        check_score_change_buttons();

        var score = scores[score_index];
        if (scoring_view != null)
        {
            if (scoring_view.score == score && !round_finished)
                return;
            remove_child(scoring_view);
        }

        if (round_finished)
        {
            start_time = 0;
            time = delays.get_animation_round_end_delay(score);
            time--; // Count down to 0
        }

        scoring_view = new ScoringInnerView(score, player_index, delays, round_finished);
        scoring_view.animation_finished.connect(animation_finished);
        add_child(scoring_view);
        resized();
    }

    private void check_score_change_buttons()
    {
        prev_score_button.visible = true;
        next_score_button.visible = true;
        prev_score_button.enabled = score_index > 0;
        next_score_button.enabled = score_index < scores.length - 1;
    }

    public void hide()
    {
        if (!busy)
            visible = false;
    }

    private void animation_finished()
    {
        busy = false;
        ready_button.enabled = true;
        time_label.visible = true;
        display_timer = true;
        check_score_change_buttons();
    }

    private void ready_clicked()
    {
        score_finished();
        ready_button.enabled = false;
    }

    private void next_score_clicked()
    {
        if (busy || score_index >= scores.length -1)
            return;

        score_index++;
        update_score_view(false);
    }

    private void prev_score_clicked()
    {
        if (busy || score_index == 0)
            return;

        score_index--;
        update_score_view(false);
    }

    public bool busy { get; private set; }
}
