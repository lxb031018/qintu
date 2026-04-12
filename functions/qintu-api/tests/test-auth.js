/**
 * 认证路由测试脚本
 * 
 * 测试所有认证端点（模拟模式）
 * 使用方法: node test-auth.js
 */

const axios = require('axios');

// 配置
const BASE_URL = 'https://qintu-cloudebase-5f5bpuj13bc6467.api.tcloudbasegateway.com/v1/functions/qintu-api?webfn=true';
const PUBLISHABLE_KEY = process.env.CLOUDBASE_PUBLISHABLE_KEY || 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjlkMWRjMzFlLWI0ZDAtNDQ4Yi1hNzZmLWIwY2M2M2Q4MTQ5OCJ9.eyJpc3MiOiJodHRwczovL3FpbnR1LWNsb3VkZWJhc2UtNWY1YnB1ajEzYmM2NDY3LmFwLXNoYW5naGFpLnRjYi1hcGkudGVuY2VudGNsb3VkYXBpLmNvbSIsInN1YiI6ImFub24iLCJhdWQiOiJxaW50dS1jbG91ZGViYXNlLTVmNWJwdWoxM2JjNjQ2NyIsImV4cCI6NDA3ODg3MDg5MywiaWF0IjoxNzc1MTg3NjkzLCJub25jZSI6IjZOeTVQbHBtU215WHdIZjZ2eWFnTlEiLCJhdF9oYXNoIjoiNk55NVBscG1TbXlYd0hmNnZ5YWdOUSIsIm5hbWUiOiJBbm9ueW1vdXMiLCJzY29wZSI6ImFub255bW91cyIsInByb2plY3RfaWQiOiJxaW50dS1jbG91ZGViYXNlLTVmNWJwdWoxM2JjNjQ2NyIsIm1ldGEiOnsicGxhdGZvcm0iOiJQdWJsaXNoYWJsZUtleSJ9LCJ1c2VyX3R5cGUiOiIiLCJjbGllbnRfdHlwZSI6ImNsaWVudF91c2VyIiwiaXNfc3lzdGVtX2FkbWluIjpmYWxzZX0.oLl3ED22kCq_1tnWzxGb-jV4xsJMNlsnLBZ_eEptkGs5Q0Wfe3T75HC3HsuAbFogS7PnlLBieLkYLXGflMdz_IZN_RUZCd4SC9HTH1N9wf4Ov7OfucNO1qQgpaQU74XUAWC70gwnRsNjnmXOgKuDI0-iPOzsMSPWtV-3ci95zFlu2oG1EF7A3M0NWBuS5nNkYeLfQLWskNHt-4bnsNjGvStGKbs2Kz7JqI2PoV07an9WcfOtVKXafzCJwLJUesrlR2jq6d15pbBSStsPgZ4EAkMBzPsBUJFiq8SKhsTOgwhhLow3Ax_JcnhYXcUH43iJ11ky4n7BCemx_r_hbus0Ow';

