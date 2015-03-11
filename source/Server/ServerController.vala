class ServerController
{
    private Server server;
    private ServerNetworking net;
    private List<ServerPlayer> players = new List<ServerPlayer>();

    public ServerController()
    {
    }

    public bool listen(uint16 port)
    {
        net = new ServerNetworking();
        if (net.listen(port))
            return false;

        net.player_connected.connect(add_player);

        return true;
    }

    public void add_player(ServerPlayer player)
    {
        player.disconnected.connect(remove_player);
        players.append(player);
    }

    private void remove_player(ServerPlayer player)
    {
        players.remove(player);
    }

    public void start_game()
    {
        bool ready = true;
        int playing = 0;
        ServerPlayer[] players = new ServerPlayer[this.players.length()];

        int a = 0;
        foreach (ServerPlayer player in players)
        {
            if (player.state == ServerPlayer.State.PLAYER)
            {
                if (!player.ready)
                {
                    ready = false;
                    break;
                }

                players[a++] = player;
                playing++;
            }
        }

        if (!ready || playing != 4)
            return;

        server = new Server();
        server.create_game(players);
    }
}
