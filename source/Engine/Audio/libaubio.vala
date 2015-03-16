using Aubio;
using Gee;

public class libaubio
{
    public static float[] load(string file, out float[] samples)
    {
        int buffer_size = 512;
        int hop_size = 512;
        uint filters = 40;
        uint coefs = 27;
        uint samplerate = 44100;

        CVector fftgrain = new CVector(buffer_size);
        PVoc pv = new PVoc(buffer_size, hop_size);
        FFT fft = new FFT(512);
        MFCC mfcc = new MFCC(buffer_size, filters, coefs, samplerate);
        FVector mfcc_out = new FVector(coefs);

        Aubio.Source source = new Aubio.Source(file, samplerate, hop_size);
        FVector ibuf = new FVector(hop_size);

        uint total_read = 0;
        uint read = 0;

        print("Start reading.\n");
        ArrayList<float?> list = new ArrayList<float?>();
        //ArrayList<float?> samp = new ArrayList<float?>();
        float[] samp = new float[38528 * 512];
        print("Samp len: " + samp.length.to_string() + "\n");
        int a = 0;

        do
        {
            source.do(ibuf, ref read);
            for (int i = 0; i < 512; i++)
                samp[a*512 + i] = ibuf.get_sample(i);

            total_read += read;

            fft.do(ibuf, fftgrain);
            //pv.do(ibuf, fftgrain);
            //mfcc.do(fftgrain, mfcc_out);

            uint smp = 50;

            for (int i = 0; i < 512; i++)
                list.add(fftgrain.norm_get_sample(i) * (float)Math.cos(fftgrain.phase_get_sample(i)));
            //float val = mfcc_out.get_sample(6);
            //list[a] = val;
            //ibuf.print();

            //print("Ibuf: " + ibuf.length.to_string() + "\n");
            //print("Norm: " + (fftgrain.norm_get_sample(0) * (float)Math.cos(fftgrain.phase_get_sample(0))).to_string() + "\n");
            //print("Phas: " + fftgrain.phase_get_sample(0).to_string() + "\n");

            //print("Read: " + read.to_string() + "\n");
            a++;
        }
        while (read == hop_size);

        print("Read " + a.to_string() + " samples.\n");

        samples = samp;
        return list.to_array();
    }
}
