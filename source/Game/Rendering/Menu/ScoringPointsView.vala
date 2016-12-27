using Gee;

class ScoringPointsView : View2D
{
    private RoundScoreState score;
    private AnimationTimings delays;
    private LabelControl score_label;
    private LabelControl? draw_label;
    private GameMenuButton next_button;
    private GameMenuButton prev_button;
    private ScoringScoreControl? scoring_control = null;
    private ScoringDoraView? dora;
    private ScoringDoraView? ura;
    private int score_index = 0;

    private bool animate;
    private int padding = 20;
    private int switches;
    private float delay;
    private float total_time;
    private DelayTimer timer;
    private EventTimer animation_timer;
    private DeltaTimer fade_timer = new DeltaTimer();
    private bool fade_label_animation;
    private bool item_animation;

    public signal void label_animation_finished();
    public signal void score_animation_finished();
    public signal void score_selected(int player_index);

    public ScoringPointsView(RoundScoreState score, AnimationTimings delays, bool animate)
    {
        this.score = score;
        this.delays = delays;
        this.animate = animate;

        if (animate)
            total_time = delays.get_animation_round_end_delay(score);
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
        score_label.alpha = animate ? 0 : 1;
        score_label.font_size = 40;

        animation_timer = new EventTimer(delays.finish_label_delay, animate);
        animation_timer.elapsed.connect(finish_label_delay_elapsed);

        if (draw)
        {
            score_label.inner_anchor = Vec2(0.5f, 0.5f);
            score_label.outer_anchor = Vec2(0.5f, 0.5f);

            if (score.result.draw_type != GameDrawType.EMPTY_WALL || score.result.nagashi_indices.length != 0)
            {
                score_label.inner_anchor = Vec2(0.5f, 0);

                draw_label = new LabelControl();
                add_child(draw_label);
                draw_label.inner_anchor = Vec2(0.5f, 1);
                draw_label.outer_anchor = Vec2(0.5f, 0.5f);
                draw_label.font_size = score_label.font_size;

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
                draw_label.alpha = animate ? 0 : 1;
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

        dora.alpha = animate ? 0 : 1;
        ura.alpha = animate ? 0 : 1;

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
        animation_timer.process(args);

        if (fade_label_animation)
        {
            float time = fade_timer.elapsed(args) / delays.finish_label_fade_time;

            if (time >= 1)
            {
                fade_timer.reset();
                fade_label_animation = false;
                item_animation = true;
                label_animation_finished();
                if (scoring_control != null)
                    scoring_control.animate();

                time = 1;
            }

            score_label.alpha = time;
            if (draw_label != null)
                draw_label.alpha = time;
        }

        if (item_animation)
        {
            float time = fade_timer.elapsed(args) / delays.menu_items_fade_time;

            if (time >= 1)
            {
                if (scoring_control == null)
                    score_animation_finished();

                item_animation = false;
                time = 1;
            }

            if (dora != null)
                dora.alpha = time;
            if (ura != null)
                ura.alpha = time;
        }

        if (switches <= 0 || delay <= 0)
            return;

        if (timer.active(args.time))
        {
            score_index = (score_index + 1) % score.result.scores.length;
            show_score_control();

            timer.set_time(delay);
            switches--;
        }
    }

    private void finish_label_delay_elapsed()
    {
        fade_label_animation = true;
    }

    private void scoring_control_animation_finished()
    {
        score_animation_finished();
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

        scoring_control = new ScoringScoreControl(scoring, sekinin, dual_payer, delays, animate);
        add_child(scoring_control);
        scoring_control.resize_style = ResizeStyle.ABSOLUTE;
        scoring_control.inner_anchor = Vec2(0.5f, 0);
        scoring_control.outer_anchor = Vec2(0.5f, 0);
        scoring_control.position = Vec2(0, dora.size.height);
        scoring_control.animation_finished.connect(scoring_control_animation_finished);

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
        private ScoringHandView? hand;
        private Scoring scoring;
        private bool sekinin;
        private bool dual_payer;
        private AnimationTimings timings;
        private bool _animate;

        private bool animate_items;
        private int han_animation_index;
        private bool animate_han;
        private bool fade_score;
        private bool animate_score;
        private LabelControl points_label;
        private EventTimer? event_timer;
        private DeltaTimer timer = new DeltaTimer();
        private ArrayList<YakuLine> lines = new ArrayList<YakuLine>();

        public signal void animation_finished();

        public ScoringScoreControl(Scoring scoring, bool sekinin, bool dual_payer, AnimationTimings timings, bool animate)
        {
            this.scoring = scoring;
            this.sekinin = sekinin;
            this.dual_payer = dual_payer;
            this.timings = timings;
            _animate = animate;
        }

        public override void added()
        {
            hand = new ScoringHandView(scoring);
            add_child(hand);
            hand.outer_anchor = Vec2(0.5f, 1);
            hand.size = Size2(size.width, 120);
            hand.position = Vec2(0, -hand.size.height / 2);
            hand.alpha = _animate ? 0 : 1;

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
                name.alpha = _animate ? 0 : 1;

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
                num.alpha = _animate ? 0 : 1;
                h++;

                lines.add(new YakuLine(name, num));
            }

            points_label = new LabelControl();
            add_child(points_label);
            points_label.font_size = 40;
            points_label.inner_anchor = Vec2(0.5f, 0);
            points_label.outer_anchor = Vec2(0.5f, 0);
            points_label.alpha = _animate ? 0 : 1;
            set_points_text(_animate ? 0 : 1);
        }

        protected override void do_process(DeltaArgs args)
        {
            if (event_timer != null)
                event_timer.process(args);

            if (animate_items)
            {
                float time = timer.elapsed(args) / timings.menu_items_fade_time;

                if (time >= 1)
                {
                    timer.reset();
                    animate_items = false;
                    event_timer = new EventTimer(timings.han_counting_delay, true);
                    event_timer.elapsed.connect(han_counting_delay_elapsed);
                    time = 1;
                }

                hand.alpha = time;
            }

            if (animate_han)
            {
                float time = (timer.elapsed(args) - timings.han_fade_delay) / timings.han_fade_time;
                time = Math.fmaxf(0, time);

                bool increase = false;

                if (time >= 1)
                {
                    if (han_animation_index >= lines.size - 1)
                    {
                        animate_han = false;
                        fade_score = true;
                    }

                    timer.reset();
                    increase = true;
                    time = 1;
                }

                lines[han_animation_index].name.alpha = time;
                lines[han_animation_index].han.alpha = time;

                if (increase)
                    han_animation_index++;
            }

            if (fade_score)
            {
                float time = (timer.elapsed(args) - timings.score_counting_fade_delay) / timings.score_counting_fade_time;
                time = Math.fmaxf(0, time);

                if (time >= 1)
                {
                    timer.reset();
                    fade_score = false;
                    animate_score = true;
                    time = 1;
                }

                points_label.alpha = time;
            }

            if (animate_score)
            {
                float time = (timer.elapsed(args) - timings.score_counting_delay) / timings.score_counting_time;
                time = Math.fmaxf(0, time);

                if (time >= 1)
                {
                    animation_finished();
                    animate_score = false;
                    time = 1;
                }

                set_points_text(time);
            }
        }

        protected override void resized()
        {
            if (hand != null)
                hand.size = Size2(size.width, hand.size.height);
        }

        public void animate()
        {
            animate_items = true;
        }

        private void han_counting_delay_elapsed()
        {
            animate_han = true;
        }

        private void set_points_text(float amount)
        {
            string points;

            if (scoring.ron)
            {
                if (dual_payer)
                    points = "2 * " + ((int)(scoring.ron_points / 2 * amount)).to_string();
                else
                    points = ((int)(scoring.ron_points * amount)).to_string();
            }
            else
            {
                if (sekinin)
                    points = ((int)(scoring.total_points * amount)).to_string();
                else if (scoring.dealer)
                    points = "3 * " + ((int)(scoring.tsumo_points_higher * amount)).to_string();
                else
                    points = ((int)(scoring.tsumo_points_lower * amount)).to_string() + "/" + ((int)(scoring.tsumo_points_higher * amount)).to_string();
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

            points_label.text = name + points + " points";
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

        private class YakuLine
        {
            public YakuLine(LabelControl name, LabelControl han)
            {
                this.name = name;
                this.han = han;
            }

            public LabelControl name { get; private set; }
            public LabelControl han { get; private set; }
        }
    }
}
