using Gee;

public class ScoringView : View2D
{
    private Scoring score;
    private LabelControl time_label;
    private RectangleControl rectangle;
    private GameMenuButton next_button;
    private ScoringHandView hand;
    private ScoringPointsView view;
    private ScoringPlayerElement bottom;
    private ScoringPlayerElement right;
    private ScoringPlayerElement top;
    private ScoringPlayerElement left;
    private int padding = 10;
    private float time = 15;
    private float start_time = 0;

    public ScoringView(Scoring score)
    {
        this.score = score;
        relative_size = Size2(0.9f, 0.9f);
    }

    public override void added()
    {
        rectangle = new RectangleControl();
        rectangle.resize_style = ResizeStyle.RELATIVE;
        rectangle.color = Color.with_alpha(0.8f);
        add_control(rectangle);

        time_label = new LabelControl(store);
        time_label.inner_anchor = Size2(0, 0);
        time_label.outer_anchor = Size2(0, 0);
        time_label.position = Vec2(padding, padding);
        add_control(time_label);

        next_button = new GameMenuButton(store, "Next");
        next_button.selectable = true;
        next_button.inner_anchor = Size2(1, 0);
        next_button.outer_anchor = Size2(1, 0);
        next_button.position = Vec2(-padding, padding);
        add_control(next_button);

        bottom = new ScoringPlayerElement(Wind.SOUTH, "Fluffy", 180000, 32000);
        bottom.resize_style = ResizeStyle.ABSOLUTE;
        bottom.inner_anchor = Vec2(0.5f, 0);
        bottom.outer_anchor = Vec2(0.5f, 0);
        bottom.position = Vec2(0, padding);
        add_child(bottom);

        right = new ScoringPlayerElement(Wind.WEST, "NullBot1", 100, -300);
        right.resize_style = ResizeStyle.ABSOLUTE;
        right.inner_anchor = Vec2(1, 0.5f);
        right.outer_anchor = Vec2(1, 0.5f);
        right.position = Vec2(-padding, 0);
        add_child(right);

        top = new ScoringPlayerElement(Wind.NORTH, "NullBot2", 25000, 0);
        top.resize_style = ResizeStyle.ABSOLUTE;
        top.inner_anchor = Vec2(0.5f, 1);
        top.outer_anchor = Vec2(0.5f, 1);
        top.position = Vec2(0, -padding);
        add_child(top);

        left = new ScoringPlayerElement(Wind.EAST, "NullBot3", 25000, -32000);
        left.resize_style = ResizeStyle.ABSOLUTE;
        left.inner_anchor = Vec2(0, 0.5f);
        left.outer_anchor = Vec2(0, 0.5f);
        left.position = Vec2(padding, 0);
        add_child(left);

        view = new ScoringPointsView(score);
        add_child(view);
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
