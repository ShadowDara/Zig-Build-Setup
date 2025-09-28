#include "function.h"
#include "hello.h"
#include "../external/SDL3/include/SDL3/SDL.h"

#include <iostream>

int main() {
    std::string name;
    std::cout << "Enter your name: ";
    std::getline(std::cin, name);

    std::string message = greet(name);
    std::cout << message << std::endl;

    random_fact();

    // sdl_init();

    return 0;
}

void sdl_init() {// SDL initialisieren
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL konnte nicht initialisiert werden: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Fenster erstellen
    SDL_Window* window = SDL_CreateWindow("SDL3 C++ Beispiel",
                                          100, 100, 800, 600,
                                          SDL_WINDOW_RESIZABLE);
    if (!window) {
        std::cerr << "Fenster konnte nicht erstellt werden: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    // Renderer erstellen
    SDL_Renderer* renderer = SDL_CreateRenderer(window, nullptr, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        std::cerr << "Renderer konnte nicht erstellt werden: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    bool running = true;
    SDL_Event event;

    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT) {
                running = false;
            }
        }

        // Bildschirmfarbe setzen (z.B. hellblau)
        SDL_SetRenderDrawColor(renderer, 100, 150, 255, 255);
        SDL_RenderClear(renderer);

        // Hier könnte man zeichnen...

        SDL_RenderPresent(renderer);
        SDL_Delay(16); // ~60 FPS
    }

    // Aufräumen
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;

}