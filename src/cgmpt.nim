import
  opengl as gl,
  strutils

import 
  cgmptpkg/config,
  cgmptpkg/sdl,
  cgmptpkg/glew,
  cgmptpkg/render

const BG_COLOR = (0.3, 0.1, 0.1)

sdl.init("CGMPT - " & VERSION, (800, 450))

let error = glew.init()

if int(error) != 0:
  echo "Error initializing GLEW: " & $glew.getErrorString(error)

# Set debug flag to get all log output
when DEBUG:
  if glew.getVar(KHR_debug):
    proc debugMessageCallback(source: GLenum, typ: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: ptr GLchar, userParam: pointer) {.stdcall.} =
      echo "[GL]: " & $message # Assuming this is 0 terminated
    glDebugMessageCallback(debugMessageCallback, nil)
    #glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DEBUG_SEVERITY_LOW, 0, nil, false)
    glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DEBUG_SEVERITY_NOTIFICATION, 0, nil, false)

# OpenGL setup
glEnable(GL_BLEND)
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

glEnable(GL_CULL_FACE)
glFrontFace(GL_CCW)

glViewport(0, 0, 800, 450) # FIXME: Don't hardcode, get window size somehow.

gl.checkGLerror()

var running = true

# Processing events
proc pollEvents() =
  var event: sdl.Event
  while sdl.pollEvent(event):
    case event.kind
    of sdl.EventType.QuitEvent:
      running = false
    else: discard

# Application loop
while running:
  pollEvents()
  
  glClearColor(BG_COLOR[0], BG_COLOR[1], BG_COLOR[2], 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  sdl.swapBuffers()

# Cleanup
echo "Terminating!"
sdl.destroy()
