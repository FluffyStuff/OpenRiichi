using Engine;
using Lobby;

public class LobbyInformationListControl : ListControl
{
    private LobbyInformation[]? lobbies;

    public LobbyInformationListControl()
    {
        base(true);
        font_size = 40;
        row_height = 45;
    }

    public void set_lobbies(LobbyInformation[] lobbies)
    {
        this.lobbies = lobbies;
        refresh_data();
    }

    protected override void added()
    {
        refresh_data();
    }

    protected override string get_cell_data(int row, int column)
    {
        if (lobbies == null)
            return "";

        LobbyInformation lobby = lobbies[row];

        if (column == 0)
            return lobby.name;
        return lobby.users.to_string();
    }

    protected override ListColumnInfo get_column_info(int column)
    {
        if (column == 0)
            return new ListColumnInfo("Lobby", new ListCellStyle(ResizeStyle.RELATIVE, 1));
        else
            return new ListColumnInfo("Users", new ListCellStyle(ResizeStyle.ABSOLUTE, 150));
    }

    protected override int row_count
    {
        get
        {
            if (lobbies == null)
                return 0;
            return lobbies.length;
        }
    }

    protected override int column_count
    {
        get { return 2; }
    }
}
