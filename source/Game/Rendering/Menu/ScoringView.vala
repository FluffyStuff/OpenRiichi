using Gee;

public class ScoringView : View2D
{
    private int player_index;
    private LabelControl time_label;
    private RectangleControl rectangle;
    //private GameMenuButton next_button;
    private ScoringPointsView? view = null;
    private ScoringPlayerElement bottom;
    private ScoringPlayerElement right;
    private ScoringPlayerElement top;
    private ScoringPlayerElement left;
    private ScoringStickNumberView riichi_view;
    private ScoringStickNumberView renchan_view;
    private int padding = 10;
    private bool display_timer;
    private float time;
    private float start_time = 0;

    public signal void timer_expired();

    public ScoringView(RoundScoreState score, int player_index, bool timer, int round_time, int hanchan_time, int game_time, bool force_game_time)
    {
        this.score = score;
        display_timer = timer;
        this.player_index = player_index;
        relative_size = Size2(0.9f, 0.9f);

        if (score.game_is_finished || force_game_time)
            time = game_time;
        else if (score.hanchan_is_finished)
            time = hanchan_time;
        else
            time = round_time;
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

        if (display_timer)
        {
            time_label = new LabelControl();
            add_child(time_label);
            time_label.inner_anchor = Vec2(1, 0);
            time_label.outer_anchor = Vec2(1, 0);
            time_label.position = Vec2(-padding, padding);
            time_label.font_size = 60;
        }

        /*next_button = new GameMenuButton("Next");
        next_button.selectable = true;
        next_button.inner_anchor = Vec2(1, 0);
        next_button.outer_anchor = Vec2(1, 0);
        next_button.position = Vec2(-padding, padding);
        add_control(next_button);*/

        var player = score.players[player_index];
        bottom = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score);
        add_child(bottom);
        bottom.resize_style = ResizeStyle.ABSOLUTE;
        bottom.inner_anchor = Vec2(0.5f, 0);
        bottom.outer_anchor = Vec2(0.5f, 0);
        bottom.position = Vec2(0, padding);
        bottom.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 1) % 4];
        right = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score);
        add_child(right);
        right.resize_style = ResizeStyle.ABSOLUTE;
        right.inner_anchor = Vec2(1, 0.5f);
        right.outer_anchor = Vec2(1, 0.5f);
        right.position = Vec2(-padding, 0);
        right.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 2) % 4];
        top = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score);
        add_child(top);
        top.resize_style = ResizeStyle.ABSOLUTE;
        top.inner_anchor = Vec2(0.5f, 1);
        top.outer_anchor = Vec2(0.5f, 1);
        top.position = Vec2(0, -padding);
        top.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 3) % 4];
        left = new ScoringPlayerElement(player.index, player.wind, player.name, player.points, player.transfer, player.score);
        add_child(left);
        left.resize_style = ResizeStyle.ABSOLUTE;
        left.inner_anchor = Vec2(0, 0.5f);
        left.outer_anchor = Vec2(0, 0.5f);
        left.position = Vec2(padding, 0);
        left.show_score = score.hanchan_is_finished;

        riichi_view = new ScoringStickNumberView("1000", true);
        add_child(riichi_view);
        riichi_view.size = Size2(200, 20);
        riichi_view.inner_anchor = Vec2(0, 0);
        riichi_view.outer_anchor = Vec2(0, 0);
        riichi_view.position = Vec2(left.size.width + left.position.x, bottom.size.height + bottom.position.y);
        riichi_view.number = score.riichi_count;

        renchan_view = new ScoringStickNumberView("100", false);
        add_child(renchan_view);
        renchan_view.size = riichi_view.size;
        renchan_view.inner_anchor = Vec2(1, 0);
        renchan_view.outer_anchor = Vec2(1, 0);
        renchan_view.position = Vec2(-right.size.width + right.position.x, bottom.size.height + bottom.position.y);
        renchan_view.number = score.renchan;

        if (score.round_is_finished)
        {
            view = new ScoringPointsView(score, time);
            view.score_selected.connect(score_selected);
            add_child(view);
        }
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (!display_timer)
            return;

        if (start_time == 0)
            start_time = delta.time;

        int t = (int)(start_time + time - delta.time);

        if (t < 0)
        {
            display_timer = false;
            time_label.visible = false;
            timer_expired();
            return;
        }

        string str = t.to_string();

        if (str != time_label.text)
            time_label.text = str;
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
