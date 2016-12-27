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
        float finish_label_delay,
        float finish_label_fade_time,
        float finish_label_animation_time,
        float menu_items_fade_time,
        float han_counting_delay,
        float han_fade_delay,
        float han_fade_time,
        float score_counting_fade_delay,
        float score_counting_fade_time,
        float score_counting_delay,
        float score_counting_time,
        float players_score_counting_delay,
        float players_score_counting_time
	)
	{
        this.winning_draw_animation_time = winning_draw_animation_time;
        this.hand_reveal_animation_time = hand_reveal_animation_time;
        this.round_over_delay = round_over_delay;
		this.round_end_delay = round_end_delay;
		this.hanchan_end_delay = hanchan_end_delay;
		this.game_end_delay = game_end_delay;
		this.decision_time = decision_time;
        this.finish_label_delay = finish_label_delay;
        this.finish_label_fade_time = finish_label_fade_time;
        this.finish_label_animation_time = finish_label_animation_time;
        this.menu_items_fade_time = menu_items_fade_time;
        this.han_counting_delay = han_counting_delay;
        this.han_fade_delay = han_fade_delay;
        this.han_fade_time = han_fade_time;
		this.score_counting_fade_delay = score_counting_fade_delay;
		this.score_counting_fade_time = score_counting_fade_time;
		this.score_counting_delay = score_counting_delay;
		this.score_counting_time = score_counting_time;
        this.players_score_counting_delay = players_score_counting_delay;
        this.players_score_counting_time = players_score_counting_time;
	}

	public float get_animation_round_end_delay(RoundScoreState round)
	{
	    float time = 0;

	    time += round_over_delay;
        time += finish_label_delay + finish_label_fade_time + finish_label_animation_time;

	    if (round.result.result != RoundFinishResult.RoundResultEnum.DRAW &&
            round.result.result != RoundFinishResult.RoundResultEnum.NONE)
        {
            time += menu_items_fade_time + han_counting_delay + score_counting_fade_delay + score_counting_fade_time + score_counting_delay + score_counting_time;

            Scoring score = round.result.scores[0];

            foreach (Yaku y in score.yaku)
            {
                if (score.yakuman == 0 || y.yakuman > 0)
                    time += han_fade_delay + han_fade_time;
            }
        }
        else if (round.result.nagashi_indices.length != 0)
            time += menu_items_fade_time + han_counting_delay + score_counting_fade_delay + score_counting_fade_time + score_counting_delay + score_counting_time;

        if (round.game_is_finished)
            time += game_end_delay;
        else if (round.hanchan_is_finished)
            time += hanchan_end_delay;
        else
            time += round_end_delay;

        foreach (var player in round.players)
            if (player.transfer != 0)
            {
                time += players_score_counting_delay + players_score_counting_time;
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

	public float finish_label_delay { get; protected set; }
	public float finish_label_fade_time { get; protected set; }
	public float finish_label_animation_time { get; protected set; }
	public float menu_items_fade_time { get; protected set; }
	public float han_counting_delay { get; protected set; }
	public float han_fade_delay { get; protected set; }
	public float han_fade_time { get; protected set; }
	public float score_counting_fade_delay { get; protected set; }
	public float score_counting_fade_time { get; protected set; }
	public float score_counting_delay { get; protected set; }
	public float score_counting_time { get; protected set; }

	public float players_score_counting_delay { get; protected set; }
	public float players_score_counting_time { get; protected set; }
}
