# CxxRust
Integrate Rust in a Qt Cmake project with Corrosion and Cxx.

## Usage
```cmake
cmake_minimum_required(VERSION 3.20)
project(MyCxxRustProject)
include(cmake/rust.cmake)

add_executable(cpp-exe main.cpp)

add_rust_sources(
    path/to/rust/source.rs
    crate/src/mod/source.rs
    workspace/crate/src/mod/source.rs
    src/mod/source.rs
)

add_rust_lilbrary(myrustlib)

target_link_libraries(cpp-exe PRIVATE myrustlib)
```

## How to run
Firstly, clone this project using following command:
```bash
$ git clone https://github.com/jason-yau/CxxRust.git
```
Secondly, init submodule corrosion using following command:
```bash
$ cd CxxRust
$ git submodule update --init --recursive
```
Then open and run this project using QtCrator or other IDEs, or you can run it by following steps.
```bash
$ mkdir build && cd build
$ cmake -DCMAKE_PREFIX_PATH=path/to/qt/dir
```
Note: Change `CMAKE_PREFIX_PATH` to your Qt directory that you downloaded, eg: `CMAKE_PREFIX_PATH=/Users/jasonyau/Qt/5.15.2/clang_64`

Then:
```bash
$ make
```
Finally, run following command in your terminal:
```bash
$ ./cxx/CxxRust
```
