using Gee;

public class ScoringPointsView : View2D
{
    private Scoring score;
    private ScoringHandView hand;
    private ArrayList<LabelControl> labels = new ArrayList<LabelControl>();

    public ScoringPointsView(Scoring score)
    {
        base();

        this.score = score;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        string score_text;
        if (score.ron)
            score_text = "Ron";
        else
            score_text = "Tsumo";

        LabelControl score_label = new LabelControl(store);
        score_label.text = score_text;
        score_label.inner_anchor = Size2(0.5f, 1);
        score_label.outer_anchor = Size2(0.5f, 1);
        score_label.position = Vec2(0, 0);
        labels.add(score_label);

        hand = new ScoringHandView(score);
        add_child(hand);
        hand.outer_anchor = Vec2(0.5f, 1);
        hand.size = Size2(size.width, 80);
        hand.position = Vec2(0, -score_label.size.height - hand.size.height / 2);

        int han = 0;
        int yakuman = 0;

        int h = 0;
        float start = hand.size.height / 2 - hand.position.y;

        foreach (Yaku yaku in score.yaku)
        {
            LabelControl name = new LabelControl(store);
            name.text = yaku_to_string(yaku);
            name.inner_anchor = Size2(0, 1);
            name.outer_anchor = Size2(0, 1);
            name.position = Vec2(0, -start - h * name.size.height);
            labels.add(name);

            string str;

            if (yaku.yakuman > 0)
                str = yaku.yakuman.to_string() + " yakuman";
            else
                str = yaku.han.to_string() + " han";

            LabelControl num = new LabelControl(store);
            num.text = str;
            num.inner_anchor = Size2(1, 1);
            num.outer_anchor = Size2(1, 1);
            num.position = Vec2(0, -start - h * num.size.height);
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
        points_label.inner_anchor = Size2(0.5f, 0);
        points_label.outer_anchor = Size2(0.5f, 0);
        labels.add(points_label);

        foreach (LabelControl label in labels)
            add_control(label);
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
        hand.size = Size2(size.width, hand.size.height);
        //hand.size = Size2(parent_window.size.width, parent_window.size.height);
    }
}
