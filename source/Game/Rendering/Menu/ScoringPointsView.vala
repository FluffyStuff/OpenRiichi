using Gee;

public class ScoringPointsView : View2D
{
    private RoundScoreState score;
    private LabelControl score_label;
    private GameMenuButton next_button;
    private GameMenuButton prev_button;
    private ScoringScoreControl? scoring_control = null;
    private ScoringDoraView? dora;
    private ScoringDoraView? ura;
    private int score_index = 0;

    private int padding = 20;
    private int switches;
    private float delay;
    private float total_time;
    private DelayTimer timer;

    public signal void score_selected(int player_index);

    public ScoringPointsView(RoundScoreState score, float total_time)
    {
        this.score = score;
        this.total_time = total_time;
    }

    public override void added()
    {
        resize_style = ResizeStyle.ABSOLUTE;

        if (!score.round_is_finished)
            return;

        bool draw = false;
        string score_text;

        int sekinin_index = -1;
        if (score.result.scores.length > 0)
            score.result.scores[0].player.sekinin_index;

        bool sekinin = !draw && sekinin_index != -1;

        if (score.result.result == RoundFinishResult.RoundResultEnum.RON)
        {
            score_text = "Ron";

            if (score.result.scores.length != 1)
                score_text = "Multiple " + score_text;
            else if (score.result.scores[0].dealer)
                score_text = "Dealer " + score_text;

            sekinin = false;
            foreach (Scoring s in score.result.scores)
                if (s.player.sekinin_index != -1 && s.player.sekinin_index != score.result.loser_index)
                    sekinin = true;
        }
        else if (score.result.result == RoundFinishResult.RoundResultEnum.TSUMO)
        {
            score_text = "Tsumo";
            if (score.result.scores[0].dealer)
                score_text = "Dealer " + score_text;
        }
        else
        {
            score_text = "Draw";
            draw = true;
        }

        if (sekinin)
            score_text += " (Sekinin Barai)";

        score_label = new LabelControl();
        add_child(score_label);
        score_label.text = score_text;

        if (draw)
        {
            score_label.inner_anchor = Vec2(0.5f, 0.5f);
            score_label.outer_anchor = Vec2(0.5f, 0.5f);

            if (score.result.draw_type != GameDrawType.EMPTY_WALL || score.result.nagashi_indices.length != 0)
            {
                score_label.inner_anchor = Vec2(0.5f, 0);

                LabelControl draw_label = new LabelControl();
                add_child(draw_label);
                draw_label.inner_anchor = Vec2(0.5f, 1);
                draw_label.outer_anchor = Vec2(0.5f, 0.5f);

                string text;

                if (score.result.draw_type == GameDrawType.EMPTY_WALL && score.result.nagashi_indices.length != 0)
                    text = "Nagashi Mangan";
                else if (score.result.draw_type == GameDrawType.FOUR_WINDS)
                    text = "Four Winds";
                else if (score.result.draw_type == GameDrawType.FOUR_KANS)
                    text = "Four Kans";
                else if (score.result.draw_type == GameDrawType.FOUR_RIICHI)
                    text = "Four Riichi";
                else if (score.result.draw_type == GameDrawType.VOID_HAND)
                    text = "Void Hand";
                else if (score.result.draw_type == GameDrawType.TRIPLE_RON)
                    text = "Triple Ron";
                else
                    text = "";

                draw_label.text = text;
            }

            return;
        }

        var s = score.result.scores[0];
        var d = s.round.dora;
        var u = s.round.ura_dora;
        dora = new ScoringDoraView(d, 2 - d.size / 2, 4 - d.size / 2);
        ura = new ScoringDoraView(u, 2 - (u.size - 1) / 2, 4 - (u.size - 1) / 2);
        add_child(dora);
        add_child(ura);

        dora.visible = s.dora;
        ura.visible = s.dora; // Optional s.ura_dora?
        dora.inner_anchor = Vec2(ura.visible ? 0 : 0.5f, 0);
        dora.outer_anchor = Vec2(ura.visible ? 0 : 0.5f, 0);
        ura.inner_anchor = Vec2(1, 0);
        ura.outer_anchor = Vec2(1, 0);

        dora.size = Size2(1, 60);
        ura.size = dora.size;

        score_label.inner_anchor = Vec2(0.5f, 1);
        score_label.outer_anchor = Vec2(0.5f, 1);

        show_score_control();

        if (score.result.scores.length > 1)
        {
            switches = score.result.scores.length - 1;
            delay = total_time / (switches + 1);
            timer = new DelayTimer();
            timer.set_time(delay);

            prev_button = new GameMenuButton("Prev");
            next_button = new GameMenuButton("Next");
            add_child(prev_button);
            add_child(next_button);

            float scale = score_label.size.height / prev_button.size.height;

            prev_button.size = Size2(prev_button.size.width * scale, prev_button.size.height * scale);
            next_button.size = Size2(next_button.size.width * scale, next_button.size.height * scale);
            prev_button.inner_anchor = Vec2(1, 0.5f);
            next_button.inner_anchor = Vec2(0, 0.5f);
            prev_button.outer_anchor = Vec2(0.5f, 1);
            next_button.outer_anchor = Vec2(0.5f, 1);
            prev_button.position = Vec2(-score_label.size.width / 2 - prev_button.size.height / 2, -score_label.size.height / 2);
            next_button.position = Vec2( score_label.size.width / 2 + next_button.size.height / 2, -score_label.size.height / 2);
            prev_button.clicked.connect(prev_score);
            next_button.clicked.connect(next_score);
        }
    }

