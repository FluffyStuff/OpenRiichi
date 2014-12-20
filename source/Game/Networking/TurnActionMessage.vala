class TurnActionMessage : PlayerMessage
{
    protected TurnActionMessage(uint8[] data)
    {
        base.empty();

        var action = (TurnAction.TurnActionEnum)data[0];

        int i = 2;

        bool r = data[1] != 0;
        uint8? discard_tile = null;
        if (r)
            discard_tile = data[i++];

        r = data[i++] != 0;
        uint8? late_kan_tile = null;
        if (r)
            late_kan_tile = data[i++];

        r = data[i++] != 0;
        uint8? late_kan_pon = null;
        if (r)
            late_kan_pon = data[i++];

        uint32 len = get_uint_at(data, i);
        i += 4;

        uint8[] kan_tiles = null;

        if (len > 0)
        {
            kan_tiles = new uint8[len];
            for (int j = 0; j < len; j++)
                kan_tiles[j] = data[j+i];
        }

        turn_action = new TurnAction.set(action, discard_tile, late_kan_tile, late_kan_pon, kan_tiles);
    }

    public TurnActionMessage.message(uint32 id, TurnAction action)
    {
        Array<uint8> chunks = new Array<uint8>(true, true, 1);

        uint8 act = (uint8)action.action;

        chunks.append_val(act);

        uint8 c = (action.discard_tile != null) ? 1 : 0;
        chunks.append_val(c);
        if (action.discard_tile != null)
            chunks.append_val(action.discard_tile);

        c = (action.late_kan_tile != null) ? 1 : 0;
        chunks.append_val(c);
        if (action.late_kan_tile != null)
            chunks.append_val(action.late_kan_tile);

        c = (action.late_kan_pon != null) ? 1 : 0;
        chunks.append_val(c);
        if (action.late_kan_pon != null)
            chunks.append_val(action.late_kan_pon);

        uint32 len = 0;
        if (action.kan_tiles != null)
            len = action.kan_tiles.length;
        chunks.append_vals(int_to_data(len), 4);
        if (action.kan_tiles != null)
            chunks.append_vals(action.kan_tiles, len);

        base(chunks, TURN_ACTION, id);

        turn_action = action;
    }

    public TurnAction turn_action { get; private set; }
}
