@echo off
chcp 65001 >nul
echo ========================================
echo AutoCAD ObjectARX Plugin Build Script
echo ========================================
echo.

REM 检查 CMake 是否安装
where cmake >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 CMake，请先安装 CMake 并添加到 PATH
    pause
    exit /b 1
)

REM 创建构建目录
if not exist "build" mkdir build
cd build

echo [1/3] 配置 CMake...
cmake .. -G "Visual Studio 17 2022" -A x64
if %errorlevel% neq 0 (
    echo [错误] CMake 配置失败
    cd ..
    pause
    exit /b 1
)

echo.
echo [2/3] 编译项目...
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo [错误] 编译失败
    cd ..
    pause
    exit /b 1
)

echo.
echo [3/3] 构建完成！
echo.
echo ARX 文件位置: %~dp0bin\MyPlugin.arx
echo.
cd ..

pause
