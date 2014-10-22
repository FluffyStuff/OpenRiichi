class HostMessage : GameMessage
{
    protected const uint32 PLAYER_CONNECTED = 0x1;
    protected const uint32 GAME_START = 0x2;

    private uint32 type;

    protected HostMessage(Array<uint8> chunks, uint32 type)
    {
        chunks.insert_vals(0, int_to_data(type), 4);
        base(chunks, HOST);
        this.type = type;
    }

    public new static HostMessage? parse(uint8[] data)
    {
        uint32 t = get_uint_at(data, 0);

        uint8[] d = new uint8[data.length - 4];

        for (int i = 0; i < d.length; i++)
            d[i] = data[i+4];

        switch (t)
        {
        case PLAYER_CONNECTED:
            return new PlayerConnectedMessage(d);
        case GAME_START:
            return new GameStartMessage(d);
        }

        return null;
    }
}
