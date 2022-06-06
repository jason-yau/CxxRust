include(${CMAKE_SOURCE_DIR}/cmake/rust.cmake)

# Add rust sources (Only add what to be compiled by cxx-build)
add_rust_sources(ffi::basic
    lib.rs
)

add_rust_sources(ffi::second
    lib.rs
)

add_rust_sources(foo
    lib.rs
)

add_rust_sources(bar
    lib.rs
    mystruct.rs
)

# Add rust crates
add_rust_crates(PATH ${CMAKE_SOURCE_DIR}/rust/works)
add_rust_crates(PATH ${CMAKE_SOURCE_DIR}/rust/basic NAMESPACE ffi)
add_rust_crates(PATH ${CMAKE_SOURCE_DIR}/rust/second NAMESPACE ffi)