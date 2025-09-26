#include "function.h"
#include "hello.h"

#include <iostream>

int main() {
    std::string name;
    std::cout << "Enter your name: ";
    std::getline(std::cin, name);

    std::string message = greet(name);
    std::cout << message << std::endl;

    random_fact();

    return 0;
}
