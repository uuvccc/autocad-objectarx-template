@echo off
chcp 65001 >nul
echo ========================================
echo Clean Build Files
echo ========================================
echo.

if exist "build" (
    echo [清理] 删除 build 目录...
    rmdir /s /q build
)

if exist "bin" (
    echo [清理] 删除 bin 目录...
    rmdir /s /q bin
)

if exist "*.user" (
    echo [清理] 删除用户配置文件...
    del /q *.user
)

echo.
echo [完成] 清理完成！
echo.
pause
