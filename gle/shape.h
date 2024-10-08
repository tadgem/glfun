#pragma once
#include "glm.hpp"
#include "vertex.h"

struct aabb
{
	glm::vec3 min;
	glm::vec3 max;
};

class shapes
{
public:



	inline static VAO s_screen_quad;
	inline static VAO s_cube_pos_only;

	static VAO gen_cube_instanced_vao(std::vector<glm::mat4>& matrices, std::vector<glm::vec3>& uvs);
};