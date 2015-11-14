public class Calculations
{
    private Calculations(){}

    public static uint8[] int_to_data(uint32 n)
    {
        // Don't do this, so we maintain consistency over network
        //int bytes = (int)sizeof(int);
        int bytes = 4;

        uint8[] buffer = new uint8[bytes];
        for (int i = 0; i < bytes; i++)
            buffer[i] = (uint8)(n >> ((bytes - i - 1) * 8));
        return buffer;
    }


    public static Vec3 rotate(Vec3 origin, Vec3 rotation, Vec3 offset)
    {
        Vec3 point = offset;
        point = rotate_x(origin, rotation.x, point);
        point = rotate_y(origin, rotation.y, point);
        point = rotate_z(origin, rotation.z, point);
        return point;
    }

    public static Vec3 rotate_x(Vec3 origin, float rotation, Vec3 offset)
    {
        if (rotation == 0)
            return offset;

        float c = (float)Math.cos(rotation * Math.PI);
        float s = (float)Math.sin(rotation * Math.PI);

        Vec3 p = offset.minus(origin);

        p = Vec3
        (
            p.x,
            p.y * c - p.z * s,
            p.y * s + p.z * c
        );

        return p.plus(origin);
    }

    public static Vec3 rotate_y(Vec3 origin, float rotation, Vec3 offset)
    {
        if (rotation == 0)
            return offset;

        float c = (float)Math.cos(rotation * Math.PI);
        float s = (float)Math.sin(rotation * Math.PI);

        Vec3 p = offset.minus(origin);

        p = Vec3
        (
            p.z * s + p.x * c,
            p.y,
            p.z * c - p.x * s
        );

        return p.plus(origin);
    }

    public static Vec3 rotate_z(Vec3 origin, float rotation, Vec3 offset)
    {
        if (rotation == 0)
            return offset;

        float c = (float)Math.cos(rotation * Math.PI);
        float s = (float)Math.sin(rotation * Math.PI);

        Vec3 p = offset.minus(origin);

        p = Vec3
        (
            p.x * c - p.y * s,
            p.x * s + p.y * c,
            p.z
        );

        return p.plus(origin);
    }

    public static Vec3 get_ray(Mat4 projection_matrix, Mat4 view_matrix, Vec2i point, Size2i size)
    {
        float aspect = (float)size.width / size.height;
        float x = -(1 - (float)point.x / size.width  * 2) * aspect;
        float y = -(1 - (float)point.y / size.height * 2) * aspect;

        // TODO: Why is this the unview matrix?
        Mat4 unview_matrix = view_matrix.mul_mat(projection_matrix.inverse());
        Vec4 vec = {x, y, 0, 1};
        Vec4 ray_dir = unview_matrix.mul_vec(vec);

        return Vec3(ray_dir.x, ray_dir.y, ray_dir.z).normalize();
    }

    public static float get_collision_distance(RenderObject3D obj, Vec3 origin, Vec3 ray)
    {
        float x_size = obj.model.size.x / 2 * obj.scale.x;
        float y_size = obj.model.size.y / 2 * obj.scale.y;
        float z_size = obj.model.size.z / 2 * obj.scale.z;

        Vec3 rot = obj.rotation.negate();
        Vec3 xy_dir = rotate(Vec3.empty(), rot, Vec3(0, 0, 1));
        Vec3 xz_dir = rotate(Vec3.empty(), rot, Vec3(0, 1, 0));
        Vec3 yz_dir = rotate(Vec3.empty(), rot, Vec3(1, 0, 0));

        Vec3 xy = xy_dir.mul_scalar(z_size);
        Vec3 xz = xz_dir.mul_scalar(y_size);
        Vec3 yz = yz_dir.mul_scalar(x_size);

        Vec3 xy_pos = obj.position.plus (xy);
        Vec3 xy_neg = obj.position.minus(xy);
        Vec3 xz_pos = obj.position.plus (xz);
        Vec3 xz_neg = obj.position.minus(xz);
        Vec3 yz_pos = obj.position.plus (yz);
        Vec3 yz_neg = obj.position.minus(yz);

        float dist = -1;

        dist = calc_dist(dist, collision_surface_distance(origin, ray, xy_pos, xy_dir, yz_dir, xz_dir, x_size, y_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, xy_neg, xy_dir, yz_dir, xz_dir, x_size, y_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, xz_pos, xz_dir, yz_dir, xy_dir, x_size, z_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, xz_neg, xz_dir, yz_dir, xy_dir, x_size, z_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, yz_pos, yz_dir, xy_dir, xz_dir, z_size, y_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, yz_neg, yz_dir, xy_dir, xz_dir, z_size, y_size));

        return dist;
    }

    private static float calc_dist(float dist, float val)
    {
        if (val >= 0 && (dist < 0 || val < dist))
            dist = val;
        return dist;
    }

    private static float collision_surface_distance(Vec3 line_offset, Vec3 line_direction, Vec3 plane_offset, Vec3 plane_direction, Vec3 ortho1, Vec3 ortho2, float width, float height)
    {
        Vec3 point = collision(line_offset, line_direction, plane_offset, plane_direction);
        if (point.x.is_nan() || point.y.is_nan() || point.z.is_nan())
            return -1;

        Vec3 width_col = proj(point, ortho1, plane_offset);
        float width_dist = plane_offset.dist_sq(width_col);
        if (width * width < width_dist)
            return -1;

        float height_dist = point.dist_sq(width_col);
        if (height * height < height_dist)
            return -1;

        return point.dist_sq(line_offset);
    }

    public static Vec3 collision(Vec3 line_offset, Vec3 line_direction, Vec3 plane_offset, Vec3 plane_direction)
    {
        Vec3 n1 = line_offset;
        Vec3 n2 = line_offset.plus(line_direction);

        Vec3 nv = plane_offset.minus(n1);
        Vec3 dv = n2.minus(n1);

        float n = plane_direction.dot(nv);
        float d = plane_direction.dot(dv);

        if (d == 0)
            return Vec3(float.NAN, float.NAN, float.NAN);

        float u = n / d;

        Vec3 p = n1.plus(dv.mul_scalar(u));
        return p;
    }

    private static Vec3 proj(Vec3 plane_position, Vec3 normal, Vec3 point)
    {
        Vec3 p = plane_position;
        Vec3 n = normal.normalize();
        Vec3 q = point;

        return q.minus(n.mul_scalar(q.minus(p).dot(n)));
    }

    public static Mat4 rotation_matrix(Vec3 axis, float angle)
    {
        axis = axis.normalize();
        float s = (float)Math.sin(angle);
        float c = (float)Math.cos(angle);
        float oc = 1 - c;

        float[] vals =
        {
            oc * axis.x * axis.x + c,          oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,  0,
            oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c,          oc * axis.y * axis.z - axis.x * s,  0,
            oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c,           0,
            0,                                 0,                                 0,                                  1
        };

        return new Mat4.with_array(vals);
    }

    public static Mat4 translation_matrix(Vec3 vec)
    {
        float[] vals =
        {
            1,     0,     0,     0,
            0,     1,     0,     0,
            0,     0,     1,     0,
            vec.x, vec.y, vec.z, 1
        };

        return new Mat4.with_array(vals);
    }

    public static Mat4 scale_matrix(Vec3 vec)
    {
        float[] vals =
        {
            vec.x, 0, 0, 0,
            0, vec.y, 0, 0,
            0, 0, vec.z, 0,
            0, 0,     0, 1
        };

        return new Mat4.with_array(vals);
    }

    public static Mat4 get_model_matrix(Vec3 position, Vec3 rotation, Vec3 scale)
    {
        float pi = (float)Math.PI;
        Mat4 x = rotation_matrix(Vec3(1, 0, 0), pi * rotation.x);
        Mat4 y = rotation_matrix(Vec3(0, 1, 0), pi * rotation.y);

        Vec3 rot = {0, 1, 0};
        rot = rotate_x(Vec3.empty(), -rotation.x, rot);
        rot = rotate_y(Vec3.empty(), -rotation.y, rot);

        Mat4 z = rotation_matrix(rot, pi * rotation.z);
        Mat4 rotate = x.mul_mat(y).mul_mat(z);

        return scale_matrix(scale).mul_mat(rotate).mul_mat(translation_matrix(position));
    }

    public static Mat3 rotation_matrix_3(float angle)
    {
        float s = (float)Math.sin(angle);
        float c = (float)Math.cos(angle);

        //print("S: %f C: %f\n", s, c);

        float[] vals =
        {
             c, s, 0,
            -s, c, 0,
             0, 0, 1
        };

        return new Mat3.with_array(vals);
    }

    public static Mat3 translation_matrix_3(Vec2 vec)
    {
        float[] vals =
        {
            1,     0,     0,
            0,     1,     0,
            vec.x, vec.y, 1
        };

        return new Mat3.with_array(vals);
    }

    public static Mat3 scale_matrix_3(Size2 vec)
    {
        float[] vals =
        {
            vec.width,  0, 0,
            0, vec.height, 0,
            0,          0, 1
        };

        return new Mat3.with_array(vals);
    }

    public static Mat3 get_model_matrix_3(Vec2 position, float rotation, Size2 scale)
    {
        Mat3 rot = rotation_matrix_3(rotation * (float)Math.PI);
        return rot.mul_mat(scale_matrix_3(scale))/*.mul_mat(rot)*/.mul_mat(translation_matrix_3(position));
    }

    public static Vec3 rotation_mod(Vec3 rotation)
    {
        float x = rotation.x % 2;
        float y = rotation.y % 2;
        float z = rotation.z % 2;

        if (x < 0)
            x += 2;
        if (y < 0)
            y += 2;
        if (z < 0)
            z += 2;

        return Vec3(x, y, z);
    }

    public static Vec3 rotation_ease(Vec3 rotation, Vec3 target)
    {
        rotation = rotation_mod(rotation);
        target = rotation_mod(target);

        float x = rotation.x;
        float y = rotation.y;
        float z = rotation.z;

        float dist_x = rotation.x - target.x;
        float dist_y = rotation.y - target.y;
        float dist_z = rotation.z - target.z;

        if (dist_x > 1)
            x -= 2;
        else if (dist_x < -1)
            x += 2;

        if (dist_y > 1)
            y -= 2;
        else if (dist_y < -1)
            y += 2;

        if (dist_z > 1)
            z -= 2;
        else if (dist_z < -1)
            z += 2;

        return Vec3(x, y, z);
    }
}
