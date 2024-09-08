#version 430 core

layout(local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

struct AABB
{
	vec3 min;
	vec3 max;
};

uniform sampler2D u_gbuffer_pos;
uniform sampler2D u_gbuffer_lighting;
uniform AABB	  u_aabb;
uniform vec3	  u_voxel_resolution;
const int div = 1;
layout(binding = 0, rgba32f) uniform image3D imgOutput;

bool is_in_aabb(vec3 pos)
{
	if (pos.x < u_aabb.min.x) { return false; }
	if (pos.y < u_aabb.min.y) { return false; }
	if (pos.z < u_aabb.min.z) { return false; }

	if (pos.x > u_aabb.max.x) { return false; }
	if (pos.y > u_aabb.max.y) { return false; }
	if (pos.z > u_aabb.max.z) { return false; }

	return true;
}

ivec3 get_texel_from_pos(vec3 position)
{
	vec3 aabb_dim = u_aabb.max - u_aabb.min;
	vec3 unit = vec3((aabb_dim.x / u_voxel_resolution.x), (aabb_dim.y / u_voxel_resolution.y) , (aabb_dim.z / u_voxel_resolution.z));

	/// <summary>
	/// 0,0,0 is aabb.min
	/// </summary>
	vec3 new_pos = position - u_aabb.min;
	int x = int(new_pos.x / unit.x) ;
	int y = int(new_pos.y / unit.y) ;
	int z = int(new_pos.z / unit.z) ;

	return ivec3(x, y, z);

}

void main() {
	ivec2 pix = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(1280, 720);
	if (pix.x >= size.x || pix.y >= size.y) {
		return;
	}
	vec2 uv = vec2(pix) / size;
	vec3 pos = texture(u_gbuffer_pos, uv).xyz;

	// is the pixel position within the bounding volume, if not do nothing
	if (!is_in_aabb(pos))
	{
		return;
	}

	// if the pixel is in volume, map position to from aabb to 3d texture
	// store pixel light value at this voxel

	vec4 light = texture(u_gbuffer_lighting, uv);
	light.w = 1.0f;

	ivec3 sample_pos = get_texel_from_pos(pos.xyz);
	vec4 current = imageLoad(imgOutput, sample_pos);
	imageStore(imgOutput,sample_pos, mix(light, current, 0.5));
}