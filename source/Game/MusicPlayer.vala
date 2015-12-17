public class MusicPlayer
{
    private AudioPlayer audio;
    private Music music;
    private string[] files;
    private int index = 0;

    public MusicPlayer(AudioPlayer audio)
    {
        this.audio = audio;
    }

    public void start()
    {
        files = FileLoader.get_files_in_dir("Data/Audio/Music");
        Threading.start0(worker);
    }

    private void worker()
    {
        Thread.usleep(3 * 1000 * 1000);

        //while (true)
        {
            play_next();
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
