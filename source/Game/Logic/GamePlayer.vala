public class GamePlayer : Serializable
{
    public GamePlayer(int ID, string name)
    {
        this.ID = ID;
        this.name = name;
    }

    public int ID { get; protected set; }
    public string name { get; protected set; }
}
