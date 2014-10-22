public uint8[] int_to_data(uint32 n)
{
    uint8[] buffer = new uint8[4];
    buffer[0] = (uint8)(n >> 24);
    buffer[1] = (uint8)(n >> 16);
    buffer[2] = (uint8)(n >>  8);
    buffer[3] = (uint8)n;
    return buffer;
}
