use std::env;
use std::ffi::CString;
use std::os::raw::c_char;

// Deklarasi fungsi dari C++
#[link(name = "gh_bridge", kind="static")]
extern "C" {
    fn create_new_codespace(token: *const c_char, repo_name: *const c_char, machine: *const c_char, display_name: *const c_char);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Perintah salah, anjing!");
        println!("Gunakan: cargo run -- [mawari | nexus]");
        return;
    }

    // Ambil token dari environment variable
    let token = env::var("GH_TOKEN").expect("Error: Environment variable GH_TOKEN tidak ditemukan. Jalanin dulu: $env:GH_TOKEN=\"token_lu\"");
    
    // Konfigurasi repo & mesin
    let repo_name = "Kyugito666/mawari-nexus-blueprint"; // Ganti kalo perlu
    let (machine, display_name) = match args[1].as_str() {
        "mawari" => ("basicLinux32gb", "mawari-node"),
        "nexus" => ("standardLinux32gb", "nexus-node"),
        _ => {
            println!("Pilihan tidak valid. Pilih 'mawari' atau 'nexus'.");
            return;
        }
    };

    println!("Mempersiapkan perintah untuk C++...");
    let c_token = CString::new(token).unwrap();
    let c_repo = CString::new(repo_name).unwrap();
    let c_machine = CString::new(machine).unwrap();
    let c_display = CString::new(display_name).unwrap();

    println!("Mengirim perintah ke C++ untuk membuat Codespace '{}'...", display_name);
    
    // Panggil fungsi C++
    unsafe {
        create_new_codespace(c_token.as_ptr(), c_repo.as_ptr(), c_machine.as_ptr(), c_display.as_ptr());
    }

    println!("✅ Perintah berhasil dikirim. Cek halaman Codespaces lu.");
}
