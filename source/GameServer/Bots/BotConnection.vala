class BotConnection : Object
{
    private Bot bot;
    private IGameConnection connection;
    private ServerMessageParser parser = new ServerMessageParser();

    public BotConnection(Bot bot, IGameConnection connection)
    {
        this.bot = bot;
        this.connection = connection;

        connection.received_message.connect(message_received);
        parser.connect(round_start, typeof(ServerMessageRoundStart));
        parser.connect(tile_assignment, typeof(ServerMessageTileAssignment));
        parser.connect(tile_draw, typeof(ServerMessageTileDraw));
        parser.connect(tile_discard, typeof(ServerMessageTileDiscard));
        parser.connect(ron, typeof(ServerMessageRon));
        parser.connect(tsumo, typeof(ServerMessageTsumo));
        parser.connect(riichi, typeof(ServerMessageRiichi));
        parser.connect(turn_decision, typeof(ServerMessageTurnDecision));
        parser.connect(call_decision, typeof(ServerMessageCallDecision));
        parser.connect(late_kan, typeof(ServerMessageLateKan));
        parser.connect(closed_kan, typeof(ServerMessageClosedKan));
        parser.connect(open_kan, typeof(ServerMessageOpenKan));
        parser.connect(pon, typeof(ServerMessagePon));
        parser.connect(chii, typeof(ServerMessageChii));
        parser.connect(calls_finished, typeof(ServerMessageCallsFinished));
        parser.connect(draw, typeof(ServerMessageDraw));

        bot.poll.connect(poll);
        bot.do_discard.connect(bot_do_discard);
        bot.do_void_hand.connect(bot_do_void_hand);
        bot.do_tsumo.connect(bot_do_tsumo);
        bot.do_riichi.connect(bot_do_riichi);
        bot.do_late_kan.connect(bot_do_late_kan);
        bot.do_closed_kan.connect(bot_do_closed_kan);
        bot.call_nothing.connect(bot_call_nothing);
        bot.call_ron.connect(bot_call_ron);
        bot.call_open_kan.connect(bot_call_open_kan);
        bot.call_pon.connect(bot_call_pon);
        bot.call_chii.connect(bot_call_chii);
    }

    ~BotConnection()
    {
        connection.received_message.disconnect(message_received);
        bot.poll.disconnect(poll);

        stop();
    }

    public void stop()
    {
        bot.stop(true);
    }

    private void message_received()
    {
        ServerMessage? message;

        while ((message = connection.dequeue_message()) != null)
        {
            if (message is ServerMessageGameStart)
            {
                ServerMessageGameStart start = message as ServerMessageGameStart;
                bot.init_game(start.info, start.settings, start.player_index);
            }
            else if (message is ServerMessageRoundStart)
            {
                connection.received_message.disconnect(message_received);
                var start = message as ServerMessageRoundStart;
                bot.start_round(true, start.info);
                break;
            }
        }
    }

    private void poll()
    {
        ServerMessage? message;
        while ((message = connection.dequeue_message()) != null)
            parser.execute(message);
    }

    private void round_start(ServerMessage message)
    {
        ServerMessageRoundStart start = message as ServerMessageRoundStart;
        bot.start_round(false, start.info);
    }

    private void tile_assignment(ServerMessage message)
    {
        ServerMessageTileAssignment tile_assignment = (ServerMessageTileAssignment)message;
        bot.tile_assign(tile_assignment.tile);
    }

    private void tile_draw(ServerMessage message)
    {
        bot.tile_draw();
    }

    private void tile_discard(ServerMessage message)
    {
        ServerMessageTileDiscard tile_discard = (ServerMessageTileDiscard)message;
        bot.tile_discard(tile_discard.tile_ID);
    }

    private void ron(ServerMessage message)
    {
        ServerMessageRon ron = (ServerMessageRon)message;
        bot.ron(ron.get_player_indices());
    }

    private void tsumo(ServerMessage message)
    {
        bot.tsumo();
    }

    private void riichi(ServerMessage message)
    {
        ServerMessageRiichi r = (ServerMessageRiichi)message;
        bot.riichi(r.open);
    }

    private void turn_decision(ServerMessage message)
    {
        bot.turn_decision();
    }

    private void call_decision(ServerMessage message)
    {
        bot.call_decision();
    }

    private void late_kan(ServerMessage message)
    {
        ServerMessageLateKan kan = (ServerMessageLateKan)message;
        bot.late_kan(kan.tile_ID);
    }

    private void closed_kan(ServerMessage message)
    {
        ServerMessageClosedKan kan = (ServerMessageClosedKan)message;
        bot.closed_kan(kan.tile_type);
    }

    private void open_kan(ServerMessage message)
    {
        ServerMessageOpenKan kan = (ServerMessageOpenKan)message;
        bot.open_kan(kan.player_index, kan.tile_1_ID, kan.tile_2_ID, kan.tile_3_ID);
    }

    private void pon(ServerMessage message)
    {
        ServerMessagePon pon = (ServerMessagePon)message;
        bot.pon(pon.player_index, pon.tile_1_ID, pon.tile_2_ID);
    }

    private void chii(ServerMessage message)
    {
        ServerMessageChii chii = (ServerMessageChii)message;
        bot.chii(chii.player_index, chii.tile_1_ID, chii.tile_2_ID);
    }

    private void calls_finished(ServerMessage message)
    {
        bot.calls_finished();
    }

    private void draw(ServerMessage message)
    {
        ServerMessageDraw draw = message as ServerMessageDraw;
        bot.draw(draw.get_tenpai_indices(), draw.void_hand, draw.triple_ron);
    }

    /////////////////

    private void send_action(ClientAction action)
    {
        connection.send_message(new ClientMessageGameAction(action));
    }

    private void bot_do_discard(Tile tile)
    {
        send_action(new TileDiscardClientAction(tile.ID));
    }

    private void bot_do_tsumo()
    {
        send_action(new TsumoClientAction());
    }

    private void bot_do_void_hand()
    {
        send_action(new VoidHandClientAction());
    }

    private void bot_do_riichi(bool open)
    {
        send_action(new RiichiClientAction(open));
    }

    private void bot_do_late_kan(Tile tile)
    {
        send_action(new LateKanClientAction(tile.ID));
    }

    private void bot_do_closed_kan(TileType type)
    {
        send_action(new ClosedKanClientAction(type));
    }

    private void bot_call_nothing()
    {
        send_action(new NoCallClientAction());
    }

    private void bot_call_ron()
    {
        send_action(new RonClientAction());
    }

    private void bot_call_open_kan()
    {
        send_action(new OpenKanClientAction());
    }

    private void bot_call_pon()
    {
        send_action(new PonClientAction());
    }

    private void bot_call_chii(Tile tile_1, Tile tile_2)
    {
        send_action(new ChiiClientAction(tile_1.ID, tile_2.ID));
    }
}