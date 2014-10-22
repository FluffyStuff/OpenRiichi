class PlayerConnectedMessage : HostMessage
{
    protected PlayerConnectedMessage(uint8[] data)
    {
        base.empty();

        id = get_uint_at(data, 0);
        uint32 len = get_uint_at(data, 4);
        name = get_string_at(data, 8, len);
        silent = data[8 + len] != 0;
    }

    public PlayerConnectedMessage.message(uint32 id, string name, bool silent)
    {
        uint8 s = silent ? 1 : 0;

        Array<uint8> chunks = new Array<uint8>(true, true, 1);

        chunks.append_vals(int_to_data(id), 4);
        chunks.append_vals(int_to_data(name.length), 4);
        chunks.append_vals(name.data, name.length);
        chunks.append_val(s);

        base(chunks, PLAYER_CONNECTED);
        this.id = id;
        this.name = name;
        this.silent = silent;
    }

    public uint32 id { get; private set; }
    public string name { get; private set; }
    public bool silent { get; private set; }
}
