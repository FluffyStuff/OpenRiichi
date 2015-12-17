using Gee;

public class AudioPlayer
{
    private ArrayList<Sound> sounds = new ArrayList<Sound>();

    public Sound load_sound(string name)
    {
        foreach (Sound sound in sounds)
            if (sound.name == name)
                return sound;

        Sound sound = new Sound("Data/Audio/Sounds/" + name + ".wav");
        sounds.add(sound);

        return sound;
    }

    public Music load_music(string name)
    {
        return new Music("Data/Audio/Music/" + name);
    }
}

public class Sound
{
    private SDLMixer.Chunk chunk;

    public Sound(string name)
    {
        this.name = name;
        chunk = new SDLMixer.Chunk.WAV(name);
    }

    public void play()
    {
        SDLMixer.Channel.play_channel(SDLMixer.DEFAULT_CHANNEL, chunk, 0);
    }

    public string name { get; private set; }
}

public class Music
{
    private static Music callback_music;

    private SDLMixer.Music music;

    public signal void music_finished(Music music);

    public Music(string name)
    {
        music = new SDLMixer.Music(name);
    }

    public void play()
    {
        callback_music = this;
        SDLMixer.Music.hook_finished((void*)finished);
        music.fade_in(1, 100);
    }

    public void stop()
    {
        SDLMixer.Music.halt();
    }

    private static void finished()
    {
        SDLMixer.Music.hook_finished(null);
        callback_music.music_finished(callback_music);
    }
}
