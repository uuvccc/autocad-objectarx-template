@echo off
chcp 65001 >nul
echo ========================================
echo Rebuild Project (Clean + Build)
echo ========================================
echo.

echo [步骤 1/2] 清理旧文件...
call clean.bat
if %errorlevel% neq 0 (
    echo [错误] 清理失败
    exit /b 1
)

echo.
echo [步骤 2/2] 重新构建...
call build.bat
if %errorlevel% neq 0 (
    echo [错误] 构建失败
    exit /b 1
)

echo.
echo ========================================
echo 重新构建完成！
echo ========================================
pause
