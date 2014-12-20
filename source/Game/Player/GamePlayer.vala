class GamePlayer : Player
{
    private GameConnection? connection;

    private CallAction? _call_action;
    private TurnAction? _turn_action;

    public GamePlayer(int position, string name, GameConnection? connection)
    {
        base(position, name);
        this.connection = connection;
    }

    public override void draw_tile(Tile t)
    {
        if (hand.size <= 1)
        {
            t.position = new Vector(Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2 + Tile.TILE_SPACING, -2.6f, Tile.TILE_WIDTH / 2 - 0.05f);
            t.rotation = new Vector(40, 0, 90);
        }
        else if (hand.size <= 4)
        {
            t.position = new Vector(Tile.TILE_HEIGHT / 2, hand_height, Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2 - 0.14f);
            t.rotation = new Vector(40, 0, 90);
        }
        else
        {
            t.position = new Vector((Tile.TILE_WIDTH + Tile.TILE_SPACING) * ((hand.size - 2) / 2.0f) + Tile.TILE_HEIGHT / 2, hand_height, Tile.TILE_HEIGHT + Tile.TILE_WIDTH / 2 - 0.14f);
            t.rotation = new Vector(40, 0, 90);
        }

        hand.add(t);
    }

    public override void arrange_hand()
    {
        Tile.sort_tiles(hand);

        for (int i = 0; i < hand.size; i++)
        {
            hand[i].position = new Vector((i - (hand.size - 1) / 2.0f) * (Tile.TILE_WIDTH + Tile.TILE_SPACING), -2.7f, 0);
            hand[i].rotation = new Vector(40, 0, 0);
        }
    }

    private void send_call_action(CallAction? action)
    {
        if (connection != null && action != null)
            connection.send_call_action(action);
    }

    private void send_turn_action(TurnAction? action)
    {
        if (connection != null && action != null)
            connection.send_turn_action(action);
    }

    public override CallAction? call_action
    {
        get { return _call_action; }
        set
        {
            _call_action = value;
            if (value != null)
                send_call_action(value);
        }
    }

    public override TurnAction? turn_action
    {
        get { return _turn_action; }
        set
        {
            _turn_action = value;
            if (value != null)
                send_turn_action(value);
        }
    }
}
