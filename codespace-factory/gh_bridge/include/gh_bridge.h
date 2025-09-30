#ifndef GH_BRIDGE_H
#define GH_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

// Kontrak fungsi: "Bangun satu Codespace, anjing!"
void create_new_codespace(const char* token, const char* repo_name, const char* machine, const char* display_name);

#ifdef __cplusplus
}
#endif

#endif // GH_BRIDGE_H
