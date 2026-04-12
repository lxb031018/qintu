/**
 * 关系绑定系统 - 自动化测试脚本
 *
 * 测试完整绑定流程，无需真实手机号
 * 运行方式：node test-binding-flow.js
 */

const http = require('http');

// ==================== 配置 ====================
const BASE_URL = 'http://localhost:3000';
const API_PREFIX = '/api/bindings';

// 测试结果
const testResults = [];
let passCount = 0;
let failCount = 0;

// ==================== 工具函数 ====================

/**
 * 发送 HTTP 请求
 */
function request(method, path, data = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    
    const options = {
      hostname: url.hostname,
      port: url.port || 3000,
      path: url.pathname,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: json
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: body
          });
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

/**
 * 测试用例
 */
async function test(name, fn) {
  process.stdout.write(`🧪 测试: ${name} ... `);
  try {
    const result = await fn();
    if (result) {
      console.log('✅ 通过');
      testResults.push({ name, status: 'PASS' });
      passCount++;
    } else {
      console.log('❌ 失败');
      testResults.push({ name, status: 'FAIL', reason: '返回 false' });
      failCount++;
    }
  } catch (error) {
    console.log(`❌ 异常: ${error.message}`);
    testResults.push({ name, status: 'ERROR', reason: error.message });
    failCount++;
  }
}

/**
 * 断言函数
 */
function assert(condition, message) {
  if (!condition) {
    throw new Error(message || '断言失败');
  }
}

// ==================== 测试变量 ====================
let senderToken = 'mock_token_sender_001';
let receiverToken = 'mock_token_receiver_002';
let bindingId = null;
let pendingRequestId = null;

// ==================== 测试用例 ====================

