import ../render/shaders

type
  GLResource = concept x
    GLhandle(x) is GLhandle

  Resource[T] = object {.inheritable.}
    handle: T

  ShaderResource = object {.inheritable.} of Resource[Shader]

  ProgramResource = object of Resource[Program]

converter toHandle*[T](r: Resource[T]): T = r.handle