using Gee;

public class ScoringView : View
{
    private Scoring score;
    private ArrayList<RenderLabel2D> labels = new ArrayList<RenderLabel2D>();
    private RenderRectangle2D rectangle;

    public ScoringView(Scoring score)
    {
        this.score = score;
    }

    public override void added()
    {
        string score_text;
        if (score.ron)
            score_text = "Ron";
        else
            score_text = "Tsumo";

        labels.add(create_label(score_text));

        int han = 0;
        int yakuman = 0;
        foreach (Yaku yaku in score.yaku)
        {
            labels.add(create_label(yaku_to_string(yaku)));
            han += yaku.han;
            yakuman += yaku.yakuman;
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
            name += " ";

        labels.add(create_label("\n\n" + name + points + " points"));

        rectangle = new RenderRectangle2D();
        rectangle.alpha = 0.7f;
        rectangle.scale = { 0.3f, 0.4f };
        rectangle.diffuse_color = { 0, 0, 0 };
    }

    private RenderLabel2D create_label(string text)
    {
        RenderLabel2D label = store.create_label();
        label.text = text;
        label.font_size = 30 / 1.6f;
        label.font_type = "Sans Bold";
        store.update_label_info(label);
        //label.diffuse_color = { -1.0f, -1.0f, -1.0f };

        return label;
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

        str += ": ";

        if (yaku.yakuman > 0)
            str += yaku.yakuman.to_string() + " yakuman";
        else
            str += yaku.han.to_string() + " han";

        return str;
    }

    public override void do_render(RenderState state)
    {
        position_labels(state);

        RenderScene2D scene = new RenderScene2D(state.screen_width, state.screen_height);

        scene.add_object(rectangle);
        foreach (RenderLabel2D label in labels)
            scene.add_object(label);

        state.add_scene(scene);
    }

    private void position_labels(RenderState state)
    {
        float y = rectangle.scale.y;

        foreach (RenderLabel2D label in labels)
        {
            float scale = 1;
            float width = (float)label.info.width / state.screen_width;
            float height = (float)label.info.height / state.screen_height;

            label.scale = { width * scale, height * scale };

            label.position = { 0, y - label.scale.y };

            y -= label.scale.y * 2;
        }
    }
}
