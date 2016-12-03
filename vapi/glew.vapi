//[CCode (cheader_filename="GL/glew.h")]
[CCode (cprefix = "GL", gir_namespace = "GLEW", gir_version = "1.0", lower_case_cprefix = "gl_")]
namespace GLEW {
	//[CCode (cname = "glewInit")]
	[CCode (cheader_filename = "GL/glew.h", cname = "glewInit")]
	public bool init();

	[CCode (cheader_filename = "GL/glew.h", cname = "glewExperimental")]
	public static bool experimental;
}
