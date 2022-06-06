use cxx::CxxString;

mod mystruct;

#[cxx::bridge(namespace = "works")]
mod ffi {
    extern "Rust" {
        fn greeting(s: &CxxString) -> String;
    }
}

pub fn greeting(s: &CxxString) -> String {
    println!("{}", s.to_string());
    common::common_fun("bar")
}