import sdl2 as sdl
import config

type
  SdlException* = object of Exception
  WindowSize* = tuple[width: int, height: int]

var
  window: sdl.WindowPtr
  context: sdl.GlContextPtr

## Initializes SDL, creates and shows the window.
proc init*(title: string, size: WindowSize) =
  if sdl.init(sdl.INIT_VIDEO or sdl.INIT_AUDIO or sdl.INIT_EVENTS) != SdlSuccess:
    raise newException(SdlException, "Error during sdl.init: " & $sdl.getError())
  
  window = sdl.createWindow(
    title = title,
    x = SDL_WINDOWPOS_CENTERED,
    y = SDL_WINDOWPOS_CENTERED,
    w = int32(size.width),
    h = int32(size.height),
    flags = SDL_WINDOW_SHOWN or SDL_WINDOW_OPENGL
  )
  
  if isNil window:
    raise newException(SdlException, "Error during sdl.createWindow: " & $sdl.getError())
  
  # OpenGL flags
  discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, int32(GL_VERSION.major))
  discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, int32(GL_VERSION.minor))
  discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
  
  when DEBUG:
    discard glSetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG)
  
  discard glSetAttribute(SDL_GL_RED_SIZE, 5)
  discard glSetAttribute(SDL_GL_GREEN_SIZE, 5)
  discard glSetAttribute(SDL_GL_BLUE_SIZE, 5)
  discard glSetAttribute(SDL_GL_DEPTH_SIZE, 16)
  discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)
  
  discard glSetSwapInterval(1)
  
  context = window.glCreateContext()

# TODO: Handle pollEvent more nicely.
export
  sdl.Event,
  sdl.EventType
iterator pollEvents*(): sdl.Event =
  var event: sdl.Event = defaultEvent
  while sdl.pollEvent(event):
    yield event

## Swaps the OpenGL buffers.
proc swapBuffers*() =
  window.glSwapWindow()

## Destroys the SDL window and OpenGL context.
proc destroy*() =
  sdl.destroy(window)
  sdl.glDeleteContext(context)
  sdl.quit()
