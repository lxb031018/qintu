@echo off
chcp 65001 >nul
echo ==========================================
echo    亲途 APP 本地开发服务器
echo ==========================================
echo.

REM 检查 Node.js 是否安装
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Node.js
    echo 请先安装 Node.js: https://nodejs.org/
    pause
    exit /b 1
)

echo [1/3] 检查依赖...
if not exist "node_modules" (
    echo 首次运行，正在安装依赖...
    call npm install
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
) else (
    echo 依赖已存在
)

echo.
echo [2/3] 启动服务器...
echo.
echo ==========================================
echo  服务器地址: http://localhost:9000
echo  健康检查:   http://localhost:9000/health
echo  API 地址:   http://localhost:9000/api/*
echo ==========================================
echo.
echo [提示] 按 Ctrl+C 可停止服务器
echo.

REM 启动服务器
node index.js

pause
