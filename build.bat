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

REM ============================================================================
REM 设置 ObjectARX SDK 路径（按优先级）：
REM   1. 命令行参数: build.bat "C:\path\to\ObjectARX_SDK"
REM   2. 环境变量 OBJECTARX_ROOT
REM   3. 此处默认值（取消注释并修改）
REM ============================================================================
if "%~1" neq "" (
    set "OBJECTARX_ROOT=%~1"
    echo [信息] 使用命令行参数指定 ARX 路径: %~1
) else if defined OBJECTARX_ROOT (
    echo [信息] 使用环境变量 OBJECTARX_ROOT: %OBJECTARX_ROOT%
) else (
    echo [错误] 未设置 ObjectARX SDK 路径
    echo.
    echo   方式1 - 命令行参数:
    echo     build.bat "C:\path\to\ObjectARX_SDK"
    echo.
    echo   方式2 - 环境变量:
    echo     set OBJECTARX_ROOT=C:\path\to\ObjectARX_SDK
    echo     build.bat
    echo.
    echo   方式3 - 直接修改 build.bat 中的默认值
    pause
    exit /b 1
)

REM 创建构建目录
if not exist "build" mkdir build
cd build

REM 自动检测已安装的 Visual Studio 版本，生成对应 Generator
set CMAKE_GENERATOR=
for %%V in (17 16 15) do (
    if not defined CMAKE_GENERATOR (
        cmake --help-generator-list 2>nul | findstr /C:"Visual Studio %%V" >nul
        if not errorlevel 1 (
            for /f "tokens=*" %%G in ('cmake --help-generator-list 2^>nul ^| findstr /C:"Visual Studio %%V"') do (
                set "CMAKE_GENERATOR=%%G"
            )
        )
    )
)

if not defined CMAKE_GENERATOR (
    echo [警告] 未检测到 Visual Studio 生成器，使用 CMake 默认生成器
    set "CMAKE_CMD=cmake .. -A x64 -DOBJECTARX_ROOT=%OBJECTARX_ROOT%"
) else (
    echo [信息] 使用生成器: %CMAKE_GENERATOR%
    set "CMAKE_CMD=cmake .. -G "%CMAKE_GENERATOR%" -A x64 -DOBJECTARX_ROOT=%OBJECTARX_ROOT%"
)

echo [1/3] 配置 CMake...
%CMAKE_CMD%
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
