import
  opengl as gl,
  strutils

import
  cgmptpkg/render/buffers,
  cgmptpkg/render/shaders,
  cgmptpkg/assets,
  cgmptpkg/config,
  cgmptpkg/glew,
  cgmptpkg/sdl

const BG_COLOR = (0.3, 0.1, 0.1)

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

# Vertex Array / Buffer setup
# TODO: Move this into helper class, maybe reorganize all GL wrapper code into a single file?
var vao: GLuint
glGenVertexArrays(1, addr(vao))
glBindVertexArray(vao)
var bufferData = @[0.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, -1.0, 0.0]
let buffer = createBuffer(BufferTarget.Array, bufferData)
glVertexAttribPointer(0, 3, cGL_FLOAT, false, 0, nil)
glEnableVertexAttribArray(0)

# Shaders setup
let program = newProgram()
program.attach(loadShaderFile(ShaderType.Vertex, "./assets/shader/core.vert"))
program.attach(loadShaderFile(ShaderType.Fragment, "./assets/shader/core.frag"))
glBindAttribLocation(program, 0, "vertex")
program.link()
program.use()

# OpenGL setup
glEnable(GL_BLEND)
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

glEnable(GL_CULL_FACE)
glFrontFace(GL_CCW)

glViewport(0, 0, 800, 450) # FIXME: Don't hardcode, get window size somehow.

# This is actually not needed since it wraps every function in error checking but might want to remove that in the future for performance reasons
gl.checkGLerror()

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
  
  glClearColor(BG_COLOR[0], BG_COLOR[1], BG_COLOR[2], 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  
  glDrawArrays(GL_TRIANGLES, 0, 3)
  
  sdl.swapBuffers()

# Cleanup
echo "Terminating!"
sdl.destroy()
