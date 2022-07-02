use cxx::CxxString;

#[cxx::bridge(namespace = "works")]
pub mod ffi {
    extern "Rust" {
        #[cxx_name = "sayHi"]
        fn say_hi(s: &CxxString) -> String;
    }
}

pub fn say_hi(s: &CxxString) -> String {
    println!("{}", s.to_string());
    common::common_fun("foo")
}