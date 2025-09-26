#include "../src/function.h"

#include <cassert>
#include <string>
#include <iostream>

void test() {
    assert(greet("Alice") == "Hello, Alice!");
    assert(greet("Bob") == "Hello, Bob!");
    assert(greet("") == "Hello, !");
    std::cout << "All tests passed.\n";
}

int main() {
    test();
    return 0;
}
