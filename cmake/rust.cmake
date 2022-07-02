cmake_minimum_required(VERSION 3.15)

add_subdirectory(${CMAKE_SOURCE_DIR}/cmake/corrosion .corrosion)

if(NOT TARGET Rust::CxxBridge)
    find_program(CXXBRIDGE_EXECUTABLE cxxbridge PATHS $ENV{HOME}/.cargo/bin)
    if(NOT CXXBRIDGE_EXECUTABLE)
        get_property(CARGO_EXECUTABLE TARGET Rust::Cargo PROPERTY IMPORTED_LOCATION)
        execute_process(COMMAND ${CARGO_EXECUTABLE} install cxxbridge COMMAND_ECHO STDERR)
        find_program(CXXBRIDGE_EXECUTABLE cxxbridge PATHS $ENV{HOME}/.cargo/bin)
        if(NOT CXXBRIDGE_EXECUTABLE)
            message(FATAL_ERROR "cxxbridge is required. Try `cargo install cxxbridge` to install it")
        endif()
    endif()

    add_executable(Rust::CxxBridge IMPORTED GLOBAL)
    set_property(TARGET Rust::CxxBridge PROPERTY IMPORTED_LOCATION ${CXXBRIDGE_EXECUTABLE})
endif()

function(add_rust_sources)
    list(LENGTH ARGV ARGV_LENGTH)
    if(ARGV_LENGTH EQUAL 0)
        message(FATAL_ERROR "Rust source(s) is required to add_rust_sources")
    endif()

    get_property(CXXBRIDGE_EXECUTABLE TARGET Rust::CxxBridge PROPERTY IMPORTED_LOCATION)
    get_filename_component(CURRENT_FOLDER ${CMAKE_CURRENT_SOURCE_DIR} NAME)

    set(CXXBRIDGE_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/cxxbridge)
    set(CXXBRIDGE_SOURCES)
    set(RUST_CRATES)
    foreach(RUST_SRC ${ARGV})
        file(REAL_PATH ${RUST_SRC} RUST_SRC)
        string(REGEX REPLACE "(.*/[a-zA-Z0-9_-]+)/src/.*.rs$" "\\1" CRATE_PATH ${RUST_SRC})
        list(APPEND RUST_CRATES ${CRATE_PATH})

        string(REGEX REPLACE ".*/([a-zA-Z0-9_-]+/)src/([a-zA-Z0-9_/-]+.rs$)" "\\1\\2" CXX_SRC ${RUST_SRC})
        list(APPEND CXXBRIDGE_SOURCES ${CXXBRIDGE_SOURCE_DIR}/${CXX_SRC}.cc)
        get_filename_component(SRC_PATH ${CXXBRIDGE_SOURCE_DIR}/${CXX_SRC} DIRECTORY)
        message(src_path:${SRC_PATH})
        file(MAKE_DIRECTORY ${SRC_PATH})


        execute_process(COMMAND ${CXXBRIDGE_EXECUTABLE} ${RUST_SRC} OUTPUT_FILE ${CXXBRIDGE_SOURCE_DIR}/${CXX_SRC}.cc COMMAND_ECHO STDERR RESULT_VARIABLE GENERATED_CXX_SRC_RESULT)
        if(NOT GENERATED_CXX_SRC_RESULT EQUAL 0)
            message(FATAL_ERROR "Generated ${CXX_SRC}.cc failed")
        endif()

        execute_process(COMMAND ${CXXBRIDGE_EXECUTABLE} ${RUST_SRC} --header OUTPUT_FILE ${CXXBRIDGE_SOURCE_DIR}/${CXX_SRC}.h COMMAND_ECHO STDERR RESULT_VARIABLE GENERATED_CXX_HEADER_RESULT)
        if(NOT GENERATED_CXX_HEADER_RESULT EQUAL 0)
            message(FATAL_ERROR "Generated ${CXX_SRC}.h failed")
        endif()
    endforeach()

    file(MAKE_DIRECTORY ${CXXBRIDGE_SOURCE_DIR}/rust)
    execute_process(COMMAND ${CXXBRIDGE_EXECUTABLE} --header OUTPUT_FILE ${CXXBRIDGE_SOURCE_DIR}/rust/cxx.h COMMAND_ECHO STDERR RESULT_VARIABLE GENERATED_CXX_H_RESULT)
    if(NOT GENERATED_CXX_H_RESULT EQUAL 0)
        message(FATAL_ERROR "Generated cxx.h failed")
    endif()

    list(REMOVE_DUPLICATES RUST_CRATES)
    set(RUST_CRATES ${RUST_CRATES} PARENT_SCOPE)
    set(CXXBRIDGE_SOURCES ${CXXBRIDGE_SOURCES} PARENT_SCOPE)
