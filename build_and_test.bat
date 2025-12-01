@echo off
REM build_and_test.bat
REM Creates a build directory, runs CMake configure, builds the project, and runs CTest.
REM Usage: build_and_test.bat [Configuration]
REM Example: build_and_test.bat Release
REM If no configuration is provided, Release is used by default.

setlocal

:: Allow user to provide configuration (Release, Debug, etc.)
set "CONFIG=%~1"
if "%CONFIG%"=="" set "CONFIG=Release"

echo.
echo ===== Build and Test (CMake) =====
echo Configuration: %CONFIG%
echo =================================
echo.

:: Create build directory if it doesn't exist
if not exist "build" (
  echo Creating build directory...
  mkdir "build"
  if errorlevel 1 (
    echo Failed to create build directory.
    endlocal
    exit /b 1
  )
)

pushd "build" || (
  echo Failed to enter build directory.
  endlocal
  exit /b 1
)

echo Running CMake configure...
REM For single-config generators this sets CMAKE_BUILD_TYPE; for multi-config it's ignored.
cmake .. -DCMAKE_BUILD_TYPE=%CONFIG%
if errorlevel 1 (
  echo CMake configuration failed.
  popd
  endlocal
  exit /b 1
)

echo Building project...
REM Use CMake's --parallel for parallel build if supported; falls back if not supported by older CMake.
set "JOBS=%NUMBER_OF_PROCESSORS%"
if "%JOBS%"=="" set "JOBS=2"

cmake --build . --config %CONFIG% --parallel %JOBS%
if errorlevel 1 (
  echo Build failed.
  popd
  endlocal
  exit /b 1
)

echo Running tests with CTest...
ctest --output-on-failure -C %CONFIG%
if errorlevel 1 (
  echo Some tests failed.
  popd
  endlocal
  exit /b 1
)

echo.
echo All steps completed successfully.
popd
endlocal
exit /b 0
