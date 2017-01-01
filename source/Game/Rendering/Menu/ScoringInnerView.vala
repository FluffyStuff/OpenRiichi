using Gee;

class ScoringInnerView : View2D
{
    private int player_index;
    private AnimationTimings delays;
    private bool animate;
    private ScoringPointsView? view = null;
    private ScoringPlayerElement bottom;
    private ScoringPlayerElement right;
    private ScoringPlayerElement top;
    private ScoringPlayerElement left;
    private ScoringStickNumberView riichi_view;
    private ScoringStickNumberView renchan_view;
    private LabelControl wind_indicator;
    private LabelControl round_indicator;
    private int padding = 10;
    private EventTimer timer;
    private bool items_animation;
    private DeltaTimer items_timer = new DeltaTimer();

    public signal void animation_finished();

    public ScoringInnerView(RoundScoreState score, int player_index, AnimationTimings delays, bool animate)
    {
        this.score = score;
        this.player_index = player_index;
        this.delays = delays;
        this.animate = animate;
    }

    public override void added()
    {
        var player = score.players[player_index];
        bottom = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score, delays, animate);
        add_child(bottom);
        bottom.resize_style = ResizeStyle.ABSOLUTE;
        bottom.inner_anchor = Vec2(0.5f, 0);
        bottom.outer_anchor = Vec2(0.5f, 0);
        bottom.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 1) % 4];
        right = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score, delays, animate);
        add_child(right);
        right.resize_style = ResizeStyle.ABSOLUTE;
        right.inner_anchor = Vec2(1, 0.5f);
        right.outer_anchor = Vec2(1, 0.5f);
        right.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 2) % 4];
        top = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score, delays, animate);
        add_child(top);
        top.resize_style = ResizeStyle.ABSOLUTE;
        top.inner_anchor = Vec2(0.5f, 1);
        top.outer_anchor = Vec2(0.5f, 1);
        top.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 3) % 4];
        left = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score, delays, animate);
        add_child(left);
        left.resize_style = ResizeStyle.ABSOLUTE;
        left.inner_anchor = Vec2(0, 0.5f);
        left.outer_anchor = Vec2(0, 0.5f);
        left.show_score = score.hanchan_is_finished;

        riichi_view = new ScoringStickNumberView("1000", true);
        add_child(riichi_view);
        riichi_view.size = Size2(200, 20);
        riichi_view.inner_anchor = Vec2(0, 0);
        riichi_view.outer_anchor = Vec2(0, 0);
        riichi_view.position = Vec2(left.size.width + left.position.x, bottom.size.height + bottom.position.y);
        riichi_view.number = score.riichi_count;
        riichi_view.alpha = animate ? 0 : 1;

        renchan_view = new ScoringStickNumberView("100", false);
        add_child(renchan_view);
        renchan_view.size = riichi_view.size;
        renchan_view.inner_anchor = Vec2(1, 0);
        renchan_view.outer_anchor = Vec2(1, 0);
        renchan_view.position = Vec2(-right.size.width + right.position.x, bottom.size.height + bottom.position.y);
        renchan_view.number = score.renchan;
        renchan_view.alpha = animate ? 0 : 1;

        wind_indicator = new LabelControl();
        add_child(wind_indicator);
        wind_indicator.text = WIND_TO_STRING(score.round_wind);
        wind_indicator.inner_anchor = Vec2(0, 1);
        wind_indicator.outer_anchor = Vec2(0, 1);
        wind_indicator.font_size = 60;
        wind_indicator.alpha = animate ? 0 : 1;

        round_indicator = new LabelControl();
        add_child(round_indicator);
        round_indicator.text = (score.current_round % 4 + 1).to_string();
        round_indicator.inner_anchor = Vec2(0, 1);
        round_indicator.outer_anchor = Vec2(0, 1);
        round_indicator.position = Vec2(wind_indicator.size.width, 0);
        round_indicator.font_size = wind_indicator.font_size;
        round_indicator.alpha = animate ? 0 : 1;

        if (score.round_is_finished)
        {
            view = new ScoringPointsView(score, delays, animate);
            view.score_selected.connect(score_selected);
            view.label_animation_finished.connect(label_animation_finished);
            view.score_animation_finished.connect(score_animation_finished);
            add_child(view);
        }
    }

    protected override void do_process(DeltaArgs args)
    {
        if (!animate)
            return;

        if (items_animation)
        {
            float time = items_timer.elapsed(args) / delays.menu_items_fade_time;

            if (time >= 1)
            {
                items_animation = false;
                time = 1;
            }

            riichi_view.alpha = time;
            renchan_view.alpha = time;
            wind_indicator.alpha = time;
            round_indicator.alpha = time;
        }

        if (timer != null)
            timer.process(args);
    }

    private void label_animation_finished()
    {
        items_animation = true;
    }

    private void score_animation_finished()
    {
        timer = new EventTimer(delays.players_score_counting_delay, true);
        timer.elapsed.connect(counting_delay_elapsed);
    }

    private void counting_delay_elapsed()
    {
        bottom.animate();
        right.animate();
        top.animate();
        left.animate();

        timer = new EventTimer(delays.players_score_counting_time, true);
        timer.elapsed.connect(counting_time_elapsed);
    }

    private void counting_time_elapsed()
    {
        animation_finished();
        view.animation_finished();
    }

    protected override void resized()
    {
        if (view != null)
        {
            view.size = Size2(right.rect.x - (left.rect.x + left.size.width) - padding * 2, top.rect.y - (bottom.rect.y + bottom.rect.height) - riichi_view.size.height - padding * 2);
            view.position = Vec2(0, riichi_view.size.height / 2);
        }

        /*if (riichi_view != null)
            riichi_view.size = Size2((right.rect.x - (left.rect.x + left.size.width)) / 2, riichi_view.size.height);
        if (renchan_view != null)
            renchan_view.size = Size2((right.rect.x - (left.rect.x + left.size.width)) / 2, renchan_view.size.height);*/
    }

    private void score_selected(int player_index)
    {
        bottom.highlighted = player_index == bottom.player_index;
        right.highlighted = player_index == right.player_index;
        top.highlighted = player_index == top.player_index;
        left.highlighted = player_index == left.player_index;
    }

    public RoundScoreState score { get; private set; }
}
