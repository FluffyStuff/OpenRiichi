using SDLMixer;

public class SDLMusic
{
    private Music music;

    public SDLMusic(int sample_rate)
    {
        open(sample_rate, 0x8010, 2, 1024);
    }

    public void load(string name)
    {
        print("Start loading music.\n");
        music = new Music(name);
        print("Finished loading music.\n");
    }

    public void play(double time)
    {
        music.halt();
        music.fade_in(0, 300, time);
    }

    public void pause() {
        music.halt();
    }
}
