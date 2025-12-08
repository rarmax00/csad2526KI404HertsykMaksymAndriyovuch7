cmake_minimum_required(VERSION 3.14)

project(HelloWorld VERSION 1.0 LANGUAGES CXX)

# Enable CTest so tests are always discoverable
include(CTest)
enable_testing()

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

# Place binaries in a predictable folder inside the build directory (for all configs)
set_target_properties(HelloWorld math_ops PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/bin"
)

# Install rule for the produced executable
install(TARGETS HelloWorld
  RUNTIME DESTINATION bin
)

#
# GoogleTest: always fetch/build and always create/register unit_tests
#
include(FetchContent)

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
# The test source file here is tests/unit_tests.cpp (keeps existing layout)
add_executable(unit_tests tests/unit_tests.cpp)
target_link_libraries(unit_tests PRIVATE GTest::gtest_main math_ops)
target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})
target_compile_features(unit_tests PRIVATE cxx_std_17)

if (MSVC)
  target_compile_options(unit_tests PRIVATE /W4 /permissive-)
else ()
  target_compile_options(unit_tests PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Ensure test binary lands in same predictable output folder for all configs
set_target_properties(unit_tests PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/bin"
  RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/bin"
)

# Register the test with CTest so it can be discovered and run in CI
add_test(NAME unit_tests COMMAND unit_tests)

# Provide a convenient 'check' target that runs CTest with output on failure.
add_custom_target(check
  COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
  DEPENDS unit_tests
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
