class BotConnection
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
        parser.connect(draw, typeof(ServerMessageDraw));

        bot.poll.connect(poll);
        bot.do_discard.connect(bot_do_discard);
        bot.do_tsumo.connect(bot_do_tsumo);
        bot.do_riichi.connect(bot_do_riichi);
        bot.do_late_kan.connect(bot_late_kan);
        bot.do_closed_kan.connect(bot_closed_kan);
        bot.call_nothing.connect(bot_call_nothing);
        bot.call_ron.connect(bot_ron);
        bot.call_open_kan.connect(bot_open_kan);
        bot.call_pon.connect(bot_pon);
        bot.call_chii.connect(bot_chii);
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
            if (message.get_type() != typeof(ServerMessageRoundStart))
                continue;

            ServerMessageRoundStart start = (ServerMessageRoundStart)message;
            connection.received_message.disconnect(message_received);
            bot.start(start.player_ID, start.get_wind(), start.dealer);
            break;
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
        ServerMessageRoundStart start = (ServerMessageRoundStart)message;
        connection.received_message.disconnect(message_received);
        bot.reset(start.player_ID, start.get_wind(), start.dealer);
    }

    private void tile_assignment(ServerMessage message)
    {
        ServerMessageTileAssignment tile_assignment = (ServerMessageTileAssignment)message;
        bot.tile_assign(tile_assignment.get_tile());
    }

    private void tile_draw(ServerMessage message)
    {
        ServerMessageTileDraw tile_draw = (ServerMessageTileDraw)message;
        bot.tile_draw(tile_draw.player_ID, tile_draw.tile_ID);
    }

    private void tile_discard(ServerMessage message)
    {
        ServerMessageTileDiscard tile_discard = (ServerMessageTileDiscard)message;
        bot.tile_discard(tile_discard.player_ID, tile_discard.tile_ID);
    }

    private void ron(ServerMessage message)
    {
        ServerMessageRon ron = (ServerMessageRon)message;
        bot.ron(ron.player_ID, ron.discard_player_ID, ron.tile_ID);
    }

    private void tsumo(ServerMessage message)
    {
        ServerMessageTsumo tsumo = (ServerMessageTsumo)message;
        bot.tsumo(tsumo.player_ID);
    }

    private void riichi(ServerMessage message)
    {
        ServerMessageRiichi riichi = (ServerMessageRiichi)message;
        bot.riichi(riichi.player_ID);
    }

    private void turn_decision(ServerMessage message)
    {
        bot.turn_decision();
    }

    private void call_decision(ServerMessage message)
    {
        ServerMessageCallDecision call_decision = (ServerMessageCallDecision)message;
        bot.call_decision(call_decision.player_ID, call_decision.tile_ID);
    }

    private void late_kan(ServerMessage message)
    {
        ServerMessageLateKan kan = (ServerMessageLateKan)message;
        bot.late_kan(kan.player_ID, kan.tile_ID);
    }

    private void closed_kan(ServerMessage message)
    {
        ServerMessageClosedKan kan = (ServerMessageClosedKan)message;
        bot.closed_kan(kan.player_ID, kan.get_type_enum());
    }

    private void open_kan(ServerMessage message)
    {
        ServerMessageOpenKan kan = (ServerMessageOpenKan)message;
        bot.open_kan(kan.player_ID, kan.discard_player_ID, kan.tile_ID, kan.tile_1_ID, kan.tile_2_ID, kan.tile_3_ID);
    }

    private void pon(ServerMessage message)
    {
        ServerMessagePon pon = (ServerMessagePon)message;
        bot.pon(pon.player_ID, pon.discard_player_ID, pon.tile_ID, pon.tile_1_ID, pon.tile_2_ID);
    }

    private void chii(ServerMessage message)
    {
        ServerMessageChii chii = (ServerMessageChii)message;
        bot.chii(chii.player_ID, chii.discard_player_ID, chii.tile_ID, chii.tile_1_ID, chii.tile_2_ID);
    }

    private void draw(ServerMessage message)
    {
        bot.draw();
    }

    /////////////////

    private void bot_do_discard(Tile tile)
    {
        ClientMessageTileDiscard message = new ClientMessageTileDiscard(tile.ID);
        connection.send_message(message);
    }

    private void bot_do_tsumo()
    {
        ClientMessageTsumo message = new ClientMessageTsumo();
        connection.send_message(message);
    }

    private void bot_do_riichi()
    {
        ClientMessageRiichi message = new ClientMessageRiichi();
        connection.send_message(message);
    }

    private void bot_late_kan(Tile tile)
    {
        ClientMessageLateKan message = new ClientMessageLateKan(tile.ID);
        connection.send_message(message);
    }

    private void bot_closed_kan(TileType type)
    {
        ClientMessageClosedKan message = new ClientMessageClosedKan(type);
        connection.send_message(message);
    }

    private void bot_call_nothing()
    {
        ClientMessageNoCall message = new ClientMessageNoCall();
        connection.send_message(message);
    }

    private void bot_ron()
    {
        ClientMessageRon message = new ClientMessageRon();
        connection.send_message(message);
    }

    private void bot_open_kan()
    {
        ClientMessageOpenKan message = new ClientMessageOpenKan();
        connection.send_message(message);
    }

    private void bot_pon()
    {
        ClientMessagePon message = new ClientMessagePon();
        connection.send_message(message);
    }

    private void bot_chii(Tile tile_1, Tile tile_2)
    {
        ClientMessageChii message = new ClientMessageChii(tile_1.ID, tile_2.ID);
        connection.send_message(message);
    }
}
