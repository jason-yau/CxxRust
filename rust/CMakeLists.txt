include(${CMAKE_SOURCE_DIR}/cmake/rust.cmake)

# Add rust sources (Only add what to be compiled by cxx-build)
add_rust_sources(
    basic/src/lib.rs
    second/src/lib.rs
    works/foo/src/lib.rs
    works/bar/src/lib.rs
    works/bar/src/mystruct.rs
)

# Add rust library
add_rust_lilbrary(rustlibrary)
