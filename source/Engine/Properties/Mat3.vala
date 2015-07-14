public class Mat3
{
    private Vec3 v1;
    private Vec3 v2;
    private Vec3 v3;

    public Mat3()
    {
        with_vecs
        (
            { 1, 0, 0 },
            { 0, 1, 0 },
            { 0, 0, 1 }
        );
    }

    public Mat3.with_array(float *a)
    {
        v1 = { a[0], a[1], a[2] };
        v2 = { a[3], a[4], a[5] };
        v3 = { a[6], a[7], a[8] };
    }

    public Mat3.with_vecs(Vec3 v1, Vec3 v2, Vec3 v3)
    {
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
    }

    /*public Mat3? inverse()
    {
        float mat[9], inv[9];

        Vec3 *v = (Vec3*)mat;
        v[0] = v1;
        v[1] = v2;
        v[2] = v3;

        return invert_matrix(mat, inv) ? new Mat3.with_array(inv) : null;
    }*/

    public Mat3 transpose()
    {
        Vec3 v1 = this.col(0);
        Vec3 v2 = this.col(1);
        Vec3 v3 = this.col(2);

        return new Mat3.with_vecs(v1, v2, v3);
    }

    public Mat3 copy()
    {
        Vec3 v1 = this.v1;
        Vec3 v2 = this.v2;
        Vec3 v3 = this.v3;

        return new Mat3.with_vecs(v1, v2, v3);
    }

    // this*mat
    public Mat3 mul_mat(Mat3 mat)
    {
        Vec3 vec1 =
        {
            v1.dot(mat.col(0)),
            v1.dot(mat.col(1)),
            v1.dot(mat.col(2))
        };

        Vec3 vec2 =
        {
            v2.dot(mat.col(0)),
            v2.dot(mat.col(1)),
            v2.dot(mat.col(2))
        };

        Vec3 vec3 =
        {
            v3.dot(mat.col(0)),
            v3.dot(mat.col(1)),
            v3.dot(mat.col(2))
        };

        return new Mat3.with_vecs(vec1, vec2, vec3);
    }

    public Vec3 mul_vec(Vec3 vec)
    {
        return
        {
            v1.dot(vec),
            v2.dot(vec),
            v3.dot(vec)
        };
    }

    public Vec3 col(int c)
    {
        return
        {
            ((float*)(&v1))[c],
            ((float*)(&v2))[c],
            ((float*)(&v3))[c]
        };
    }

    public float[] get_data()
    {
        float[] mat = new float[9];
        Vec3 *v = (Vec3*)mat;
        v[0] = v1;
        v[1] = v2;
        v[2] = v3;

        return mat;
    }
}
