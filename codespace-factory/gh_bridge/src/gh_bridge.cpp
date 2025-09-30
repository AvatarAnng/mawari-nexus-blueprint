#include "../include/gh_bridge.h"
#include <iostream>
#include <string>
#include <memory>
#include <stdexcept>
#include <array>

// Fungsi internal buat ngejalanin perintah `gh`
void runCommand(const std::string& token, const std::string& cmd) {
    std::string full_cmd = "gh " + cmd;
    _putenv_s("GH_TOKEN", token.c_str());
    
    // Kita nggak perlu nangkep outputnya, cuma perlu jalanin
    int result = system(full_cmd.c_str());

    _putenv_s("GH_TOKEN", ""); // Bersihin lagi
    if (result != 0) {
        throw std::runtime_error("Perintah gh gagal dieksekusi.");
    }
}

// Implementasi fungsi yang diekspor buat Rust
void create_new_codespace(const char* token, const char* repo_name, const char* machine, const char* display_name) {
    try {
        std::string cmd = "cs create -R " + std::string(repo_name) + 
                          " --machine " + std::string(machine) + 
                          " --display-name " + std::string(display_name);
        runCommand(std::string(token), cmd);
    } catch (const std::exception& e) {
        std::cerr << "ERROR di C++: " << e.what() << std::endl;
    }
}
