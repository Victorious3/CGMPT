import
  sdl2 as sdl,
  opengl as gl,
  cgmpt/config

const TITLE = "CGMPT - " & VERSION
const BG_COLOR = (0.3, 0.1, 0.1)
const DEFAULT_SIZE = (
  width: 800,
  height: 450
)

if sdl.init(sdl.INIT_VIDEO or sdl.INIT_AUDIO or sdl.INIT_EVENTS) == SdlError:
  raise newException(Exception, "sdl.init error: " & $sdl.getError())

let window = sdl.createWindow(
  title = TITLE,
  x = SDL_WINDOWPOS_CENTERED,
  y = SDL_WINDOWPOS_CENTERED,
  w = cint(DEFAULT_SIZE.width),
  h = cint(DEFAULT_SIZE.height),
  flags = SDL_WINDOW_SHOWN or SDL_WINDOW_OPENGL
)

if isNil window:
  raise newException(Exception, "sdl.createWindow error: " & $sdl.getError())

# Opengl flags
discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)

discard glSetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG)

discard glSetAttribute(SDL_GL_RED_SIZE, 5)
discard glSetAttribute(SDL_GL_GREEN_SIZE, 5)
discard glSetAttribute(SDL_GL_BLUE_SIZE, 5)
discard glSetAttribute(SDL_GL_DEPTH_SIZE, 16)
discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)

discard glSetSwapInterval(1)

let context = window.glCreateContext()
# Call is needed to do all the OpenGL extension wrangling
gl.loadExtensions()

var running = true

# Processing events
proc pollEvent =
  var event: sdl.Event
  while sdl.pollEvent(event):
    case event.kind
    of sdl.QuitEvent:
      running = false
    else: discard

# Application loop
while running:
  pollEvent()

  glClearColor(BG_COLOR[0], BG_COLOR[1], BG_COLOR[2], 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  window.glSwapWindow()

# Cleanup
echo "Terminating!"

sdl.destroy(window)
glDeleteContext(context)
