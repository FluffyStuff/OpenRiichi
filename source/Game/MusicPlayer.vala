public class MusicPlayer : Object
{
    private AudioPlayer audio;
    private Music? music = null;
    private string[] files;
    private int index = 0;

    ~MusicPlayer()
    {
        stop();
    }

    public MusicPlayer(AudioPlayer audio)
    {
        this.audio = audio;
    }

    public void start()
    {
        if (music == null)
        {
            files = FileLoader.get_files_in_dir("Data/Audio/Music");
            play_next();
        }
    }

    public void stop()
    {
        if (music != null)
        {
            music.music_finished.disconnect(song_finished);
            music.stop();
            music = null;
        }
    }

    private void play_next()
    {
        if (files.length == 0)
            return;

        music = audio.load_music(files[index]);
        music.music_finished.connect(song_finished);
        music.play();

        index = (index + 1) % files.length;
    }

    private void song_finished()
    {
        music.music_finished.disconnect(song_finished);
        play_next();
    }
}
