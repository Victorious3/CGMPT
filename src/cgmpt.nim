import sdl2

if sdl2.init(sdl2.INIT_VIDEO + sdl2.INIT_AUDIO + sdl2.INIT_EVENTS):
    raise newException(Exception, "sdl2.init error: " & $sdl2.getError())

let window = sdl2.createWindow(
    title = "CGMPT", 
    x = SDL_WINDOWPOS_CENTERED, 
    y = SDL_WINDOWPOS_CENTERED, 
    w = 800, 
    h = 600, 
    flags = SDL_WINDOW_SHOWN + SDL_WINDOW_OPENGL
)

if isNil window:
    raise newException(Exception, "sdl2.createWindow error: " & $sdl2.getError())

var running = true

proc pollEvent =
    var event: sdl2.Event
    while sdl2.pollEvent(event):
        case event.kind
        of sdl2.QuitEvent:
            running = false
        else: discard

while running:
    pollEvent()

echo "Terminating!"

sdl2.destroyWindow(window)