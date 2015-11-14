using Gee;

public class ScoringView : View2D
{
    private RoundScoreState score;
    private int player_index;
    private LabelControl time_label;
    private RectangleControl rectangle;
    private GameMenuButton next_button;
    private ScoringPointsView view;
    private ScoringPlayerElement bottom;
    private ScoringPlayerElement right;
    private ScoringPlayerElement top;
    private ScoringPlayerElement left;
    private int padding = 10;
    private float time;
    private float start_time = 0;

    public ScoringView(RoundScoreState score, int player_index, int round_time, int hanchan_time, int game_time)
    {
        this.score = score;
        this.player_index = player_index;
        relative_size = Size2(0.9f, 0.9f);

        if (score.game_is_finished)
            time = game_time;
        else if (score.hanchan_is_finished)
            time = hanchan_time;
        else
            time = round_time;
    }

    public override void added()
    {
        rectangle = new RectangleControl();
        rectangle.resize_style = ResizeStyle.RELATIVE;
        rectangle.color = Color.with_alpha(0.8f);
        add_control(rectangle);

        time_label = new LabelControl(store);
        time_label.inner_anchor = Vec2(0, 0);
        time_label.outer_anchor = Vec2(0, 0);
        time_label.position = Vec2(padding, padding);
        add_control(time_label);

        next_button = new GameMenuButton(store, "Next");
        next_button.selectable = true;
        next_button.inner_anchor = Vec2(1, 0);
        next_button.outer_anchor = Vec2(1, 0);
        next_button.position = Vec2(-padding, padding);
        add_control(next_button);

        var player = score.players[player_index];
        bottom = new ScoringPlayerElement(player.wind, player.name, player.points, player.transfer, player.score);
        bottom.resize_style = ResizeStyle.ABSOLUTE;
        bottom.inner_anchor = Vec2(0.5f, 0);
        bottom.outer_anchor = Vec2(0.5f, 0);
        bottom.position = Vec2(0, padding);
        add_child(bottom);
        bottom.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 1) % 4];
        right = new ScoringPlayerElement(player.wind, player.name, player.points, player.transfer, player.score);
        right.resize_style = ResizeStyle.ABSOLUTE;
        right.inner_anchor = Vec2(1, 0.5f);
        right.outer_anchor = Vec2(1, 0.5f);
        right.position = Vec2(-padding, 0);
        add_child(right);
        right.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 2) % 4];
        top = new ScoringPlayerElement(player.wind, player.name, player.points, player.transfer, player.score);
        top.resize_style = ResizeStyle.ABSOLUTE;
        top.inner_anchor = Vec2(0.5f, 1);
        top.outer_anchor = Vec2(0.5f, 1);
        top.position = Vec2(0, -padding);
        add_child(top);
        top.show_score = score.hanchan_is_finished;

        player = score.players[(player_index + 3) % 4];
        left = new ScoringPlayerElement(player.wind, player.name, player.points, player.transfer, player.score);
        left.resize_style = ResizeStyle.ABSOLUTE;
        left.inner_anchor = Vec2(0, 0.5f);
        left.outer_anchor = Vec2(0, 0.5f);
        left.position = Vec2(padding, 0);
        add_child(left);

        view = new ScoringPointsView(score);
        add_child(view);
        left.show_score = score.hanchan_is_finished;
    }

    public override void do_process(DeltaArgs delta)
    {
        if (start_time == 0)
            start_time = delta.time;

        int t = int.max((int)(start_time + time - delta.time), 0);
        string str = t.to_string();

        if (str != time_label.text)
            time_label.text = str;

        view.size = Size2(right.rect.x - (left.rect.x + left.size.width) - padding * 2, top.rect.y - (bottom.rect.y + bottom.rect.height) - padding * 2);
    }
}
