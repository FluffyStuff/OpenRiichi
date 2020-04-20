[CCode (cheader_filename="search_dir.h", lower_case_cprefix = "")]
namespace Build
{
	const string SEARCH_DIR;
}

#if WINDOWS
[CCode (cheader_filename="windows.h", lower_case_cprefix = "")]
namespace Windows
{
	uint STD_OUTPUT_HANDLE;
	void* GetStdHandle(uint nStdHandle);
	bool GetConsoleMode(void *hConsoleHandle, out uint mode);
	bool SetConsoleMode(void *hConsoleHandle, uint mode);
}
#endif
