[CCode (lower_case_prefix = "aubio_", cheader_filename = "aubio/aubio.h")]
namespace Aubio
{
	[Compact]
	[CCode (cname="cvec_t", free_function="del_cvec"/*, cheader_filename="aubio/cvec.h"*/)]
	public class CVector
	{
		[CCode (cname = "length")]
		private int _length;
		
		[CCode (cname="new_cvec")]
		public CVector(uint length);
		
		[CCode (cname = "cvec_phas_get_sample")]
		public float phase_get_sample(uint position);
		
		[CCode (cname = "cvec_norm_get_sample")]
		public float norm_get_sample(uint position);
		
		public int length { get { return (_length - 1) / 2; } }
	}
	
	[Compact]
	[CCode (cname="fvec_t", free_function="del_fvec")]
	public class FVector
	{
		[CCode (cname = "length")]
		private int _length;
		
		[CCode (cname="new_fvec")]
		public FVector(uint length);
		[CCode (cname = "fvec_print")]
		public void print();
		[CCode (cname = "fvec_get_sample")]
		public float get_sample(uint position);
		
		public int length { get { return _length; } }
	}
	
	[Compact]
	[CCode (/*type_id="aubio_pvoc_t", */cname="aubio_pvoc_t", free_function="del_aubio_pvoc"/*, cheader_filename="aubio/spectral/phasevoc.h"*/)]
	public class PVoc
	{
		[CCode (cname="new_aubio_pvoc")]
		public PVoc(int window_size, int hop_size);
		public void do(FVector in, CVector fftgrain);
	}
	
	[Compact]
	[CCode (cname="aubio_mfcc_t", free_function="del_aubio_mfcc")]
	public class MFCC
	{
		[CCode (cname="new_aubio_mfcc")]
		public MFCC(uint buf_size, uint filters, uint coeffs, uint samplerate);
		public void do(CVector in, FVector out);
	}
	
	[Compact]
	[CCode (cname="aubio_fft_t", free_function="del_aubio_fft")]
	public class FFT
	{
		[CCode (cname="new_aubio_fft")]
		public FFT(uint window_size);
		public void do(FVector in, CVector out);
	}
	
	[Compact]
	[CCode (cname="aubio_source_t", free_function="del_aubio_source")]
	public class Source
	{
		[CCode (cname="new_aubio_source")]
		public Source(string file, uint samplerate, uint hop_size);
		public void do(FVector in, ref uint read);
	}
	
	[Compact]
	[CCode (cname="aubio_tempo_t", free_function="del_aubio_tempo")]
	public class Tempo
	{
		[CCode (cname = "new_aubio_tempo")]
		public Tempo(string method, uint buf_size, uint hop_size, uint sample_rate);
		public void do(FVector in, FVector out);
		public void set_silence(float silence);
		public void set_threshold(float threshold);
		public float get_bpm();
	}
}