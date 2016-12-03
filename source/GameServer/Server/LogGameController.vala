using Gee;

namespace GameServer
{
    public class LogGameController
    {
        private const int ROUND_DELAY = 2;

        private GameLog log;
        private bool log_finished = false;
        private int round_index;
        private int line_index;

        private GameLogRound? current_round;
        private GameLogLine? current_line;
        private TimeStamp? start_time;
        private TimeStamp? next_time;
        private float start_seconds = -1;

        public LogGameController(GameLog log)
        {
            this.log = log;
            players = new ArrayList<ServerPlayer>();
            source = new LogServerGameRoundInfoSource(log);

            for (int i = 0; i < 4; i++)
            {
                ServerLogPlayer player = new ServerLogPlayer(i.to_string());
                players.add(player);
            }

            current_round = get_current_round(log, round_index);
            current_line = get_current_line(current_round, line_index);
            start_time = next_time = get_current_logtime(current_line);

            if (start_time != null)
                start_time = start_time.plus_seconds(-ROUND_DELAY);
        }

        public void process(float time)
        {
            if (log_finished || start_time == null || next_time == null || current_line == null)
                return;

            if (start_seconds == -1)
                start_seconds = time;

            float seconds = start_time.minus(next_time).seconds + (time - start_seconds);

            //Environment.log(LogType.DEBUG, "LogGameController", "Seconds: " + seconds.to_string());

            if (seconds < 0)
                return;

            make_move();

            current_line = get_current_line(current_round, ++line_index);
            if (current_line == null)
            {
                current_round = get_current_round(log, ++round_index);
                source.round = round_index;

                line_index = 0;
                current_line = get_current_line(current_round, line_index);

                if (start_time != null)
                    start_time = start_time.plus_seconds(-ROUND_DELAY);
            }
            next_time = get_current_logtime(current_line);

            if (current_round == null)
                log_finished = true;
        }

        private void make_move()
        {
            ClientPlayerMessage? message = log_line_to_client_message(current_line);
            if (message != null)
            {
                ServerPlayer player = players[message.client];
                player.receive_message(player, message.message);

                //Environment.log(LogType.DEBUG, "LogGameController", "Move player: " + message.client.to_string());
            }
        }

        private static GameLogRound? get_current_round(GameLog log, int round)
        {
            var rounds = log.rounds.to_array();
            return rounds.length <= round ? null : rounds[round];
        }

        private static GameLogLine? get_current_line(GameLogRound? round, int line)
        {
            if (round == null)
                return null;

            var lines = round.lines.to_array();
            return lines.length <= line ? null : lines[line];
        }

        private static TimeStamp? get_current_logtime(GameLogLine? line)
        {
            return line == null ? null : line.timestamp;
        }

        private static ClientPlayerMessage? log_line_to_client_message(GameLogLine line)
        {
            if (line is DefaultTileDiscardGameLogLine)
            {
                DefaultTileDiscardGameLogLine l = (DefaultTileDiscardGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageControlDefaultTileAction(l.tile));
            }
            else if (line is DefaultCallActionGameLogLine)
            {
                return new ClientPlayerMessage(-1, new ClientMessageControlDefaultCallAction());
            }
            else if (line is ClientTileDiscardGameLogLine)
            {
                ClientTileDiscardGameLogLine l = (ClientTileDiscardGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageTileDiscard(l.tile));
            }
            else if (line is ClientNoCallGameLogLine)
            {
                ClientNoCallGameLogLine l = (ClientNoCallGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageNoCall());
            }
            else if (line is ClientRonGameLogLine)
            {
                ClientRonGameLogLine l = (ClientRonGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageRon());
            }
            else if (line is ClientTsumoGameLogLine)
            {
                ClientTsumoGameLogLine l = (ClientTsumoGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageTsumo());
            }
            else if (line is ClientVoidHandGameLogLine)
            {
                ClientVoidHandGameLogLine l = (ClientVoidHandGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageVoidHand());
            }
            else if (line is ClientRiichiGameLogLine)
            {
                ClientRiichiGameLogLine l = (ClientRiichiGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageRiichi(l.open));
            }
            else if (line is ClientLateKanGameLogLine)
            {
                ClientLateKanGameLogLine l = (ClientLateKanGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageLateKan(l.tile));
            }
            else if (line is ClientClosedKanGameLogLine)
            {
                ClientClosedKanGameLogLine l = (ClientClosedKanGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageClosedKan(l.tile_type));
            }
            else if (line is ClientOpenKanGameLogLine)
            {
                ClientOpenKanGameLogLine l = (ClientOpenKanGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageOpenKan());
            }
            else if (line is ClientPonGameLogLine)
            {
                ClientPonGameLogLine l = (ClientPonGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessagePon());
            }
            else if (line is ClientChiiGameLogLine)
            {
                ClientChiiGameLogLine l = (ClientChiiGameLogLine)line;
                return new ClientPlayerMessage(l.client, new ClientMessageChii(l.tile_1, l.tile_2));
            }

            return null;
        }

        public ArrayList<ServerPlayer> players { get; private set; }
        public ServerSettings settings { get { return log.settings; } }
        public GameStartInfo start_info { get { return log.start_info; } }
        public LogServerGameRoundInfoSource source { get; private set; }
    }

    public class ServerLogPlayer : ServerPlayer
    {
        public ServerLogPlayer(string name)
        {
            base(name, false);

            ready = true;
            state = State.PLAYER;
        }

        public override void close()
        {
            // Nothing
        }
    }

    public class LogServerGameRoundInfoSource : ServerGameRoundInfoSource
    {
        private GameLog log;

        public LogServerGameRoundInfoSource(GameLog log)
        {
            this.log = log;
            round = 0;
        }

        public override ServerGameRoundInfoSourceRound get_round()
        {
            GameLogRound[] rounds = log.rounds.to_array();
            if (this.round >= rounds.length)
                return new ServerGameRoundInfoSourceRound(new RoundStartInfo(2), null);

            GameLogRound round = rounds[this.round];

            return new ServerGameRoundInfoSourceRound(round.start_info, round.tiles.to_array());
        }

        public int round { get; set; }
    }

    public class ClientPlayerMessage
    {
        public ClientPlayerMessage(int client, ClientMessage message)
        {
            this.client = client;
            this.message = message;
        }

        public int client { get; private set; }
        public ClientMessage message { get; private set; }
    }
}
