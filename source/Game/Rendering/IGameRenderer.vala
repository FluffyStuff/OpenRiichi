public interface IGameRenderer : Object
{
    public signal void tile_selected();
    public signal void ron();
    public signal void tsumo();
    public signal void riichi();
    public signal void kan();
    public signal void pon();
    public signal void chi();

    public abstract void set_active(bool active);
    //public void set_selectable_tiles(int[] tiles);
}
