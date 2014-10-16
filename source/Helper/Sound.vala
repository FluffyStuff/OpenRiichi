using SDLMixer;
using Gee;

// TODO: Do we really want a static class?
public class Sound
{
#if DEBUG
    private const bool SOUND_ENABLED = false;
#else
    private const bool SOUND_ENABLED = true;
#endif

    private static bool initialized = false;
    private static ArrayList<Sound> list = new ArrayList<Sound>();

    public static bool init()
    {
        if (initialized)
            return true;

        bool success = SDLMixer.open(44100/*22050*/, 0x8010, 2, 1024) <= 0;
        if (success)
            initialized = true;
        return success;
    }

    public static void quit()
    {
        if (initialized)
        {
            SDLMixer.close();
            initialized = false;
        }
    }

    public static Sound load_sound(string n)
    {
        string name = "sounds/" + n + ".wav";
        Sound sound = new Sound(name);
        list.add(sound);
        return sound;
    }

    public static void play_sound(string name)
    {
        Sound sound = load_sound(name);

        if (SOUND_ENABLED)
            Channel.play_channel(DEFAULT_CHANNEL, sound.chunk, 0);
            //sound.music.play(0);
    }

    public Music _music;
    public Chunk _chunk;

    // We need this as a wrapper class for music
    private Sound(string name)
    {
        //_music = new Music(name);
        _chunk = new Chunk.WAV(name);
    }

    public Music music { get { return _music; } }
    public Chunk chunk { get { return _chunk; } }
}
