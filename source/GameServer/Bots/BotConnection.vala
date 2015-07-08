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
        parser.tile_assignment.connect(tile_assignment);
        parser.tile_draw.connect(tile_draw);
        parser.tile_discard.connect(tile_discard);
        parser.turn_decision.connect(turn_decision);
        parser.call_decision.connect(call_decision);
        bot.poll.connect(poll);
        bot.discard_tile.connect(bot_discard_tile);
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
            parser.parse(message);
    }

    private void tile_assignment(ServerMessageTileAssignment message)
    {
        bot.tile_assign(message.get_tile());
    }

    private void tile_draw(ServerMessageTileDraw message)
    {
        bot.tile_draw(message.player_ID, message.tile_ID);
    }

    private void tile_discard(ServerMessageTileDiscard message)
    {
        bot.tile_discard(message.player_ID, message.tile_ID);
    }

    private void turn_decision(ServerMessageTurnDecision message)
    {
        bot.turn_decision();
    }

    private void call_decision(ServerMessageCallDecision message)
    {
        bot.call_decision(message.player_ID, message.tile_ID);
    }

    /////////////////

    private void bot_discard_tile(Tile tile)
    {
        ClientMessageTileDiscard message = new ClientMessageTileDiscard(tile.ID);
        connection.send_message(message);
    }
}
