class GameMessage : Message
{
    protected const uint32 INIT       = 0x1;
    protected const uint32 INIT_REPLY = 0x2;
    protected const uint32 HOST       = 0x10;
    protected const uint32 PLAYER     = 0x20;

    private uint32 type;

    protected GameMessage(Array<uint8> chunks, uint32 type)
    {
        chunks.insert_vals(0, int_to_data(type), 4);

        uint8[] d = new uint8[chunks.length];

        for (int i = 0; i < chunks.length; i++)
            d[i] = chunks.index(i);

        base(d);

        this.type = type;
    }

    public static GameMessage? parse(Message message)
    {
        uint32 t = get_uint_at(message.data, 0);

        uint8[] data = new uint8[message.data.length - 4];

        for (int i = 0; i < data.length; i++)
            data[i] = message.data[i+4];

        switch (t)
        {
        case INIT:
        case INIT_REPLY:
            return new InitiateMessage(data, t);
        case HOST:
            return HostMessage.parse(data);
        }

        return null;
    }

    protected static uint32 get_uint_at(uint8[] data, int pos)
    {
        uint32 u = 0;
        for (int i = 0; i < 4; i++)
            u += data[pos+i] << (8 * (3 - i));

        return u;
    }

    protected static string get_string_at(uint8[] data, uint32 pos, uint32 len)
    {
        uint8[] d = new uint8[len];
        for (int i = 0; i < len; i++)
            d[i] = data[i + pos];
        return (string)d;
    }
}
