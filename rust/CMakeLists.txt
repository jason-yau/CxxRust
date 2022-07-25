include(${CMAKE_SOURCE_DIR}/cmake/rust.cmake)

cxxbridge_add_library(rustlibrary
    basic/src/lib.rs
    second/src/lib.rs
    second/src/parse_xml.rs
    works/foo/src/lib.rs
    works/bar/src/lib.rs
    works/bar/src/mystruct.rs
)
