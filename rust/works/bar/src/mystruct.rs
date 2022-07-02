#[cxx::bridge(namespace = "rust")]
pub mod ffi {
    pub struct MyStruct {
        pub s: String,
        pub c: u8,
    }

    extern "Rust" {
        #[cxx_name = "getMyStruct"]
        fn get_my_struct() -> MyStruct;
    }
}

fn get_my_struct() -> ffi::MyStruct {
    ffi::MyStruct {
        s: String::from("hello world"),
        c: 255,
    }
}