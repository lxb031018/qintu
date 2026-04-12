@echo off
echo ==========================================
echo    亲途 APP 认证流程完整测试
echo ==========================================
echo.

set BASE_URL=https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api-test

echo [步骤 1] 发送验证码
echo -------------------
set SEND_RESULT=$(curl -s -X POST %BASE_URL%/api/auth/send-code -H "Content-Type: application/json" -d "{\"phone_number\":\"+86 13800138000\"}")
echo %SEND_RESULT%
echo.

REM 提取 verification_id（简化处理，使用固定值）
echo [步骤 2] 验证验证码（使用 123456）
echo --------------------------------
set VERIFY_RESULT=$(curl -s -X POST %BASE_URL%/api/auth/verify-code -H "Content-Type: application/json" -d "{\"verification_id\":\"mock_vid_1775720760460\",\"verification_code\":\"123456\"}")
echo %VERIFY_RESULT%
echo.

echo [步骤 3] 用户注册
echo -----------------
set REGISTER_RESULT=$(curl -s -X POST %BASE_URL%/api/auth/sign-up -H "Content-Type: application/json" -d "{\"verification_token\":\"mock_vtoken_test\",\"phone_number\":\"+86 13800138000\"}")
echo %REGISTER_RESULT%
echo.

echo [步骤 4] 用户登录
echo -----------------
set LOGIN_RESULT=$(curl -s -X POST %BASE_URL%/api/auth/sign-in -H "Content-Type: application/json" -d "{\"verification_token\":\"mock_vtoken_test\"}")
echo %LOGIN_RESULT%
echo.

echo [步骤 5] 刷新令牌
echo -----------------
set REFRESH_RESULT=$(curl -s -X POST %BASE_URL%/api/auth/refresh-token -H "Content-Type: application/json" -d "{\"refresh_token\":\"refresh_test\"}")
echo %REFRESH_RESULT%
echo.

echo [步骤 6] 用户登出
echo -----------------
set LOGOUT_RESULT=$(curl -s -X POST %BASE_URL%/api/auth/sign-out -H "Content-Type: application/json" -H "Authorization: Bearer access_test" -d "{}")
echo %LOGOUT_RESULT%
echo.

echo ==========================================
echo    测试完成！
echo ==========================================
pause
