use cxx::{CxxString, CxxVector};

#[cxx::bridge(namespace = "basic")]
mod ffi {
    struct RustStruct {
        x: i32,
        y: f64,
        z: String,
    }

    extern "Rust" {
        #[cxx_name = "toIntVector"]
        fn to_i32_vector(vec: &CxxVector<CxxString>) -> Vec<i32>;

        #[cxx_name = "getRustStruct"]
        fn get_rust_struct() -> RustStruct;
    }
}

fn to_i32_vector(vec: &CxxVector<CxxString>) -> Vec<i32> {
    vec.iter().filter_map(|v|v.to_string().parse().ok()).collect()
}

fn get_rust_struct() -> ffi::RustStruct {
    ffi::RustStruct {
        x: 10,
        y: 0.12,
        z: String::from("From Rust String"),
    }
}

#[no_mangle]
pub extern "C" fn rust_extern_c_integer() -> i32 {
    322
}