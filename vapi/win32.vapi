[CCode (cheader_filename="windows.h", lower_case_cprefix = "")]
namespace Win
{
	extern const uint STD_OUTPUT_HANDLE;
	static uint ENABLE_VIRTUAL_TERMINAL_PROCESSING() { return 0x0004; }

	[CCode (cheader_filename = "windows.h")]
	static extern void* GetStdHandle(uint nStdHandle);
	
	[CCode (cheader_filename = "windows.h")]
	static extern bool GetConsoleMode(void *hConsoleHandle, out uint mode);
	
	[CCode (cheader_filename = "windows.h")]
	static extern bool SetConsoleMode(void *hConsoleHandle, uint mode);
}