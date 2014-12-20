class PlayerMessage : GameMessage
{
    protected const uint32 CALL_ACTION = 0x1;
    protected const uint32 TURN_ACTION = 0x2;

    protected PlayerMessage(Array<uint8> chunks, uint32 type, uint32 id)
    {
        chunks.insert_vals(0, int_to_data(id), 4);
        chunks.insert_vals(0, int_to_data(type), 4);
        base(chunks, PLAYER);

        this.id = id;
    }

    public new static PlayerMessage? parse(uint8[] data)
    {
        uint32 t = get_uint_at(data, 0);
        uint32 id = get_uint_at(data, 4);

        uint8[] d = new uint8[data.length - 8];

        for (int i = 0; i < d.length; i++)
            d[i] = data[i+8];

        PlayerMessage msg = null;

        switch (t)
        {
        case CALL_ACTION:
            msg = new CallActionMessage(d);
            break;
        case TURN_ACTION:
            msg = new TurnActionMessage(d);
            break;
        }
        if (msg != null)
            msg.id = id;

        return msg;
    }

    public uint32 id { get; private set; }
}
