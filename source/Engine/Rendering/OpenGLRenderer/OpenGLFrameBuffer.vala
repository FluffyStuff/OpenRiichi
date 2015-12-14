using GL;

// TODO: Error checking
// TODO: Insert into rendering pipeline
/*class OpenGLFrameBuffer
{
    private uint texture;

    public void init(OpenGLRenderBuffer buffer, int width, int height)
    {
        //glActiveTexture(GL_TEXTURE0);

        uint tex[1];
        glGenTextures(1, tex);
        texture = tex[0];

        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB_ALPHA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
        //glBindTexture(GL_TEXTURE_2D, 0);

        uint buf[1];
        glGenFramebuffers(1, buf);
        handle = buf[0];

        glBindFramebuffer(GL_FRAMEBUFFER, handle);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);

        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, buffer.handle);
        //glBindTexture(GL_TEXTURE_2D, 0);
    }

    public void resize(int width, int height)
    {
        if (this.width == width && this.height == height)
            return;

        this.width = width;
        this.height = height;

        glBindTexture(GL_TEXTURE_2D, texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB_ALPHA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
    }

    public uint handle { get; private set; }
    public int width { get; private set; }
    public int height { get; private set; }
}
*/
