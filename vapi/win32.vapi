[CCode (cheader_filename="windows.h", lower_case_cprefix = "")]
namespace Win
{
	uint STD_OUTPUT_HANDLE;
	uint ENABLE_VIRTUAL_TERMINAL_PROCESSING;
	void* GetStdHandle(uint nStdHandle);
	bool GetConsoleMode(void *hConsoleHandle, out uint mode);
	bool SetConsoleMode(void *hConsoleHandle, uint mode);
}