#include "function.h"
#include "hello.h"

#include "SDL3/SDL.h"

#include "recursiv/hi.h"

#include <iostream>

int main()
{
    std::string name;
    std::cout << "Enter your name: ";
    std::getline(std::cin, name);

    std::string message = greet(name);
    std::cout << message << std::endl;

    random_fact();

    if (runSDL3Test())
    {
        std::cout << "SDL3 Test erfolgreich abgeschlossen!" << std::endl;
    }
    else
    {
        std::cout << "SDL3 Test fehlgeschlagen." << std::endl;
    }

    return 0;
}

