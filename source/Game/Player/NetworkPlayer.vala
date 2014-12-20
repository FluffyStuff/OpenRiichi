class NetworkPlayer : Player
{
    private GameConnection connection;

    public NetworkPlayer(int position, GameConnection connection)
    {
        base(position, connection.name);
        connection.call_action.connect(net_call_action);
        connection.turn_action.connect(net_turn_action);
        this.connection = connection;
    }

    ~NetworkPlayer()
    {
        connection.call_action.disconnect(net_call_action);
        connection.turn_action.disconnect(net_turn_action);
    }

    private void net_call_action(CallAction action)
    {
        print("Got call action!");
        call_action = action;
        state = PlayerState.READY;
    }

    private void net_turn_action(TurnAction action)
    {
        print("Got turn action!");
        turn_action = action;

        if (turn_action != null)
            state = PlayerState.READY;
    }
}
