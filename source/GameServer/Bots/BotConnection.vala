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
        parser.connect(tile_assignment, typeof(ServerMessageTileAssignment));
        parser.connect(tile_draw, typeof(ServerMessageTileDraw));
        parser.connect(tile_discard, typeof(ServerMessageTileDiscard));
        parser.connect(turn_decision, typeof(ServerMessageTurnDecision));
        parser.connect(call_decision, typeof(ServerMessageCallDecision));
        parser.connect(late_kan, typeof(ServerMessageLateKan));
        parser.connect(closed_kan, typeof(ServerMessageClosedKan));
        parser.connect(open_kan, typeof(ServerMessageOpenKan));
        parser.connect(pon, typeof(ServerMessagePon));
        parser.connect(chi, typeof(ServerMessageChi));
        bot.poll.connect(poll);
        bot.discard_tile.connect(bot_discard_tile);
        bot.do_late_kan.connect(bot_late_kan);
        bot.do_closed_kan.connect(bot_closed_kan);
        bot.no_call.connect(bot_no_call);
        bot.call_ron.connect(bot_ron);
        bot.call_open_kan.connect(bot_open_kan);
        bot.call_pon.connect(bot_pon);
        bot.call_chi.connect(bot_chi);
    }

    ~BotConnection()
    {
        connection.received_message.disconnect(message_received);
        parser.disconnect();
        bot.poll.disconnect(poll);
        bot.discard_tile.disconnect(bot_discard_tile);
        bot.do_late_kan.disconnect(bot_late_kan);
        bot.do_closed_kan.disconnect(bot_closed_kan);
        bot.no_call.disconnect(bot_no_call);
        bot.call_ron.disconnect(bot_ron);
        bot.call_open_kan.disconnect(bot_open_kan);
        bot.call_pon.disconnect(bot_pon);
        bot.call_chi.disconnect(bot_chi);

        stop();
    }

    public void stop()
    {
        bot.stop();
    }

    private void message_received()
    {
        ServerMessage? message;

        while ((message = connection.dequeue_message()) != null)
        {
            if (message.get_type() != typeof(ServerMessageGameStart))
                continue;

            ServerMessageGameStart start = (ServerMessageGameStart)message;
            connection.received_message.disconnect(message_received);
            bot.start(start.player_ID);
            break;
        }
    }

    private void poll()
    {
        ServerMessage? message;
        while ((message = connection.dequeue_message()) != null)
            parser.execute(message);
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

    private void chi(ServerMessage message)
    {
        ServerMessageChi chi = (ServerMessageChi)message;
        bot.chi(chi.player_ID, chi.discard_player_ID, chi.tile_ID, chi.tile_1_ID, chi.tile_2_ID);
    }

    /////////////////

    private void bot_discard_tile(Tile tile)
    {
        ClientMessageTileDiscard message = new ClientMessageTileDiscard(tile.ID);
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

    private void bot_no_call()
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

    private void bot_chi(Tile tile_1, Tile tile_2)
    {
        ClientMessageChi message = new ClientMessageChi(tile_1.ID, tile_2.ID);
        connection.send_message(message);
    }
}
