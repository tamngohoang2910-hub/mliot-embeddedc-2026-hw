@echo off


set BUILD_DIR=build
set TARGET_BIN=%BUILD_DIR%\app_firmware.bin

echo STEP 1: CLEANING BUILD DIRECTORY
if exist %BUILD_DIR% (
    echo Deleting existing build folder...
    rmdir /s /q %BUILD_DIR% >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Cannot delete build folder. Please close any open files inside it!
        goto :error
    )
) else (
    echo Deleting existing build folder...
)
echo.

echo STEP 2: CONFIGURING PROJECT WITH CMAKE
cmake -G Ninja -B %BUILD_DIR%
if %errorlevel% neq 0 (
    echo [ERROR] CMake configuration failed!
    goto :error
)
echo.

echo STEP 3: COMPILING FIRMWARE WITH NINJA
ninja -C %BUILD_DIR%
if %errorlevel% neq 0 (
    echo [ERROR] Compilation with Ninja failed!
    goto :error
)

rem Kiểm tra sự tồn tại của file binary trước khi nạp
if not exist "%TARGET_BIN%" (
    echo [ERROR] Cannot find firmware image: %TARGET_BIN%
    goto :error
)
echo.

echo STEP 4: FLASHING FIRMWARE TO TARGET MCU
echo Memory Programming...

rem Chạy lệnh nạp từ thư mục gốc, truyền đường dẫn chuẩn xác
STM32_Programmer_CLI -c port=SWD -w "%TARGET_BIN%" 0x08000000 -v -rst

if %errorlevel% neq 0 (
    echo [ERROR] Flashing failed! Check ST-Link connection or SWD wiring.
    goto :error
)

echo KẾT QUẢ MẪU NÈ
pause
exit /b 0

:error
echo.
echo [FAILED] Process stopped due to errors.
pause
exit /b 1