using Engine;
using Lobby;

public class LobbyGameListControl : ListControl
{
    private ClientLobbyGame[]? games;

    public LobbyGameListControl()
    {
        base(true);
        font_size = 30;
        row_height = 35;
    }

    public void set_games(ClientLobbyGame[] games)
    {
        this.games = games;
        refresh_data();
    }

    protected override void added()
    {
        refresh_data();
    }

    protected override string get_cell_data(int row, int column)
    {
        if (games == null)
            return "";

        ClientLobbyGame game = games[row];

        if (column == 0)
        {
            if (game.users.size == 0)
                return "Empty game";
            else
                return game.users[0].name + "'s game";
        }

        return game.users.size.to_string();
    }

    protected override ListColumnInfo get_column_info(int column)
    {
        if (column == 0)
            return new ListColumnInfo("Game", new ListCellStyle(ResizeStyle.RELATIVE, 1));
        else
            return new ListColumnInfo("Players", new ListCellStyle(ResizeStyle.ABSOLUTE, 100));
    }

    protected override int row_count
    {
        get
        {
            if (games == null)
                return 0;
            return games.length;
        }
    }

    protected override int column_count
    {
        get { return 2; }
    }
}
