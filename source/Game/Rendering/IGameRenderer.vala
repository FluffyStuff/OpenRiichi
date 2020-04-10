public interface IGameRenderer
{
    public signal void tile_selected(Tile tile);
    public abstract void set_active(bool active);
    public abstract void tile_assignment(Tile tile);
    public abstract void tile_draw(int player_index);
    public abstract void tile_discard(int player_index, int tile_ID);
    public abstract void flip_dora();
    public abstract void game_finished(RoundFinishResult result);
    public abstract void riichi(int player_index, bool open);
    public abstract void late_kan(int player_index, int tile_ID);
    public abstract void closed_kan(int player_index, TileType type);
    public abstract void open_kan(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID);
    public abstract void pon(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID);
    public abstract void chii(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID);
}
