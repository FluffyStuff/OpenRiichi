using Gee;

public class ScoringView : View2D
{
    private Scoring score;
    private ArrayList<LabelControl> labels = new ArrayList<LabelControl>();
    private LabelControl time_label;
    private RectangleControl rectangle;
    private GameMenuButton next_button;
    private float time = 15;
    private float start_time = 0;

    public ScoringView(Scoring score)
    {
        this.score = score;
    }

    public override void added()
    {
        rectangle = new RectangleControl();
        rectangle.resize_style = ResizeStyle.RELATIVE;
        rectangle.relative_scale = Size2(0.9f, 0.9f);
        rectangle.diffuse_color = Color.with_alpha(0.8f);
        add_control(rectangle);

        string score_text;
        if (score.ron)
            score_text = "Ron";
        else
            score_text = "Tsumo";

        LabelControl score_label = new LabelControl(store);
        score_label.text = score_text;
        score_label.inner_anchor = Size2(0.5f, 1);
        score_label.outer_anchor = Size2(0.5f, rectangle.relative_scale.height);
        score_label.position = Vec2(0, 0);
        labels.add(score_label);

        int han = 0;
        int yakuman = 0;

        int h = 2;

        foreach (Yaku yaku in score.yaku)
        {
            LabelControl name = new LabelControl(store);
            name.text = yaku_to_string(yaku);
            name.inner_anchor = Size2(0, 1);
            name.outer_anchor = Size2(1 - rectangle.relative_scale.width, rectangle.relative_scale.height);
            name.position = Vec2(0, -h * name.size.height);
            labels.add(name);

            string str;

            if (yaku.yakuman > 0)
                str = yaku.yakuman.to_string() + " yakuman";
            else
                str = yaku.han.to_string() + " han";

            LabelControl num = new LabelControl(store);
            num.text = str;
            num.inner_anchor = Size2(1, 1);
            num.outer_anchor = Size2(rectangle.relative_scale.width, rectangle.relative_scale.height);
            num.position = Vec2(0, -h * num.size.height);
            labels.add(num);

            han += yaku.han;
            yakuman += yaku.yakuman;
            h++;
        }

        string points;

        if (score.ron)
            points = score.ron_points.to_string();
        else
        {
            if (score.dealer)
                points = score.tsumo_points_higher.to_string();
            else
                points = score.tsumo_points_lower.to_string() + "/" + score.tsumo_points_higher.to_string();
        }

        string name = "";

        switch (score.score_type)
        {
        case Scoring.ScoreType.MANGAN:
            name = "Mangan";
            break;
        case Scoring.ScoreType.HANEMAN:
            name = "Haneman";
            break;
        case Scoring.ScoreType.BAIMAN:
            name = "Baiman";
            break;
        case Scoring.ScoreType.SANBAIMAN:
            name = "Sanbaiman";
            break;
        case Scoring.ScoreType.KAZOE_YAKUMAN:
            name = "Kazoe Yakuman";
            break;
        case Scoring.ScoreType.YAKUMAN:
            name = "Yakuman";
            break;
        case Scoring.ScoreType.NAGASHI_MANGAN:
            name = "Nagashi Mangan";
            break;
        case Scoring.ScoreType.NORMAL:
        default:
            name = "";
            break;
        }

        if (name != "")
            name += " - ";


        LabelControl points_label = new LabelControl(store);
        points_label.text = name + points + " points";
        points_label.inner_anchor = Size2(0.5f, 1);
        points_label.outer_anchor = Size2(0.5f, rectangle.relative_scale.height);
        points_label.position = Vec2(0, -(h + 3) * points_label.size.height);
        labels.add(points_label);

        foreach (LabelControl label in labels)
            add_control(label);

        time_label = new LabelControl(store);
        time_label.text = "";
        time_label.font_size = 30 / 1.6f;
        time_label.font_type = "Sans Bold";
        time_label.inner_anchor = Size2(0, 0);
        time_label.outer_anchor = Size2(1 - rectangle.relative_scale.width, 1 - rectangle.relative_scale.height);
        add_control(time_label);

        next_button = new GameMenuButton(store, "Next");
        next_button.selectable = true;
        next_button.inner_anchor = Size2(1, 0);
        next_button.outer_anchor = Size2(rectangle.relative_scale.width, 1 - rectangle.relative_scale.height);
        //add_control(next_button);
    }

    private string yaku_to_string(Yaku yaku)
    {
        string str = "";

        string[] parts = yaku.yaku_type.to_string().substring(10).down().split("_");

        for (int i = 0; i < parts.length; i++)
        {
            string part = parts[i];

            if (i != 0)
                str += " ";
            str += part[0].toupper().to_string() + part.substring(1);
        }

        return str;
    }

    public override void do_process(DeltaArgs delta)
    {
        if (start_time == 0)
            start_time = delta.time;

        int t = (int)(start_time + time - delta.time);
        string str = t.to_string();

        if (str != time_label.text)
            time_label.text = str;
    }
}
