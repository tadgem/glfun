#pragma once
#include <string>
#include "vertex.h"
#include "glm.hpp"

enum class texture_map_type
{
	diffuse,
	normal,
	specular,
	metallicness,
	roughness,
	ao

};

class texture
{
public:

	texture() = default;
	texture(const std::string& path);

	void bind(GLenum texture_slot, GLenum texture_target = GL_TEXTURE_2D);
	static void bind_handle(gl_handle handle, GLenum texture_slot, GLenum texture_target = GL_TEXTURE_2D);

	int m_width, m_height, m_depth, m_num_channels;

	gl_handle m_handle;
	
	static texture from_data(unsigned int* data, unsigned int count, int width, int height, int depth, int nr_channels);
	static texture create_3d_texture(glm::ivec3 dim, GLenum format, GLenum pixel_format, GLenum data_type, void* data, GLenum filter = GL_LINEAR, GLenum wrap_mode = GL_REPEAT);
	static texture create_3d_texture_empty(glm::ivec3 dim, GLenum format, GLenum pixel_format, GLenum data_type, GLenum filter = GL_LINEAR, GLenum wrap_mode = GL_REPEAT);

	inline static texture* white;
	inline static texture* black;
};