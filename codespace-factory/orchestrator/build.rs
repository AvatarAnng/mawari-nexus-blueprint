fn main() {
    cc::Build::new()
        .cpp(true)
        .file("../../gh_bridge/src/gh_bridge.cpp")
        .include("../../gh_bridge/include")
        .compile("gh_bridge");
}
