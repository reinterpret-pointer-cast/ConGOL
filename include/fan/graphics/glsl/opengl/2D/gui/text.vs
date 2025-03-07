R"(
#version 130

in vec4 input0;
in vec4 input1;
in vec4 input2;
in vec4 input3;
in vec4 input4;
in vec2 input5;

out vec4 color;

uniform mat4 projection;
uniform mat4 view;

mat4 translate(mat4 m, vec3 v) {
	mat4 matrix = m;

//	v = vec3(v.x, -v.y, v.z);

	matrix[3][0] = m[0][0] * v[0] + m[1][0] * v[1] + m[2][0] * v[2] + m[3][0];
	matrix[3][1] = m[0][1] * v[0] + m[1][1] * v[1] + m[2][1] * v[2] + m[3][1];
	matrix[3][2] = m[0][2] * v[0] + m[1][2] * v[1] + m[2][2] * v[2] + m[3][2];
	matrix[3][3] = m[0][3] * v[0] + m[1][3] * v[1] + m[2][3] * v[2] + m[3][3];

	return matrix;
}

mat4 scale(mat4 m, vec3 v) {
	mat4 matrix = mat4(1);

	matrix[0][0] = m[0][0] * v[0];
	matrix[0][1] = m[0][1] * v[0];
	matrix[0][2] = m[0][2] * v[0];

	matrix[1][0] = m[1][0] * v[1];
	matrix[1][1] = m[1][1] * v[1];
	matrix[1][2] = m[1][2] * v[1];

	matrix[2][0] = m[2][0] * v[2];
	matrix[2][1] = m[2][1] * v[2];
	matrix[2][2] = m[2][2] * v[2];

	matrix[3][0] = m[3][0];
	matrix[3][1] = m[3][1];
	matrix[3][2] = m[3][2];

	matrix[3] = m[3];

	return matrix;
}

mat4 rotate(mat4 m, float angle, vec3 v) {
	float a = angle;
	float c = cos(a);
	float s = sin(a);
	vec3 axis = vec3(normalize(v));
	vec3 temp = vec3(axis * (1.0f - c));

	mat4 rotation;
	rotation[0][0] = c + temp[0] * axis[0];
	rotation[0][1] = temp[0] * axis[1] + s * axis[2];
	rotation[0][2] = temp[0] * axis[2] - s * axis[1];

	rotation[1][0] = temp[1] * axis[0] - s * axis[2];
	rotation[1][1] = c + temp[1] * axis[1];
	rotation[1][2] = temp[1] * axis[2] + s * axis[0];

	rotation[2][0] = temp[2] * axis[0] + s * axis[1];
	rotation[2][1] = temp[2] * axis[1] - s * axis[0];
	rotation[2][2] = c + temp[2] * axis[2];

	mat4 matrix;
	matrix[0][0] = (m[0][0] * rotation[0][0]) + (m[1][0] * rotation[0][1]) + (m[2][0] * rotation[0][2]);
	matrix[1][0] = (m[0][1] * rotation[0][0]) + (m[1][1] * rotation[0][1]) + (m[2][1] * rotation[0][2]);
	matrix[2][0] = (m[0][2] * rotation[0][0]) + (m[1][2] * rotation[0][1]) + (m[2][2] * rotation[0][2]);

	matrix[0][1] = (m[0][0] * rotation[1][0]) + (m[1][0] * rotation[1][1]) + (m[2][0] * rotation[1][2]);
	matrix[1][1] = (m[0][1] * rotation[1][0]) + (m[1][1] * rotation[1][1]) + (m[2][1] * rotation[1][2]);
	matrix[2][1] = (m[0][2] * rotation[1][0]) + (m[1][2] * rotation[1][1]) + (m[2][2] * rotation[1][2]);

	matrix[0][2] = (m[0][0] * rotation[2][0]) + (m[1][0] * rotation[2][1]) + (m[2][0] * rotation[2][2]);
	matrix[1][2] = (m[0][1] * rotation[2][0]) + (m[1][1] * rotation[2][1]) + (m[2][1] * rotation[2][2]);
	matrix[2][2] = (m[0][2] * rotation[2][0]) + (m[1][2] * rotation[2][1]) + (m[2][2] * rotation[2][2]);

	matrix[3] = m[3];

	return matrix;
}

vec2 rectangle_vertices[] = vec2[](
	vec2(-1.0, -1.0),
	vec2(1.0, -1.0),
	vec2(1.0, 1.0),

	vec2(1.0, 1.0),
	vec2(-1.0, 1.0),
	vec2(-1.0, -1.0)
);

out vec2 texture_coordinate;
out float font_size;
out vec4 text_color;
out vec4 outline_color;
out float outline_size;

void main() {

	vec4 layout_color = vec4(input0[0], input0[1], input0[2], input0[3]);
	vec2 layout_position = vec2(input1[0], input1[1]);
	vec2 layout_size = vec2(input1[2], input1[3]);
	float layout_angle = input2[0];
	vec2 layout_rotation_point = vec2(input2[1], input2[2]);
	vec3 layout_rotation_vector = vec3(input2[3], input3[0], input3[1]);
	vec2 layout_texture_coordinates = vec2(input3[2], input3[3]);
	float layout_font_size = float(input4[0]);
	vec4 layout_outline_color = vec4(input4[1], input4[2], input4[3], input5[0]);
	float layout_outline_size = float(input5[1]);

	mat4 m = mat4(1);

	float angle = -layout_angle;

	mat2 m2 = mat2(1);

	m2[0] = vec2(cos(angle), sin(angle));
	m2[1] = vec2(-sin(angle), cos(angle));

	vec2 middle = layout_rotation_point + m2 * (layout_position - layout_rotation_point);

	m = rotate(m, -angle, vec3(0, 0, 1));

	m[3][0] = middle.x;
	m[3][1] = middle.y;

  m = scale(m, vec3(layout_size.x, layout_size.y, 0));

  gl_Position = projection * view * m * vec4(rectangle_vertices[gl_VertexID % 6].x, rectangle_vertices[gl_VertexID % 6].y, 0, 1);

	font_size = layout_font_size;

	texture_coordinate = layout_texture_coordinates;

	text_color = layout_color;
	outline_color = layout_outline_color;
	outline_size = layout_outline_size;
}
)"