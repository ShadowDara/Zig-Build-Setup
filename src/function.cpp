#include "function.h"

std::string greet(const std::string& name) {
    return "Hello, " + name + "!";
}

bool runSDL3Test()
{
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
    {
        std::cerr << "SDL_Init fehlgeschlagen: " << SDL_GetError() << std::endl;
        return false;
    }

    SDL_Window *window = SDL_CreateWindow("SDL3 Test",
                                          SDL_WINDOWPOS_CENTERED,
                                          SDL_WINDOWPOS_CENTERED,
                                          640, 480,
                                          0);
    if (!window)
    {
        std::cerr << "Fenster konnte nicht erstellt werden: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return false;
    }

    bool running = true;
    while (running)
    {
        SDL_Event e;
        while (SDL_PollEvent(&e))
        {
            if (e.type == SDL_EVENT_QUIT)
            {
                running = false;
            }
        }
        SDL_Delay(16); // ~60 FPS
    }

    SDL_DestroyWindow(window);
    SDL_Quit();
    return true;
}
