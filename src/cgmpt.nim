import sdl2 as sdl
import opengl

try:
  sdl.init(sdl.INIT_VIDEO or sdl.INIT_AUDIO or sdl.INIT_EVENTS)
except:
  # Sadly we have to do this since sdl.init throws an exception if SDL is compiled without directx
  # Let's hope that some of the other functions fail if SDL failed to intialize correctly
  echo getCurrentExceptionMsg()

let window = sdl.createWindow(
  title = "CGMPT",
  x = SDL_WINDOWPOS_CENTERED,
  y = SDL_WINDOWPOS_CENTERED,
  w = 800,
  h = 600,
  flags = SDL_WINDOW_SHOWN + SDL_WINDOW_OPENGL
)

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
# Call is needed to do all the opengl extension wrangling
opengl.loadExtensions()

var running = true

# Event loop
proc pollEvent =
  var event: sdl.Event
  while sdl.pollEvent(event):
    case event.kind
    of sdl.QuitEvent:
      running = false
    else: discard

while running:
  pollEvent()

  glClearColor(255, 0, 0, 0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  window.glSwapWindow()

echo "Terminating!"

# Cleanup
sdl.destroy(window)
glDeleteContext(context)
