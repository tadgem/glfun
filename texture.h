#pragma once
#include <string>
#include "vertex.h"

enum class texture_map_type
{
	diffuse,
	normal,
	specular,

};

class texture
{
public:

	texture() = default;
	texture(const std::string& path);

	int m_width, m_height, m_depth, m_num_channels;

	gl_handle m_handle;

};