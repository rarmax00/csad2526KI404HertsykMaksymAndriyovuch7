cmake_minimum_required(VERSION 3.14)

project(HelloWorld VERSION 1.0 LANGUAGES CXX)

# Require C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Create a small library for math operations so both the executable and tests can link to it
add_library(math_ops STATIC
  math_operations.cpp
)

target_include_directories(math_ops PUBLIC
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
)

# Create the main executable from main.cpp and link the math_ops library
add_executable(HelloWorld main.cpp)
target_link_libraries(HelloWorld PRIVATE math_ops)

# Prefer target-based properties
target_compile_features(HelloWorld PRIVATE cxx_std_17)
target_compile_features(math_ops PRIVATE cxx_std_17)

# Warning level / pedantic flags per compiler (helpful cross-platform defaults)
if (MSVC)
  target_compile_options(HelloWorld PRIVATE /W4 /permissive-)
  target_compile_options(math_ops PRIVATE /W4 /permissive-)
else ()
  target_compile_options(HelloWorld PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options(math_ops PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Place binaries in a predictable folder inside the build directory
set_target_properties(HelloWorld PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Install rule for the produced executable
install(TARGETS HelloWorld
  RUNTIME DESTINATION bin
)

# Option to enable building tests (OFF by default)
option(BUILD_TESTS "Build tests" OFF)

# GoogleTest integration (download & build when BUILD_TESTS is ON)
if (BUILD_TESTS)
  enable_testing()
  include(FetchContent)

  # Fetch GoogleTest; this will download the project at configure time if needed.
  FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/heads/main.zip
  )

  # For MSVC: prefer shared CRT for gtest to match project settings if needed
  if (MSVC)
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  endif()

  FetchContent_MakeAvailable(googletest)

  # Add the test executable and link to gtest_main and our math_ops library
  add_executable(unit_tests tests/unit_tests.cpp)
  target_link_libraries(unit_tests PRIVATE GTest::gtest_main math_ops)
  target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})
  target_compile_features(unit_tests PRIVATE cxx_std_17)

  if (MSVC)
    target_compile_options(unit_tests PRIVATE /W4 /permissive-)
  else ()
    target_compile_options(unit_tests PRIVATE -Wall -Wextra -Wpedantic)
  endif()

  # Put tests in the same predictable output folder
  set_target_properties(unit_tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  )

  add_test(NAME unit_tests COMMAND unit_tests)
endif()
