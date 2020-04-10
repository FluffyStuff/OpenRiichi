using Engine;
using Lobby;

public class LobbyUserListControl : ListControl
{
    private ClientLobbyUser[]? users;

    public LobbyUserListControl()
    {
        base(false);
        font_size = 30;
        row_height = 35;
    }

    public void set_users(ClientLobbyUser[]? users)
    {
        this.users = users;
        refresh_data();
    }

    protected override void added()
    {
        refresh_data();
    }

    protected override string get_cell_data(int row, int column)
    {
        if (users == null)
            return "";

        ClientLobbyUser user = users[row];
        return user.name;
    }

    protected override ListColumnInfo get_column_info(int column)
    {
        return new ListColumnInfo("Users", new ListCellStyle(ResizeStyle.RELATIVE, 1));
    }

    protected override int row_count
    {
        get
        {
            if (users == null)
                return 0;
            return users.length;
        }
    }

    protected override int column_count
    {
        get { return 1; }
    }
}
