import
  glm,
  opengl,
  strutils

import
  render/buffer,
  render/color,
  render/shader,
  assets,
  config,
  glew,
  misc,
  sdl

const BG_COLOR = newColorRGB(0x441111)

sdl.init("CGMPT - " & VERSION, (800, 450))

let error = glewInit()
if int(error) != 0:
  echo "Error initializing GLEW: " & $glewGetErrorString(error)

# Set debug flag to get all log output
when DEBUG:
  if glewGetVar(KHR_debug):
    proc debugMessageCallback(source: GLenum, typ: GLenum, id: GLuint, severity: GLenum,
                              length: GLsizei, message: ptr GLchar, userParam: pointer) {.stdcall.} =
      echo "[GL]: " & $message # Assuming this is 0 terminated
    glDebugMessageCallback(debugMessageCallback, nil)
    #glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DEBUG_SEVERITY_LOW, 0, nil, false)
    glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DEBUG_SEVERITY_NOTIFICATION, 0, nil, false)

# OpenGL setup
glEnable(GL_BLEND)
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

glEnable(GL_DEPTH_TEST)

glEnable(GL_CULL_FACE)
glFrontFace(GL_CCW)

glViewport(0, 0, 800, 450) # FIXME: Don't hardcode, get window size somehow.

# This is actually not needed since it wraps every function in error checking but might want to remove that in the future for performance reasons
checkGLerror()

# Vertex Array / Buffer setup
# TODO: Move this into helper class, maybe reorganize all GL wrapper code into a single file?
var cube = @[
  vec3f(-1.0, -1.0, -1.0), vec3f(-1.0, -1.0,  1.0), vec3f(-1.0,  1.0,  1.0),
  vec3f( 1.0,  1.0, -1.0), vec3f(-1.0, -1.0, -1.0), vec3f(-1.0,  1.0, -1.0),
  vec3f( 1.0, -1.0,  1.0), vec3f(-1.0, -1.0, -1.0), vec3f( 1.0, -1.0, -1.0),
  vec3f( 1.0,  1.0, -1.0), vec3f( 1.0, -1.0, -1.0), vec3f(-1.0, -1.0, -1.0),
  vec3f(-1.0, -1.0, -1.0), vec3f(-1.0,  1.0,  1.0), vec3f(-1.0,  1.0, -1.0),
  vec3f( 1.0, -1.0,  1.0), vec3f(-1.0, -1.0,  1.0), vec3f(-1.0, -1.0, -1.0),
  vec3f(-1.0,  1.0,  1.0), vec3f(-1.0, -1.0,  1.0), vec3f( 1.0, -1.0,  1.0),
  vec3f( 1.0,  1.0,  1.0), vec3f( 1.0, -1.0, -1.0), vec3f( 1.0,  1.0, -1.0),
  vec3f( 1.0, -1.0, -1.0), vec3f( 1.0,  1.0,  1.0), vec3f( 1.0, -1.0,  1.0),
  vec3f( 1.0,  1.0,  1.0), vec3f( 1.0,  1.0, -1.0), vec3f(-1.0,  1.0, -1.0),
  vec3f( 1.0,  1.0,  1.0), vec3f(-1.0,  1.0, -1.0), vec3f(-1.0,  1.0,  1.0),
  vec3f( 1.0,  1.0,  1.0), vec3f(-1.0,  1.0,  1.0), vec3f( 1.0, -1.0,  1.0)
];
var cubeColors = @[
  C_RED,    C_RED,    C_RED,    C_RED,    C_RED,    C_RED,
  C_LIME,   C_LIME,   C_LIME,   C_LIME,   C_LIME,   C_LIME,
  C_BLUE,   C_BLUE,   C_BLUE,   C_BLUE,   C_BLUE,   C_BLUE,
  C_YELLOW, C_YELLOW, C_YELLOW, C_YELLOW, C_YELLOW, C_YELLOW,
  C_PURPLE, C_PURPLE, C_PURPLE, C_PURPLE, C_PURPLE, C_PURPLE,
  C_WHITE,  C_WHITE,  C_WHITE,  C_WHITE,  C_WHITE,  C_WHITE
];

let vBuffer = createBuffer(BufferTarget.Array, cube)
let cBuffer = createBuffer(BufferTarget.Array, cubeColors)

var vao: GLuint
glGenVertexArrays(1, addr(vao))
vao.glBindVertexArray()
vBuffer.`bind`()
glVertexAttribPointer(0, 3, cGL_FLOAT, false, 0, nil)
cBuffer.`bind`()
glVertexAttribPointer(1, 4, cGL_FLOAT, false, 0, nil)
glEnableVertexAttribArray(0)
glEnableVertexAttribArray(1)

# Shaders setup
let program = newProgram()
program.attach(loadShaderFile(ShaderType.Vertex, "./assets/shader/core.vert"))
program.attach(loadShaderFile(ShaderType.Fragment, "./assets/shader/core.frag"))
program.glBindAttribLocation(0, "inPosition")
program.glBindAttribLocation(1, "inColor")
program.link()
let projectionLoc = program.getUniform("projection")
let modelviewLoc = program.getUniform("modelview")
var modelview = lookAt(vec3f(2, 2, 2), vec3f(0, 0, 0), vec3f(0, 1, 0))
program.use()
projectionLoc.set(varof(perspective[float32](radians(75'f32), 800 / 450'f32, 0.1, 100)))

var running = true

# Processing events
proc processEvents() =
  for event in sdl.pollEvents():
    case event.kind
    of sdl.EventType.QuitEvent:
      running = false
    else: discard

# Application loop
while running:
  processEvents()
  
  modelview = modelview.rotate(vec3f(0, 1, 0), 0.0001)
  modelviewLoc.set(modelview)
  
  BG_COLOR.glClear()
  vao.glBindVertexArray()
  glDrawArrays(GL_TRIANGLES, 0, GLsizei(cube.len))
  
  sdl.swapBuffers()

# Cleanup
echo "Terminating!"
sdl.destroy()
