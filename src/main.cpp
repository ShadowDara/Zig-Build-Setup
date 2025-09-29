#include "function.h"
#include "hello.h"

// #include "SDL3/SDL.h"

#include "recursiv/hi.h"

#include <iostream>

#include "DARA_LIBARY/DARA.h"

int main()
{
    std::string name;
    std::cout << "Enter your name: ";
    std::getline(std::cin, name);

    std::string message = greet(name);
    std::cout << message << std::endl;

    random_fact();

    dara();

    return 0;
}