async function runTests() {
  console.log('\n' + '='.repeat(60));
  console.log('🚀 关系绑定系统 - 自动化测试');
  console.log('='.repeat(60) + '\n');

  // 测试 1: 发送绑定请求
  await test('发送者 A 发送绑定请求给接收者 B', async () => {
    const res = await request('POST', `${API_PREFIX}/request-phone`, {
      receiver_phone: '+86 13800138002',
      sender_name: '发送者A'
    }, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 201, `期望 201，实际 ${res.statusCode}`);
    assert(res.data.message === '绑定请求已发送', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 2: 获取待确认请求
  await test('接收者 B 查看待确认请求', async () => {
    const res = await request('GET', `${API_PREFIX}/pending`, null, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(Array.isArray(res.data), '返回数据不是数组');
    assert(res.data.length > 0, '待确认请求列表为空');
    
    pendingRequestId = res.data[0].id;
    console.log(`\n   📋 待确认请求 ID: ${pendingRequestId}`);
    return true;
  });

  // 测试 3: 确认绑定
  await test('接收者 B 确认绑定', async () => {
    const res = await request('POST', `${API_PREFIX}/confirm-request`, {
      request_id: pendingRequestId
    }, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.message === '绑定成功', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 4: 获取绑定列表
  await test('发送者 A 查看绑定列表', async () => {
    const res = await request('GET', `${API_PREFIX}/my`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.total === 1, `绑定数量应为 1，实际 ${res.data.total}`);
    assert(res.data.as_sender === 1, `作为发送者数量应为 1`);
    assert(res.data.bindings.length === 1, `绑定列表长度应为 1`);
    
    bindingId = res.data.bindings[0].id;
    console.log(`\n   🔗 绑定 ID: ${bindingId}`);
    return true;
  });

  // 测试 5: 接收者查看绑定列表
  await test('接收者 B 查看绑定列表', async () => {
    const res = await request('GET', `${API_PREFIX}/my`, null, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.as_receiver === 1, `作为接收者数量应为 1`);
    return true;
  });

  // 测试 6: 重复绑定
  await test('重复绑定应被拒绝', async () => {
    const res = await request('POST', `${API_PREFIX}/request-phone`, {
      receiver_phone: '+86 13800138002',
      sender_name: '发送者A'
    }, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 409, `期望 409，实际 ${res.statusCode}`);
    assert(res.data.error_code === 'BINDING_EXISTS', `错误码不匹配: ${res.data.error_code}`);
    return true;
  });

  // 测试 7: 绑定自己
  await test('绑定自己应被拒绝', async () => {
    const res = await request('POST', `${API_PREFIX}/request-phone`, {
      receiver_phone: '+86 13800138001', // 假设这是发送者自己的号码
      sender_name: '发送者A'
    }, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 400, `期望 400，实际 ${res.statusCode}`);
    assert(res.data.error_code === 'SELF_BINDING', `错误码不匹配: ${res.data.error_code}`);
    return true;
  });

  // 测试 8: 未注册手机号
  await test('未注册手机号应返回 404', async () => {
    const res = await request('POST', `${API_PREFIX}/request-phone`, {
      receiver_phone: '+86 99999999999',
      sender_name: '发送者A'
    }, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 404, `期望 404，实际 ${res.statusCode}`);
    assert(res.data.error_code === 'USER_NOT_FOUND', `错误码不匹配: ${res.data.error_code}`);
    return true;
  });

  // 测试 9: 解除绑定
  await test('发送者 A 解除绑定', async () => {
    const res = await request('DELETE', `${API_PREFIX}/${bindingId}`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.message === '绑定关系已解除', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 10: 验证解除后绑定列表为空
  await test('解除绑定后列表应为空', async () => {
    const res = await request('GET', `${API_PREFIX}/my`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.total === 0, `绑定数量应为 0，实际 ${res.data.total}`);
    return true;
  });

  // 测试 11: 无权解绑他人绑定
  await test('无权解绑他人绑定关系', async () => {
    // 先用 sender 创建一个新绑定
    const createRes = await request('POST', `${API_PREFIX}/request-phone`, {
      receiver_phone: '+86 13800138002',
      sender_name: '发送者A'
    }, {
      'X-User-OpenID': senderToken
    });

    // 用 receiver 确认
    const pendingRes = await request('GET', `${API_PREFIX}/pending`, null, {
      'X-User-OpenID': receiverToken
    });
    const reqId = pendingRes.data[0].id;
    await request('POST', `${API_PREFIX}/confirm-request`, {
      request_id: reqId
    }, {
      'X-User-OpenID': receiverToken
    });

    // 尝试用无关用户解绑（模拟）
    const res = await request('DELETE', `${API_PREFIX}/${reqId}`, null, {
      'X-User-OpenID': 'mock_token_stranger_003'
    });

    assert(res.statusCode === 403, `期望 403，实际 ${res.statusCode}`);
    assert(res.data.error_code === 'PERMISSION_DENIED', `错误码不匹配: ${res.data.error_code}`);
    return true;
  });

  // ==================== 打印测试报告 ====================
  console.log('\n' + '='.repeat(60));
  console.log('📊 测试报告');
  console.log('='.repeat(60) + '\n');

  testResults.forEach((result, index) => {
    const icon = result.status === 'PASS' ? '✅' : '❌';
    console.log(`${index + 1}. ${icon} ${result.name}`);
    if (result.reason) {
      console.log(`   原因: ${result.reason}`);
    }
  });

  console.log('\n' + '-'.repeat(60));
  console.log(`总计: ${passCount + failCount} 个测试`);
  console.log(`✅ 通过: ${passCount}`);
  console.log(`❌ 失败: ${failCount}`);
  console.log('='.repeat(60) + '\n');

  if (failCount === 0) {
    console.log('🎉 所有测试通过！关系绑定系统工作正常。\n');
  } else {
    console.log(`⚠️  ${failCount} 个测试失败，请检查问题。\n`);
    process.exit(1);
  }
}

// ==================== 运行测试 ====================
runTests().catch(error => {
  console.error('\n❌ 测试运行异常:', error);
  console.error(error.stack);
  process.exit(1);
});
