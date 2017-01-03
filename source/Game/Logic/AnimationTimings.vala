public class AnimationTimings : Serializable
{
	public AnimationTimings
	(
        float winning_draw_animation_time,
        float hand_reveal_animation_time,
        float round_over_delay,
        float round_end_delay,
        float hanchan_end_delay,
        float game_end_delay,
        float decision_time,
        AnimationTime finish_label_fade,
        AnimationTime menu_items_fade,
        AnimationTime han_fade,
        AnimationTime score_counting_fade,
        AnimationTime score_counting,
        AnimationTime players_points_counting,
        AnimationTime players_score_fade,
        AnimationTime players_score_counting
	)
	{
        this.winning_draw_animation_time = winning_draw_animation_time;
        this.hand_reveal_animation_time = hand_reveal_animation_time;
        this.round_over_delay = round_over_delay;
		this.round_end_delay = round_end_delay;
		this.hanchan_end_delay = hanchan_end_delay;
		this.game_end_delay = game_end_delay;
		this.decision_time = decision_time;
        this.finish_label_fade = finish_label_fade;
        this.menu_items_fade = menu_items_fade;
        this.han_fade = han_fade;
        this.score_counting_fade = score_counting_fade;
        this.score_counting = score_counting;
        this.players_points_counting = players_points_counting;
        this.players_score_fade = players_score_fade;
        this.players_score_counting = players_score_counting;
	}

	public float get_animation_round_end_delay(RoundScoreState round)
	{
	    float time = 0;

	    time += round_over_delay;
        time += finish_label_fade.total() + menu_items_fade.total();

	    if (round.result.result != RoundFinishResult.RoundResultEnum.DRAW &&
            round.result.result != RoundFinishResult.RoundResultEnum.NONE)
        {
            foreach (Scoring score in round.result.scores)
            {
                time += score_counting_fade.total() + score_counting.total();

                foreach (Yaku y in score.yaku)
                    if (score.yakuman == 0 || y.yakuman > 0)
                        time += han_fade.total();
            }
        }

        if (round.game_is_finished)
            time += game_end_delay + players_score_fade.total() + players_score_counting.total();
        else if (round.hanchan_is_finished)
            time += hanchan_end_delay + players_score_fade.total() + players_score_counting.total();
        else
            time += round_end_delay;

        foreach (var player in round.players)
            if (player.transfer != 0)
            {
                time += players_points_counting.total();
                break;
            }

        return time;
	}

	public float winning_draw_animation_time { get; protected set; }
	public float hand_reveal_animation_time { get; protected set; }

	public float round_over_delay { get; protected set; }

	public float round_end_delay { get; protected set; }
	public float hanchan_end_delay { get; protected set; }
	public float game_end_delay { get; protected set; }
	public float decision_time { get; protected set; }

	public AnimationTime finish_label_fade { get; protected set; }
	public AnimationTime menu_items_fade { get; protected set; }
	public AnimationTime han_fade { get; protected set; }

	public AnimationTime score_counting_fade { get; protected set; }
	public AnimationTime score_counting { get; protected set; }

	public AnimationTime players_points_counting { get; protected set; }
	public AnimationTime players_score_fade { get; protected set; }
	public AnimationTime players_score_counting { get; protected set; }
}
