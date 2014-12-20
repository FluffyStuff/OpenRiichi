class CallActionMessage : PlayerMessage
{
    protected CallActionMessage(uint8[] data)
    {
        base.empty();

        var action = (CallAction.CallActionEnum)data[0];
        uint32 len = get_uint_at(data, 1);

        uint8[] tiles = null;

        if (len > 0)
        {
            tiles = new uint8[len];
            for (int i = 0; i < len; i++)
                tiles[i] = data[i+5];
        }

        bool r = data[len + 5] != 0;
        uint8? ron = null;
        if (r)
            ron = data[len + 6];

        call_action = new CallAction.set(action, tiles, ron);
    }

    public CallActionMessage.message(uint32 id, CallAction action)
    {
        Array<uint8> chunks = new Array<uint8>(true, true, 1);

        uint8 act = (uint8)action.action;

        chunks.append_val(act);

        uint32 len = 0;
        if (action.tiles != null)
            len = action.tiles.length;
        chunks.append_vals(int_to_data(len), 4);
        if (action.tiles != null)
            chunks.append_vals(action.tiles, len);

        uint8 ron_tile = (action.ron_tile != null) ? 1 : 0;
        chunks.append_val(ron_tile);
        if (action.ron_tile != null)
            chunks.append_val(action.ron_tile);

        base(chunks, CALL_ACTION, id);

        call_action = action;
    }

    public CallAction call_action { get; private set; }
}

