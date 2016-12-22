public class AnimationTimings : Serializable
{
	public AnimationTimings
	(
		float round_end_delay,
		float hanchan_end_delay,
		float game_end_delay,
		float decision_time,
		float score_counting_delay,
		float score_counting_time
	)
	{
		this.round_end_delay = round_end_delay;
		this.hanchan_end_delay = hanchan_end_delay;
		this.game_end_delay = game_end_delay;
		this.decision_time = decision_time;
		this.score_counting_delay = score_counting_delay;
		this.score_counting_time = score_counting_time;
	}

	public float get_animation_round_end_delay(RoundScoreState round)
	{
	    float time;
        if (round.game_is_finished)
            time = game_end_delay;
        else if (round.hanchan_is_finished)
            time = hanchan_end_delay;
        else
            time = round_end_delay;

        foreach (var player in round.players)
            if (player.transfer != 0)
            {
                time += score_counting_time + score_counting_delay;
                break;
            }

        return time;
	}

	public float round_end_delay { get; protected set; }
	public float hanchan_end_delay { get; protected set; }
	public float game_end_delay { get; protected set; }
	public float decision_time { get; protected set; }

	public float score_counting_delay { get; protected set; }
	public float score_counting_time { get; protected set; }
}
