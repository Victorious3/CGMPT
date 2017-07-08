# AUTO GENERATED FILE - DO NOT EDIT
import glm
import resource/resource

#[
shader/:
  core.prog:
    - ../frag/core.vert
    - ../vert/core.frag
  frag/core.vert:
    in:
      vertex: ivec2
      texture: vec2
      color: vec4
    uniform:
      projection: array[mat4, 5]
      modelview: mat4
  vert/core.frag:
    uniform:
      use_texture: bool
]#

