public static int main(string[] args)
{
    /*ArrayList<Tile> hand = new ArrayList<Tile>();

    TileType[] tile_types =
    {

        TileType.PIN6,
        TileType.PIN7,
        TileType.PIN8,

        TileType.MAN2,
        TileType.MAN1,
        TileType.MAN3,

        TileType.SHAA,
        TileType.SHAA,
        TileType.SHAA,

        TileType.MAN3,
        TileType.MAN1,
        TileType.MAN2,

        TileType.HAKU,
    };

    for (int i = 0; i < tile_types.length; i++)
        hand.add(new Tile(i, tile_types[i], false));

    ArrayList<Tile> pond = new ArrayList<Tile>();
    ArrayList<RoundStateCall> calls = new ArrayList<RoundStateCall>();
    Wind wind = Wind.NORTH;
    bool dealer = false;
    bool in_riichi = false;
    bool double_riichi = false;
    bool ippatsu = false;
    bool tiles_called_on = true;

    Wind round_wind = Wind.EAST;
    ArrayList<Tile> dora = new ArrayList<Tile>();
    ArrayList<Tile> ura_dora = new ArrayList<Tile>();
    bool ron = true;
    Tile win_tile = new Tile(14, TileType.HAKU, false);
    bool last_tile = false;
    bool rinshan = false;
    bool chankan = false;
    bool flow_interrupted = true;
    bool first_turn = false;

    PlayerStateContext player = new PlayerStateContext(hand, pond, calls, wind, dealer, in_riichi, double_riichi, ippatsu, tiles_called_on);
    RoundStateContext round = new RoundStateContext(round_wind, dora, ura_dora, ron, win_tile, last_tile, rinshan, chankan, flow_interrupted, first_turn);

    Scoring score = TileRules.get_score(player, round);

    foreach (Yaku yaku in score.yaku)
    {
        print(yaku.yaku_type.to_string() + "\n");
    }

    return 0;*/

    Environment environment = new Environment();
    if (!environment.init(2))
        return -1;

    //Threading.start1(start_game, environment);
    start_game(environment);

    return 0;
}

private static void start_game(Object env)
{
    Environment environment = (Environment)env;

    SDL.Window wnd = environment.createWindow("RiichiMahjong", 1280, 720);
    SDLWindowTarget sdlWindow = new SDLWindowTarget(wnd);
    OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
    MainWindow window = new MainWindow(sdlWindow, renderer);

    if (!renderer.start())
        return;

    window.show();

    renderer.stop();
}
