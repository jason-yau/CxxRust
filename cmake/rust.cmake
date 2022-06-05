set(RUST_CARGO_TARGET ${Rust_TOOLCHAIN})
string(REPLACE "stable-" "" RUST_CARGO_TARGET ${RUST_CARGO_TARGET})
string(REPLACE "nightly-" "" RUST_CARGO_TARGET ${RUST_CARGO_TARGET})

set(CXXBRIDGE_BINARY_DIR ${CMAKE_BINARY_DIR}/cargo/build/${RUST_CARGO_TARGET}/cxxbridge)

function(add_rust_crates)
    set(OPTIONS ALL_FEATURES NO_DEFAULT_FEATURES NO_STD)
    set(ONE_VALUE_KEYWORDS PATH NAMESPACE PROFILE)
    set(MULTI_VALUE_KEYWORDS CRATES FEATURES)
    cmake_parse_arguments(RUST "${OPTIONS}" "${ONE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

    ## PATH checks
    if(NOT DEFINED RUST_PATH)
        message(FATAL_ERROR "PATH is required keyword to add_rust_crates")
    endif()
    if(NOT IS_ABSOLUTE "${RUST_PATH}")
        set(RUST_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${RUST_PATH})
    endif()
    set(MANIFEST ${RUST_PATH}/Cargo.toml)

    ## OPTIONS checks
    if(NOT RUST_ALL_FEATURES)
        list(REMOVE_ITEM OPTIONS ALL_FEATURES)
    endif()
    if(NOT RUST_NO_DEFAULT_FEATURES)
        list(REMOVE_ITEM OPTIONS NO_DEFAULT_FEATURES)
    endif()
    if(NOT RUST_NO_STD)
        list(REMOVE_ITEM OPTIONS NO_STD)
    endif()

    ## Import rust target
    corrosion_import_crate(
        ${OPTIONS}
        MANIFEST_PATH ${MANIFEST}
        PROFILE ${RUST_PROFILE}
        CRATES ${RUST_CRATES}
        FEATURES ${RUST_FEATURES}
    )

    ## Configure rust libraries
    get_source_file_property(num_targets ${MANIFEST} CORROSION_NUM_TARGETS)
    math(EXPR num_targets-1 "${num_targets} - 1")
    foreach(index RANGE ${num_targets-1})
        get_source_file_property(target_name ${MANIFEST} CORROSION_TARGET${index}_TARGET_NAME)
        set(CXXBRIDGE_SOURCE ${CXXBRIDGE_BINARY_DIR}/${target_name}/src/lib.rs.cc)
        add_custom_command(
            OUTPUT ${CXXBRIDGE_SOURCE}
            DEPENDS ${target_name}-static
        )
        add_library(${target_name}_cxxbridge SHARED ${CXXBRIDGE_SOURCE})
        target_include_directories(${target_name}_cxxbridge
            INTERFACE
                ${CXXBRIDGE_BINARY_DIR}
        )
        target_link_libraries(${target_name}_cxxbridge PRIVATE ${target_name})
        if(DEFINED RUST_NAMESPACE)
            add_library(${RUST_NAMESPACE}::${target_name} ALIAS ${target_name}_cxxbridge)
        else()
            add_library(rust::${target_name} ALIAS ${target_name}_cxxbridge)
            message(STATUS "${target_name} library has namespace rust, use method: rust::${target_name}")
        endif()
    endforeach()
endfunction(add_rust_crates)