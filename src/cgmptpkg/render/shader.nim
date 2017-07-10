import opengl

type
  ## Represents an OpenGL program object.
  Program* = object
    handle*: GLhandle
  
  ## Represents an OpenGL shader object.
  Shader* = object
    handle*: GLhandle
    shaderType*: ShaderType
  
  ShaderType* {.pure.} = enum GLenum
    Fragment = GL_FRAGMENT_SHADER,
    Vertex   = GL_VERTEX_SHADER,
    Geometry = GL_GEOMETRY_SHADER,
    Compute  = GL_COMPUTE_SHADER
  
  ShaderException* = object of Exception

converter toHandle*(value: Program): GLhandle = value.handle
converter toHandle*(value: Shader): GLhandle = value.handle
converter toEnum*(value: ShaderType): GLenum = GLenum(value)

## Returns the information log of the OpenGL object, or nil if none.
proc getInfoLog[T](obj: T): string =
  # Decide which procs/values to use based on the object type.
  when T is Program:
    const
      getiv       = glGetProgramiv
      getInfoLog  = glGetProgramInfoLog
      statusPName = GL_LINK_STATUS
  elif T is Shader:
    const
      getiv       = glGetShaderiv
      getInfoLog  = glGetShaderInfoLog
      statusPName = GL_COMPILE_STATUS
  else: {.error "Only Program and Shader are valid".}
  
  var status: GLint
  getiv(obj, statusPName, addr status)
  if status == 0:
    var logLength: GLsizei
    getiv(obj, GL_INFO_LOG_LENGTH, addr logLength)
    result = newString(logLength)
    getInfoLog(obj, logLength, addr logLength, result)
  else: result = nil

## Raises a ShaderException if the OpenGL object has an information log.
proc checkInfoLog[T](obj: T) =
  let log = obj.getInfoLog()
  if not isNil(log):
    raise newException(ShaderException, log)


## Creates and returns a new OpenGL Program.
proc newProgram*(): Program =
  Program(handle: glCreateProgram())

## Attaches a Shader to a Program.
proc attach*(program: Program, shader: Shader) =
  glAttachShader(program, shader)

## Links a Program, raising an exception if it failed.
proc link*(program: Program) =
  glLinkProgram(program)
  program.checkInfoLog()

## Intalls a Program as part of the current rendering state.
proc use*(program: Program) =
  glUseProgram(program)


## Creates a new OpenGL Shader object.
proc newShader*(shaderType: ShaderType): Shader =
  Shader(handle: glCreateShader(shaderType),
         shaderType: shaderType)

## Sets the source code of a Shader.
proc source*(shader: Shader, source: string) =
  let sourceArr = [source].allocCStringArray()
  defer: sourceArr.deallocCStringArray()
  glShaderSource(shader, 1, sourceArr, nil)

## Compiles a Shader, raising an exception if it failed.
proc compile*(shader: Shader) =
  glCompileShader(shader)
  shader.checkInfoLog()


## Creates and compiles a new Shader from a source string.
proc loadShaderString*(shaderType: ShaderType, source: string): Shader =
  result = newShader(shaderType)
  result.source(source)
  result.compile()

## Creates and compiles a new Shader from a source file.
proc loadShaderFile*(shaderType: ShaderType, path: string): Shader =
  loadShaderString(shaderType, readFile(path))
