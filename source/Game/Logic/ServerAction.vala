using Engine;

public abstract class ServerAction : Serializable {}

public class ClientServerAction : ServerAction
{
	public ClientServerAction(int client, ClientAction action)
	{
		this.client = client;
		this.action = action;
	}

	public int client { get; protected set; }
	public ClientAction action { get; protected set; }
}

public class DefaultDiscardServerAction : ServerAction
{
	public DefaultDiscardServerAction(int client, int tile)
	{
		this.client = client;
		this.tile = tile;
	}

	public int client { get; protected set; }
	public int tile { get; protected set; }
}

public class DefaultNoCallServerAction : ServerAction {}