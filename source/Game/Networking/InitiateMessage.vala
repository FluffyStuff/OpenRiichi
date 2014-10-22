class InitiateMessage : GameMessage
{
    protected InitiateMessage(uint8[] data, uint32 type)
    {
        base.empty();

        if (type == INIT)
        {
            major = get_uint_at(data, 0);
            minor = get_uint_at(data, 4);
            revision = get_uint_at(data, 8);
            accepted = true;
            reply = false;
            name = "";
        }
        else if (type == INIT_REPLY)
        {
            major = 0;
            minor = 0;
            revision = 0;
            accepted = data[0] != 0;
            reply = true;
            uint32 len = get_uint_at(data, 1);
            name = get_string_at(data, 5, len);
        }
    }

    public InitiateMessage.initiate(uint32 major, uint32 minor, uint32 revision)
    {
        Array<uint8> chunks = new Array<uint8>(true, true, 1);

        chunks.append_vals(int_to_data(major), 4);
        chunks.append_vals(int_to_data(minor), 4);
        chunks.append_vals(int_to_data(revision), 4);

        base(chunks, INIT);

        this.major = major;
        this.minor = minor;
        this.revision = revision;
        accepted = true;
        reply = false;
    }

    public InitiateMessage.initiate_reply(bool accepted, string name)
    {
        uint8 c = accepted ? 1 : 0;
        Array<uint8> chunks = new Array<uint8>(true, true, 1);
        chunks.append_val(c);
        chunks.append_vals(int_to_data(name.length), 4);
        chunks.append_vals(name.data, name.length);

        base(chunks, INIT_REPLY);
        major = 0;
        minor = 0;
        revision = 0;
        this.accepted = accepted;
        reply = true;
        this.name = name;
    }

    public uint32 major { get; private set; }
    public uint32 minor { get; private set; }
    public uint32 revision { get; private set; }
    public bool accepted { get; private set; }
    public bool reply { get; private set; }
    public string name { get; private set; }
}
