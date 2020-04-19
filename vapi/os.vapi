[CCode (cheader_filename="working_dir.h", lower_case_cprefix = "")]
namespace Build
{
	const string WORKING_DIR;
}

[CCode (cheader_filename="windows.h", lower_case_cprefix = "")]
namespace Windows
{
	uint STD_OUTPUT_HANDLE;
	void* GetStdHandle(uint nStdHandle);
	bool GetConsoleMode(void *hConsoleHandle, out uint mode);
	bool SetConsoleMode(void *hConsoleHandle, uint mode);
}

[CCode (lower_case_cprefix = "")]
namespace macOS
{
	const int PATH_MAX;
	void* CFBundleGetMainBundle();
	void* CFBundleCopyResourcesDirectoryURL(void *bundle);
	bool CFURLGetFileSystemRepresentation(void *url, bool b, uint8 *path, int max_path);
	void CFRelease(void *url);
}