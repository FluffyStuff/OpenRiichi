class GameStartMessage : HostMessage
{
    protected GameStartMessage(uint8[] data)
    {
        base.empty();
        delay = data[0];
        tile_seed = new uint8[136];
        for (int i = 0; i < tile_seed.length; i++)
            tile_seed[i] = data[i+1];
        wall_split = data[137];
        seat = data[138];
    }

    public GameStartMessage.message(uint8 delay, uint8[] tile_seed, uint8 wall_split, uint8 seat)
    {
        Array<uint8> chunks = new Array<uint8>(true, true, 1);
        chunks.append_val(delay);
        chunks.append_vals(tile_seed, tile_seed.length);
        chunks.append_val(wall_split);
        chunks.append_val(seat);

        base(chunks, GAME_START);
        this.delay = delay;
        this.tile_seed = tile_seed;
        this.wall_split = wall_split;
        this.seat = seat;
    }

    public uint8 delay { get; private set; }
    public uint8[] tile_seed { get; private set; }
    public uint8 wall_split { get; private set; }
    public uint8 seat { get; private set; }
}
