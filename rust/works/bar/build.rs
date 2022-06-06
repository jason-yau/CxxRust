fn main() {
    let sources = vec![
        "src/lib.rs",
        "src/mystruct.rs",
    ];
    let _build = cxx_build::bridges(sources);
}