endfunction(add_rust_sources)

function(_make_lib_rs_file)
    set(ONE_VALUE_KEYWORDS LIBRARY)
    set(MULTI_VALUE_KEYWORDS CRATES)
    cmake_parse_arguments(RUST "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

    if(NOT DEFINED RUST_LIBRARY)
        message(FATAL_ERROR "LIBRARY is required keyword to make_lib_rs_file")
    endif()
    if(NOT DEFINED RUST_CRATES)
        message(FATAL_ERROR "CRATES is required keyword to make_lib_rs_file")
    endif()

    set(LIB_RS_FILE_CONTENTS)
    foreach(DEPEND ${RUST_CRATES})
        get_filename_component(CRATE ${DEPEND} NAME)
        string(APPEND LIB_RS_FILE_CONTENTS "pub use ${CRATE}\;\n")
    endforeach()

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${RUST_LIBRARY}/src/lib.rs ${LIB_RS_FILE_CONTENTS})
endfunction(_make_lib_rs_file)

function(_make_cargo_toml_file)
    set(ONE_VALUE_KEYWORDS NAME VERSION)
    set(MULTI_VALUE_KEYWORDS DEPENDS)
    cmake_parse_arguments(LIB "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

    if(NOT DEFINED LIB_NAME)
        message(FATAL_ERROR "NAME is required keyword to make_cargo_toml_file")
    endif()
    if(NOT DEFINED LIB_DEPENDS)
        message(FATAL_ERROR "DEPENDS is required keyword to make_cargo_toml_file")
    endif()

    if(NOT DEFINED LIB_VERSION)
        set(LIB_VERSION "0.1.0")
    endif()

    set(CARGO_TOML_FILE_CONTENTS "[package]\nname=\"${LIB_NAME}\"\nversion=\"${LIB_VERSION}\"\nedition=\"2021\"\n[lib]\ncrate-type=[\"staticlib\"]\n[dependencies]\n")
    foreach(DEPEND ${LIB_DEPENDS})
        get_filename_component(CRATE ${DEPEND} NAME)
        string(APPEND CARGO_TOML_FILE_CONTENTS "${CRATE}={path=\"${DEPEND}\"}\n")
    endforeach()

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${LIB_NAME}/Cargo.toml ${CARGO_TOML_FILE_CONTENTS})
endfunction(_make_cargo_toml_file)

function(add_rust_lilbrary LIBRARY)
    if(NOT RUST_CRATES)
        message(FATAL_ERROR "Need add_rust_sources before add_rust_lilbrary")
    endif()

    _make_cargo_toml_file(
        NAME ${LIBRARY}
        DEPENDS ${RUST_CRATES}
    )

    _make_lib_rs_file(
        LIBRARY ${LIBRARY}
        CRATES ${RUST_CRATES}
    )

    get_property(
        CARGO_EXECUTABLE
        TARGET Rust::Cargo PROPERTY IMPORTED_LOCATION
    )

    corrosion_import_crate(
        MANIFEST_PATH ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY}/Cargo.toml
    )

    set_property(
        TARGET ${LIBRARY}-static
        PROPERTY INTERFACE_SOURCES ${CXXBRIDGE_SOURCES}
    )
    set_property(
        TARGET ${LIBRARY}-static
        PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_BINARY_DIR}/cxxbridge
    )
endfunction(add_rust_lilbrary)
