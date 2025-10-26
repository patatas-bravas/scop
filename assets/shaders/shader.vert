#version 460 core
layout (location = 0) in vec3 aPos;

out vec2 textureCoor;

uniform mat4 transform;

void main()
{
    gl_Position = transform * vec4(aPos, 1.0f);
    textureCoor = aPos.xy * 0.9 + 0.5;
    textureCoor.x += 0.1;
}
