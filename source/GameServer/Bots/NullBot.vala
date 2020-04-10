class NullBot : Bot
{
    protected override void do_turn_decision()
    {
        do_discard(round_state.self.get_default_discard_tile());
    }

    protected override void do_call_decision(RoundStatePlayer discarding_player, Tile tile)
    {
        call_nothing();
    }

    public override string name { get { return "NullBot"; } }
}
