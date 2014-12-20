public class ComputerPlayer : Player
{
    public ComputerPlayer(int position, string name)
    {
        base(position, name);
    }

    public override bool call_decision(Tile discard_tile, bool can_chi)
    {
        base.call_decision(discard_tile, can_chi);
        Threading.start3(call_decision_thread, this, discard_tile, new Obj<bool>(can_chi));
        return true;
    }

    public override bool turn_decision()
    {
        print("Bot starting decision\n");
        if (in_riichi &&
            !Logic.winning_hand(hand) &&
            !Logic.can_riichi_closed_kan(hand))
        {
            turn_action = new TurnAction.discard(hand[hand.size - 1].id);
            state = PlayerState.READY;
            return false;
        }

        state = PlayerState.DECIDING;

        Threading.start1(turn_decision_thread, this);

        if (in_riichi)
            return Logic.can_riichi_closed_kan(hand) || Logic.winning_hand(hand);
        else
            return
            Logic.can_closed_kan(hand) ||
            Logic.can_late_kan(hand, pons) ||
            (!open_hand && Logic.can_tenpai(hand).size != 0) ||
            Logic.winning_hand(hand);
    }

    private static void call_decision_thread(Object player_obj, Object tile_obj, Object can_chi_obj)
    {
        print("Bot starting call decision\n");
        ComputerPlayer p = (ComputerPlayer)player_obj;
        Tile discard_tile = (Tile)tile_obj;
        bool can_chi = ((Obj<bool>)can_chi_obj).obj;

        p.call_action = Bot.make_call(0, p, discard_tile, can_chi);
        p.state = PlayerState.READY;
    }

    private static void turn_decision_thread(Object player_obj)
    {
        print("Bot starting decision thread\n");
        ComputerPlayer p = (ComputerPlayer)player_obj;
        print("in between\n");
        p.turn_action = Bot.make_move(0, p);
        print("Bot finished decision\n");

        if (p.turn_action != null)
            p.state = PlayerState.READY;
        print("Bot decision thread over\n");
    }
}