const headers = {
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${PUBLISHABLE_KEY}`
};

// 测试手机号
const TEST_PHONE = '+86 13800138000';

async function testSendCode() {
  console.log('\n========== 测试 1: 发送验证码 ==========');
  try {
    const response = await axios.post(
      `${BASE_URL}/api/auth/send-code`,
      { phone_number: TEST_PHONE },
      { headers }
    );
    console.log('✅ 发送验证码成功');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return response.data.data.verification_id;
  } catch (error) {
    console.error('❌ 发送验证码失败');
    console.error('Error:', error.response?.data || error.message);
    return null;
  }
}

async function testVerifyCode(verificationId) {
  console.log('\n========== 测试 2: 验证验证码 ==========');
  try {
    const response = await axios.post(
      `${BASE_URL}/api/auth/verify-code`,
      { 
        verification_id: verificationId,
        verification_code: '123456' // 模拟模式的固定验证码
      },
      { headers }
    );
    console.log('✅ 验证验证码成功');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return response.data.data.verification_token;
  } catch (error) {
    console.error('❌ 验证验证码失败');
    console.error('Error:', error.response?.data || error.message);
    return null;
  }
}

async function testSignUp(verificationToken) {
  console.log('\n========== 测试 3: 用户注册 ==========');
  try {
    const response = await axios.post(
      `${BASE_URL}/api/auth/sign-up`,
      { 
        verification_token: verificationToken,
        phone_number: TEST_PHONE
      },
      { headers }
    );
    console.log('✅ 用户注册成功');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return response.data.data;
  } catch (error) {
    console.error('❌ 用户注册失败');
    console.error('Error:', error.response?.data || error.message);
    // 如果用户已存在，继续测试登录
    if (error.response?.data?.code === 'USER_ALREADY_EXISTS') {
      console.log('⚠️  用户已存在，将继续测试登录');
      return null;
    }
    return null;
  }
}

async function testSignIn(verificationToken) {
  console.log('\n========== 测试 4: 用户登录 ==========');
  try {
    // 首先需要再次发送和验证验证码（因为之前的 token 已使用）
    const sendRes = await axios.post(
      `${BASE_URL}/api/auth/send-code`,
      { phone_number: TEST_PHONE },
      { headers }
    );
    const vid = sendRes.data.data.verification_id;
    
    const verifyRes = await axios.post(
      `${BASE_URL}/api/auth/verify-code`,
      { 
        verification_id: vid,
        verification_code: '123456'
      },
      { headers }
    );
    const vtoken = verifyRes.data.data.verification_token;

    const response = await axios.post(
      `${BASE_URL}/api/auth/sign-in`,
      { verification_token: vtoken },
      { headers }
    );
    console.log('✅ 用户登录成功');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return response.data.data;
  } catch (error) {
    console.error('❌ 用户登录失败');
    console.error('Error:', error.response?.data || error.message);
    return null;
  }
}

async function testRefreshToken(refreshToken) {
  console.log('\n========== 测试 5: 刷新令牌 ==========');
  try {
    const response = await axios.post(
      `${BASE_URL}/api/auth/refresh-token`,
      { refresh_token: refreshToken },
      { headers }
    );
    console.log('✅ 刷新令牌成功');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return response.data.data;
  } catch (error) {
    console.error('❌ 刷新令牌失败');
    console.error('Error:', error.response?.data || error.message);
    return null;
  }
}

async function testSignOut(accessToken) {
  console.log('\n========== 测试 6: 用户登出 ==========');
  try {
    const response = await axios.post(
      `${BASE_URL}/api/auth/sign-out`,
      {},
      { 
        headers: {
          ...headers,
          'Authorization': `Bearer ${accessToken}`
        }
      }
    );
    console.log('✅ 用户登出成功');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return true;
  } catch (error) {
    console.error('❌ 用户登出失败');
    console.error('Error:', error.response?.data || error.message);
    return false;
  }
}

async function runTests() {
  console.log('🚀 开始测试云函数认证流程...');
  console.log('Base URL:', BASE_URL);

  // 测试发送验证码
  const verificationId = await testSendCode();
  if (!verificationId) {
    console.log('\n❌ 测试中断：发送验证码失败');
    return;
  }

  // 等待一下
  await new Promise(resolve => setTimeout(resolve, 500));

  // 测试验证码验证
  const verificationToken = await testVerifyCode(verificationId);
  if (!verificationToken) {
    console.log('\n❌ 测试中断：验证验证码失败');
    return;
  }

  // 等待一下
  await new Promise(resolve => setTimeout(resolve, 500));

  // 测试注册（可能失败，因为用户可能已存在）
  const signupResult = await testSignUp(verificationToken);
  
  // 等待一下
  await new Promise(resolve => setTimeout(resolve, 500));

  // 测试登录（会重新发送和验证验证码）
  const loginResult = await testSignIn(verificationToken);
  if (!loginResult) {
    console.log('\n❌ 测试中断：登录失败');
    return;
  }

  const { access_token, refresh_token } = loginResult;

  // 等待一下
  await new Promise(resolve => setTimeout(resolve, 500));

  // 测试刷新令牌
  const refreshResult = await testRefreshToken(refresh_token);

  // 等待一下
  await new Promise(resolve => setTimeout(resolve, 500));

  // 测试登出
  await testSignOut(access_token);

  console.log('\n========== 测试完成 ==========');
}

// 运行测试
runTests().catch(console.error);
