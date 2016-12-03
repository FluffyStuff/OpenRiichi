class GameController : Object
{
    private GameState game;
    private ClientRoundState round;
    private GameRenderView? renderer = null;
    private GameMenuView? menu = null;

    private unowned Container parent_view;
    private GameStartInfo start_info;
    private ServerSettings settings;
    private IGameConnection connection;
    private int player_index;

    private Options options;
    private bool game_finished = false;
    private bool is_disconnected = false;
    public signal void finished();

    public GameController(Container parent_view, GameStartInfo start_info, ServerSettings settings, IGameConnection connection, int player_index, Options options)
    {
        this.parent_view = parent_view;
        this.start_info = start_info;
        this.settings = settings;
        this.connection = connection;
        this.player_index = player_index;

        this.connection.disconnected.connect(disconnected);

        this.options = options;
        string quality = Options.quality_enum_to_string(options.shader_quality);
        parent_view.window.renderer.shader_3D = "open_gl_shader_3D_" + quality;

        game = new GameState(start_info, settings);
    }

    ~GameController()
    {
        connection.close();

        parent_view.remove_child(renderer);
        parent_view.remove_child(menu);
    }

    public void process()
    {
        if (game_finished == true)
        {
            finished();
            return;
        }

        ServerMessage? message = null;
        while ((message = connection.dequeue_message()) != null)
        {
            if (!game.round_is_finished)
                round.receive_message(message);

            if (message is ServerMessageRoundStart)
            {
                ServerMessageRoundStart start = message as ServerMessageRoundStart;
                create_round(start.info);
            }
            else if (message is ServerMessagePlayerLeft && !game.game_is_finished)
            {
                ServerMessagePlayerLeft msg = message as ServerMessagePlayerLeft;
                menu.display_player_left(game.get_player(msg.player_index).name);
            }
        }

        if (!game.round_is_finished)
        {
            if (round.finished)
            {
                var result = game.round_finished(round.result);
                menu.display_score(result, true, false);
            }
        }
    }

    public void load_options(Options options)
    {
        this.options = options;

        renderer.load_options(options);

        string quality = Options.quality_enum_to_string(options.shader_quality);
        parent_view.window.renderer.shader_3D = "open_gl_shader_3D_" + quality;
    }

    private void create_round_state(RoundStartInfo round_start)
    {
        round = new ClientRoundState(round_start, settings, player_index, game.round_wind, game.dealer_index, game.can_riichi());
        round.send_message.connect(connection.send_message);
        round.set_chii_state.connect(menu.set_chii);
        round.set_pon_state.connect(menu.set_pon);
        round.set_kan_state.connect(menu.set_kan);
        round.set_riichi_state.connect(menu.set_riichi);
        round.set_tsumo_state.connect(menu.set_tsumo);
        round.set_ron_state.connect(menu.set_ron);
        round.set_timer_state.connect(menu.set_timer);
        round.set_continue_state.connect(menu.set_continue);
        round.set_void_hand_state.connect(menu.set_void_hand);
        round.set_furiten_state.connect(menu.set_furiten);
        round.set_tile_select_state.connect(renderer.set_active);
        round.set_tile_select_groups.connect(renderer.set_tile_select_groups);
        round.game_riichi.connect(declared_riichi);

        round.game_finished.connect(renderer.game_finished);
        round.game_tile_assignment.connect(renderer.tile_assignment);
        round.game_tile_draw.connect(renderer.tile_draw);
        round.game_dead_tile_draw.connect(renderer.dead_tile_draw);
        round.game_tile_discard.connect(renderer.tile_discard);
        round.game_flip_dora.connect(renderer.flip_dora);
        round.game_riichi.connect(renderer.riichi);
        round.game_late_kan.connect(renderer.late_kan);
        round.game_closed_kan.connect(renderer.closed_kan);
        round.game_open_kan.connect(renderer.open_kan);
        round.game_pon.connect(renderer.pon);
        round.game_chii.connect(renderer.chii);

        renderer.tile_selected.connect(round.client_tile_selected);

        if (menu != null)
        {
            menu.chii_pressed.connect(round.client_chii);
            menu.pon_pressed.connect(round.client_pon);
            menu.kan_pressed.connect(round.client_kan);
            menu.riichi_pressed.connect(round.client_riichi);
            menu.tsumo_pressed.connect(round.client_tsumo);
            menu.ron_pressed.connect(round.client_ron);
            menu.continue_pressed.connect(round.client_continue);
            menu.void_hand_pressed.connect(round.client_void_hand);
        }
    }

    private void create_round(RoundStartInfo info)
    {
        if (renderer != null)
            parent_view.remove_child(renderer);
        if (menu != null)
            parent_view.remove_child(menu);

        int index = player_index == -1 ? 0 : player_index;

        game.start_round(info);
        menu = new GameMenuView(settings, index, start_info.decision_time, start_info.round_wait_time, start_info.hanchan_wait_time, start_info.game_wait_time);
        menu.display_score_pressed.connect(display_score_pressed);
        menu.score_timer_expired.connect(score_timer_expired);

        renderer = new GameRenderView(info, player_index, game.round_wind, game.dealer_index, options, game.score);
        parent_view.add_child(renderer);
        parent_view.add_child(menu);

        create_round_state(info);
    }

    private void declared_riichi(int player_index, bool open)
    {
        game.declare_riichi(player_index);
    }

    private void display_score_pressed()
    {
        if (menu != null)
            menu.display_score(game.score, false, false);
    }

    private void score_timer_expired()
    {
        if (game.game_is_finished || is_disconnected)
            game_finished = true;
    }

    private void disconnected()
    {
        is_disconnected = true;

        if (menu != null && !game.game_is_finished)
        {
            if (round != null)
                round.disconnected();
            menu.display_score(game.score, true, true);
            menu.display_disconnected();
        }
    }
}
