using Gee;

public class ScoringPointsView : View2D
{
    private RoundScoreState score;
    private ScoringHandView? hand = null;
    private ArrayList<LabelControl> labels = new ArrayList<LabelControl>();

    public ScoringPointsView(RoundScoreState score)
    {
        base();

        this.score = score;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        bool draw = false;
        string score_text;

        if (score.result.result == RoundFinishResult.RoundResultEnum.RON)
        {
            score_text = "Ron";
            if (score.result.score.dealer)
                score_text = "Dealer " + score_text;
        }
        else if (score.result.result == RoundFinishResult.RoundResultEnum.TSUMO)
        {
            score_text = "Tsumo";
            if (score.result.score.dealer)
                score_text = "Dealer " + score_text;
        }
        else
        {
            score_text = "Draw";
            draw = true;
        }

        Scoring scoring = score.result.score;

        LabelControl score_label = new LabelControl(store);
        score_label.text = score_text;
        score_label.position = Vec2(0, 0);

        if (draw)
        {
            score_label.inner_anchor = Vec2(0.5f, 0.5f);
            score_label.outer_anchor = Vec2(0.5f, 0.5f);
            add_control(score_label);
            return;
        }

        score_label.inner_anchor = Vec2(0.5f, 1);
        score_label.outer_anchor = Vec2(0.5f, 1);
        labels.add(score_label);

        hand = new ScoringHandView(scoring);
        add_child(hand);
        hand.outer_anchor = Vec2(0.5f, 1);
        hand.size = Size2(size.width, 80);
        hand.position = Vec2(0, -score_label.size.height - hand.size.height / 2);

        int han = 0;
        int yakuman = 0;

        foreach (Yaku yaku in scoring.yaku)
        {
            han += yaku.han;
            yakuman += yaku.yakuman;
        }

        int h = 0;
        float start = hand.size.height / 2 - hand.position.y;

        foreach (Yaku yaku in scoring.yaku)
        {
            if (yakuman > 0 && yaku.yakuman == 0)
                continue;

            LabelControl name = new LabelControl(store);
            name.text = yaku_to_string(yaku);
            name.inner_anchor = Vec2(0, 1);
            name.outer_anchor = Vec2(0, 1);
            name.position = Vec2(0, -start - h * name.size.height);
            labels.add(name);

            string str;

            if (yaku.yakuman > 0)
                str = yaku.yakuman.to_string() + " yakuman";
            else
                str = yaku.han.to_string() + " han";

            LabelControl num = new LabelControl(store);
            num.text = str;
            num.inner_anchor = Vec2(1, 1);
            num.outer_anchor = Vec2(1, 1);
            num.position = Vec2(0, -start - h * num.size.height);
            labels.add(num);
            h++;
        }

        string points;

        if (scoring.ron)
            points = scoring.ron_points.to_string();
        else
        {
            if (scoring.dealer)
                points = "3 * " + scoring.tsumo_points_higher.to_string();
            else
                points = scoring.tsumo_points_lower.to_string() + "/" + scoring.tsumo_points_higher.to_string();
        }

        string name = "";

        switch (scoring.score_type)
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
        {
            if (scoring.dealer)
                name = "Dealer " + name;
            name += " - ";
        }

        LabelControl points_label = new LabelControl(store);
        points_label.text = name + points + " points";
        points_label.inner_anchor = Vec2(0.5f, 0);
        points_label.outer_anchor = Vec2(0.5f, 0);
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
        if (hand != null)
            hand.size = Size2(size.width, hand.size.height);
    }
}
