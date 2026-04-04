/**
 * 亲途云函数部署测试脚本
 * 
 * 测试所有关键接口是否正常工作
 */

const https = require('https');

// ==================== 配置 ====================
// 网关访问入口
const BASE_URL = 'https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/api';

// 测试用户
const TEST_USER_1 = {
  openid: 'test_sender_001',
  phone: '+86 13800138001',
  nickname: '测试发送者',
  user_type: 'sender'
};

const TEST_USER_2 = {
  openid: 'test_receiver_001',
  phone: '+86 13800138002',
  nickname: '测试接收者',
  user_type: 'receiver'
};

// ==================== 工具函数 ====================

/**
 * 发送 HTTPS 请求
 */
function request(method, path, body = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    
    const options = {
      hostname: url.hostname,
      port: url.port || 443,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve({
            statusCode: res.statusCode,
            data: json,
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            data: data,
          });
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    if (body) {
      req.write(JSON.stringify(body));
    }

    req.end();
  });
}

/**
 * 打印测试结果
 */
function printResult(testName, success, result) {
  const icon = success ? '✅' : '❌';
  console.log(`${icon} ${testName}`);
  if (result) {
    console.log(`   状态码: ${result.statusCode}`);
    console.log(`   响应: ${JSON.stringify(result.data, null, 2).substring(0, 200)}...`);
  }
  console.log('');
}

// ==================== 测试用例 ====================

async function runTests() {
  console.log('🚀 开始测试亲途云函数部署情况...\n');
  console.log(`📡 测试地址: ${BASE_URL}\n`);
  console.log('=' .repeat(60));
  console.log('');

  const results = {
    total: 0,
    passed: 0,
    failed: 0,
  };

  // 测试 1: 健康检查
  results.total++;
  console.log(`📋 测试 ${results.total}: 健康检查`);
  try {
    const result = await request('GET', '/health');
    const success = result.statusCode === 200 && result.data.status === 'ok';
    if (success) results.passed++; else results.failed++;
    printResult('健康检查', success, result);
  } catch (e) {
    results.failed++;
    console.log('❌ 健康检查失败:', e.message, '\n');
  }

  // 测试 2: 用户注册（发送者）
  results.total++;
  console.log(`📋 测试 ${results.total}: 用户注册（发送者）`);
  try {
    const result = await request('POST', '/api/users/register', TEST_USER_1);
    const success = result.statusCode === 200 || result.statusCode === 201 || 
                    (result.statusCode === 409 && result.data.code === 'USER_EXISTS');
    if (success) results.passed++; else results.failed++;
    printResult('用户注册（发送者）', success, result);
  } catch (e) {
    results.failed++;
    console.log('❌ 用户注册失败:', e.message, '\n');
  }

  // 测试 3: 用户注册（接收者）
  results.total++;
  console.log(`📋 测试 ${results.total}: 用户注册（接收者）`);
  try {
    const result = await request('POST', '/api/users/register', TEST_USER_2);
    const success = result.statusCode === 200 || result.statusCode === 201 || 
                    (result.statusCode === 409 && result.data.code === 'USER_EXISTS');
    if (success) results.passed++; else results.failed++;
    printResult('用户注册（接收者）', success, result);
  } catch (e) {
    results.failed++;
    console.log('❌ 用户注册失败:', e.message, '\n');
  }

  // 测试 4: 获取用户信息
  results.total++;
  console.log(`📋 测试 ${results.total}: 获取用户信息`);
  try {
    const result = await request('GET', '/api/users/me', null, {
      'X-User-OpenID': TEST_USER_1.openid,
    });
    const success = result.statusCode === 200;
    if (success) results.passed++; else results.failed++;
    printResult('获取用户信息', success, result);
  } catch (e) {
    results.failed++;
    console.log('❌ 获取用户信息失败:', e.message, '\n');
  }

  // 测试 5: 生成绑定码
  results.total++;
  console.log(`📋 测试 ${results.total}: 生成绑定码`);
  try {
    const result = await request('POST', '/api/bindings/generate', {}, {
      'X-User-OpenID': TEST_USER_1.openid,
    });
    const success = result.statusCode === 200 || result.statusCode === 201;
    if (success) results.passed++; else results.failed++;
    printResult('生成绑定码', success, result);
    
    // 保存绑定码供后续测试使用
    const bindCode = result.data?.data?.bind_code;
    if (bindCode) {
      console.log(`   💡 生成的绑定码: ${bindCode}\n`);
    }
  } catch (e) {
    results.failed++;
    console.log('❌ 生成绑定码失败:', e.message, '\n');
  }

  // 测试 6: 获取绑定列表
  results.total++;
  console.log(`📋 测试 ${results.total}: 获取绑定列表`);
  try {
    const result = await request('GET', '/api/bindings/my', null, {
      'X-User-OpenID': TEST_USER_1.openid,
    });
    const success = result.statusCode === 200;
    if (success) results.passed++; else results.failed++;
    printResult('获取绑定列表', success, result);
  } catch (e) {
    results.failed++;
    console.log('❌ 获取绑定列表失败:', e.message, '\n');
  }

  // 测试 7: 404 测试
  results.total++;
  console.log(`📋 测试 ${results.total}: 404 处理`);
  try {
    const result = await request('GET', '/api/not-found');
    const success = result.statusCode === 404;
    if (success) results.passed++; else results.failed++;
    printResult('404 处理', success, result);
  } catch (e) {
    results.failed++;
    console.log('❌ 404 测试失败:', e.message, '\n');
  }

  // 测试 8: 无认证访问
  results.total++;
  console.log(`📋 测试 ${results.total}: 无认证拒绝`);
  try {
    const result = await request('GET', '/api/users/me');
    const success = result.statusCode === 401;
    if (success) results.passed++; else results.failed++;
    printResult('无认证拒绝', success, result);
  } catch (e) {
    results.failed++;
    console.log('❌ 无认证测试失败:', e.message, '\n');
  }

  // 测试结果汇总
  console.log('=' .repeat(60));
  console.log('');
  console.log('📊 测试结果汇总:');
  console.log(`   总测试数: ${results.total}`);
  console.log(`   ✅ 通过: ${results.passed}`);
  console.log(`   ❌ 失败: ${results.failed}`);
  console.log(`   通过率: ${((results.passed / results.total) * 100).toFixed(1)}%`);
  console.log('');

  if (results.failed === 0) {
    console.log('🎉 所有测试通过！云函数部署成功！');
  } else {
    console.log('⚠️  部分测试失败，请检查部署配置。');
    console.log('💡 常见失败原因：');
    console.log('   - 数据库未配置或连接失败');
    console.log('   - 环境变量配置错误');
    console.log('   - HTTP 访问路径未创建');
  }
  console.log('');
}

// 运行测试
runTests().catch(e => {
  console.error('❌ 测试运行失败:', e.message);
  process.exit(1);
});
