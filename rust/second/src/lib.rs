use cxx::CxxString;

#[cxx::bridge(namespace = "second")]
mod ffi {
    extern "Rust" {
        fn to_rust_string(s: &CxxString) -> String;
    }
}

fn to_rust_string(s: &CxxString) -> String {
    s.to_string()
}