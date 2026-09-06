#pragma once

#include <iostream>
#include <string>

class Logger {
public:
    static void info(const std::string& message) { std::cout << message << '\n'; }
    static void warning(const std::string& message) { std::cerr << "Warning: " << message << '\n'; }
};
