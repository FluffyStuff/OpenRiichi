public class GameController
{
    private GameState game;
    private RoundState round;
    private GameRenderView? renderer = null;
    private GameMenuView? menu = null;

    private unowned View parent_view;
    private GameStartInfo start_info;
    private IGameConnection connection;
    private int player_index;

    private string extension;
    private bool game_finished = false;
    public signal void finished();

    public GameController(View parent_view, GameStartInfo start_info, IGameConnection connection, int player_index, Options options)
    {
        this.parent_view = parent_view;
        this.start_info = start_info;
        this.connection = connection;
        this.player_index = player_index;

        this.connection.disconnected.connect(disconnected);

        string quality = Options.quality_enum_to_string(options.shader_quality);
        extension = Options.quality_enum_to_string(options.model_quality);

        parent_view.window.renderer.shader_3D = "open_gl_shader_3D_" + quality;

        game = new GameState(start_info);
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
            if (renderer != null)
                renderer.receive_message(message);
            if (!game.round_is_finished)
                round.receive_message(message);

            if (message is ServerMessageRoundStart)
            {
                ServerMessageRoundStart start = message as ServerMessageRoundStart;
                create_round(start.info);
            }
        }

        if (!game.round_is_finished)
        {
            if (round.finished)
            {
                var state = game.round_finished(round.result);
                menu.display_score(state, player_index, start_info.round_wait_time, start_info.hanchan_wait_time, start_info.game_wait_time);

                print("----Client----\n");
                print(game.to_string() + "\n");
            }
        }
    }

    private void create_round_state(RoundStartInfo round_start)
    {
        round = new RoundState(round_start, player_index, game.round_wind, game.dealer_index);
        round.send_message.connect(connection.send_message);
        round.set_chii_state.connect(menu.set_chii);
        round.set_pon_state.connect(menu.set_pon);
        round.set_kan_state.connect(menu.set_kan);
        round.set_riichi_state.connect(menu.set_riichi);
        round.set_tsumo_state.connect(menu.set_tsumo);
        round.set_ron_state.connect(menu.set_ron);
        round.set_continue_state.connect(menu.set_continue);
        round.set_tile_select_state.connect(renderer.set_active);
        round.set_tile_select_groups.connect(renderer.set_tile_select_groups);

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
        }
    }

    private void create_round(RoundStartInfo info)
    {
        if (renderer != null)
            parent_view.remove_child(renderer);
        if (menu != null)
        {
            /*if (round != null)
            {
                menu.chii_pressed.disconnect(round.client_chii);
                menu.pon_pressed.disconnect(round.client_pon);
                menu.kan_pressed.disconnect(round.client_kan);
                menu.riichi_pressed.disconnect(round.client_riichi);
                menu.tsumo_pressed.disconnect(round.client_tsumo);
                menu.ron_pressed.disconnect(round.client_ron);
                menu.continue_pressed.disconnect(round.client_continue);
            }*/

            parent_view.remove_child(menu);
        }

        game.start_round(info);
        menu = new GameMenuView();
        menu.quit.connect(finish_game);

        renderer = new GameRenderView(info, player_index, game.round_wind, game.dealer_index, extension);
        parent_view.add_child(renderer);
        parent_view.add_child(menu);

        if (player_index != -1)
            create_round_state(info);
    }

    private void disconnected()
    {
        finish_game();
    }

    private void finish_game()
    {
        game_finished = true;
    }
}