    protected override void do_process(DeltaArgs args)
    {
        if (switches <= 0)
            return;

        if (timer.active(args.time))
        {
            score_index = (score_index + 1) % score.result.scores.length;
            show_score_control();

            timer.set_time(delay);
            switches--;
        }
    }

    private void show_score_control()
    {
        if (scoring_control != null)
            remove_child(scoring_control);

        Scoring scoring = score.result.scores[score_index];
        int sekinin_index = scoring.player.sekinin_index;
        bool sekinin = sekinin_index != -1;
        bool dual_payer = false;

        if (score.result.result == RoundFinishResult.RoundResultEnum.RON)
            dual_payer = sekinin = sekinin && sekinin_index != score.result.loser_index;

        scoring_control = new ScoringScoreControl(scoring, sekinin, dual_payer);
        add_child(scoring_control);
        scoring_control.resize_style = ResizeStyle.ABSOLUTE;
        scoring_control.inner_anchor = Vec2(0.5f, 0);
        scoring_control.outer_anchor = Vec2(0.5f, 0);
        scoring_control.position = Vec2(0, dora.size.height);

        score_selected(score.result.winner_indices[score_index]);
        resized();
    }

    private void prev_score()
    {
        score_index = (score_index + 1) % score.result.scores.length;
        show_score_control();
        switches = 0;
    }

    private void next_score()
    {
        score_index = (score_index - 1 + score.result.scores.length) % score.result.scores.length;
        show_score_control();
        switches = 0;
    }

    protected override void resized()
    {
        if (dora != null)
            dora.size = Size2(ura.visible ? (size.width - padding) / 2 : size.width, dora.size.height);
        if (ura != null)
            ura.size  = Size2((size.width - padding) / 2,  ura.size.height);

        if (scoring_control != null)
            scoring_control.size = Size2(size.width, size.height - score_label.size.height - dora.size.height);
    }

    private class ScoringScoreControl : Control
    {
        private ScoringHandView? hand = null;
        private Scoring scoring;
        private bool sekinin;
        private bool dual_payer;

        public ScoringScoreControl(Scoring scoring, bool sekinin, bool dual_payer)
        {
            this.scoring = scoring;
            this.sekinin = sekinin;
            this.dual_payer = dual_payer;
        }

        public override void added()
        {
            hand = new ScoringHandView(scoring);
            add_child(hand);
            hand.outer_anchor = Vec2(0.5f, 1);
            hand.size = Size2(size.width, 120);
            hand.position = Vec2(0, -hand.size.height / 2);

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

                LabelControl name = new LabelControl();
                add_child(name);
                name.text = yaku_to_string(yaku);
                name.inner_anchor = Vec2(0, 1);
                name.outer_anchor = Vec2(0, 1);
                name.position = Vec2(0, -start - h * name.size.height);

                string str;

                if (yaku.yakuman > 0)
                {
                    str = "Yakuman";

                    if (yaku.yakuman == 2)
                        str = "Double " + str;
                    else if (yaku.yakuman > 2)
                        str = yaku.yakuman.to_string() + " " + str;
                }
                else
                    str = yaku.han.to_string() + " han";

                LabelControl num = new LabelControl();
                add_child(num);
                num.text = str;
                num.inner_anchor = Vec2(1, 1);
                num.outer_anchor = Vec2(1, 1);
                num.position = Vec2(0, -start - h * num.size.height);
                h++;
            }

            string points;

            if (scoring.ron)
            {
                if (dual_payer)
                    points = "2 * " + (scoring.ron_points / 2).to_string();
                else
                    points = scoring.ron_points.to_string();
            }
            else
            {
                if (sekinin)
                    points = scoring.total_points.to_string();
                else if (scoring.dealer)
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

            LabelControl points_label = new LabelControl();
            add_child(points_label);
            points_label.text = name + points + " points";
            points_label.inner_anchor = Vec2(0.5f, 0);
            points_label.outer_anchor = Vec2(0.5f, 0);
        }

        public override void resized()
        {
            if (hand != null)
                hand.size = Size2(size.width, hand.size.height);
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
    }
}
