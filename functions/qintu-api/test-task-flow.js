/**
 * 导航任务系统 - 自动化测试脚本
 *
 * 测试完整导航任务流程：创建 → 接受 → 开始 → 完成/取消
 * 运行方式：node test-task-flow.js
 */

const http = require('http');

// ==================== 配置 ====================
const BASE_URL = 'http://localhost:3000';
const API_PREFIX = '/api/tasks';
const BINDING_PREFIX = '/api/bindings';
const LOCATION_PREFIX = '/api/locations';

// 测试结果
const testResults = [];
let passCount = 0;
let failCount = 0;

// ==================== 工具函数 ====================

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

function assert(condition, message) {
  if (!condition) {
    throw new Error(message || '断言失败');
  }
}

// ==================== 测试变量 ====================
const senderToken = 'mock_token_sender_001';
const receiverToken = 'mock_token_receiver_002';
let taskId = null;

// ==================== 辅助函数 ====================

/**
 * 创建绑定关系（导航任务的前提）
 */
async function createBinding() {
  // 发送绑定请求
  await request('POST', `${BINDING_PREFIX}/request-phone`, {
    receiver_phone: '+86 13800138002',
    sender_name: '发送者A'
  }, { 'X-User-OpenID': senderToken });

  // 获取待确认请求
  const pendingRes = await request('GET', `${BINDING_PREFIX}/pending`, null, {
    'X-User-OpenID': receiverToken
  });

  if (pendingRes.data.length > 0) {
    // 确认绑定
    await request('POST', `${BINDING_PREFIX}/confirm-request`, {
      request_id: pendingRes.data[0].id
    }, { 'X-User-OpenID': receiverToken });
  }
}

// ==================== 测试用例 ====================

async function runTests() {
  console.log('\n' + '='.repeat(60));
  console.log('🚀 导航任务系统 - 自动化测试');
  console.log('='.repeat(60) + '\n');

  // 前置准备：创建绑定关系
  console.log('📦 前置准备：创建绑定关系...');
  await createBinding();
  console.log('✅ 绑定关系已创建\n');

  // 测试 1: 创建导航任务
  await test('发送者 A 创建导航任务', async () => {
    const res = await request('POST', API_PREFIX, {
      receiver_openid: 'mock_token_receiver_002',
      start_name: '当前位置',
      start_latitude: 39.908823,
      start_longitude: 116.397470,
      end_name: '北京天安门',
      end_latitude: 39.904690,
      end_longitude: 116.407164,
      end_address: '北京市东城区天安门广场',
      transport_mode: 'drive',
      route_data: {
        paths: [{
          steps: [
            { instruction: '向东行驶', distance: 100, duration: 60 },
            { instruction: '右转', distance: 200, duration: 120 }
          ]
        }]
      },
      route_summary: {
        distance: 300,
        duration: 180
      }
    }, { 'X-User-OpenID': senderToken });

    assert(res.statusCode === 201, `期望 201，实际 ${res.statusCode}`);
    assert(res.data.task_id, '缺少 task_id');
    
    taskId = res.data.task_id;
    console.log(`\n   📍 任务 ID: ${taskId}`);
    return true;
  });

  // 测试 2: 接收者查看待处理任务
  await test('接收者 B 查看待处理任务', async () => {
    const res = await request('GET', `${API_PREFIX}/pending`, null, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(Array.isArray(res.data), '返回数据不是数组');
    assert(res.data.length > 0, '待处理任务列表为空');
    assert(res.data[0].task_id === taskId, '任务 ID 不匹配');
    return true;
  });

  // 测试 3: 发送者查看自己的任务列表
  await test('发送者 A 查看我的任务列表', async () => {
    const res = await request('GET', `${API_PREFIX}/my?role=sender`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.tasks, '缺少 tasks 字段');
    assert(res.data.tasks.length > 0, '任务列表为空');
    return true;
  });

  // 测试 4: 查看任务详情
  await test('查看任务详情', async () => {
    const res = await request('GET', `${API_PREFIX}/${taskId}`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.task, '缺少 task 字段');
    assert(res.data.task.task_id === taskId, '任务 ID 不匹配');
    assert(res.data.task.status === 'waiting', `状态应为 waiting，实际 ${res.data.task.status}`);
    return true;
  });

  // 测试 5: 接收者接受任务
  await test('接收者 B 接受任务', async () => {
    const res = await request('POST', `${API_PREFIX}/${taskId}/accept`, null, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.message === '任务已接受', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 6: 验证任务状态已更新
  await test('验证任务状态已更新为 accepted', async () => {
    const res = await request('GET', `${API_PREFIX}/${taskId}`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.task.status === 'accepted', `状态应为 accepted，实际 ${res.data.task.status}`);
    return true;
  });

  // 测试 7: 接收者开始导航
  await test('接收者 B 开始导航', async () => {
    const res = await request('POST', `${API_PREFIX}/${taskId}/start`, null, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.message === '导航已开始', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 8: 验证任务状态为 navigating
  await test('验证任务状态已更新为 navigating', async () => {
    const res = await request('GET', `${API_PREFIX}/${taskId}`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.task.status === 'navigating', `状态应为 navigating，实际 ${res.data.task.status}`);
    return true;
  });

  // 测试 9: 接收者更新位置
  await test('接收者 B 更新实时位置', async () => {
    const res = await request('POST', `${LOCATION_PREFIX}/update`, {
      latitude: 39.905000,
      longitude: 116.405000,
      accuracy: 10.5,
      speed: 45.0,
      bearing: 90.0
    }, { 'X-User-OpenID': receiverToken });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.message === '位置已更新', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 10: 发送者查看接收者位置
  await test('发送者 A 查看接收者位置', async () => {
    const res = await request('GET', `${LOCATION_PREFIX}/mock_token_receiver_002`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.location, '缺少 location 字段');
    assert(Math.abs(res.data.location.latitude - 39.905000) < 0.001, '纬度不匹配');
    assert(Math.abs(res.data.location.longitude - 116.405000) < 0.001, '经度不匹配');
    return true;
  });

  // 测试 11: 接收者完成任务
  await test('接收者 B 完成任务', async () => {
    const res = await request('POST', `${API_PREFIX}/${taskId}/finish`, null, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.message === '任务已完成', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 12: 验证任务状态为 finished
  await test('验证任务状态已更新为 finished', async () => {
    const res = await request('GET', `${API_PREFIX}/${taskId}`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.task.status === 'finished', `状态应为 finished，实际 ${res.data.task.status}`);
    return true;
  });

  // 测试 13: 创建新任务测试取消流程
  await test('创建新任务测试取消流程', async () => {
    const res = await request('POST', API_PREFIX, {
      receiver_openid: 'mock_token_receiver_002',
      end_name: '测试地点',
      end_latitude: 39.910000,
      end_longitude: 116.410000,
      transport_mode: 'walk'
    }, { 'X-User-OpenID': senderToken });

    assert(res.statusCode === 201, `期望 201，实际 ${res.statusCode}`);
    taskId = res.data.task_id;
    return true;
  });

  // 测试 14: 发送者取消任务
  await test('发送者 A 取消任务', async () => {
    const res = await request('POST', `${API_PREFIX}/${taskId}/cancel`, {
      reason: '测试取消'
    }, { 'X-User-OpenID': senderToken });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
    assert(res.data.message === '任务已取消', `消息不匹配: ${res.data.message}`);
    return true;
  });

  // 测试 15: 权限验证 - 接收者不能创建任务
  await test('接收者创建任务应被拒绝', async () => {
    const res = await request('POST', API_PREFIX, {
      receiver_openid: 'mock_token_receiver_002',
      end_name: '测试地点',
      end_latitude: 39.910000,
      end_longitude: 116.410000,
      transport_mode: 'walk'
    }, { 'X-User-OpenID': receiverToken });

    assert(res.statusCode === 403, `期望 403，实际 ${res.statusCode}`);
    return true;
  });

  // 测试 16: 权限验证 - 发送者不能接受任务
  await test('发送者接受任务应被拒绝', async () => {
    // 先创建一个任务
    const createRes = await request('POST', API_PREFIX, {
      receiver_openid: 'mock_token_receiver_002',
      end_name: '测试地点',
      end_latitude: 39.910000,
      end_longitude: 116.410000,
      transport_mode: 'walk'
    }, { 'X-User-OpenID': senderToken });

    const newTaskId = createRes.data.task_id;

    // 发送者尝试接受
    const res = await request('POST', `${API_PREFIX}/${newTaskId}/accept`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 403, `期望 403，实际 ${res.statusCode}`);
    return true;
  });

  // 测试 17: 无效任务 ID
  await test('查看无效任务 ID 应返回 404', async () => {
    const res = await request('GET', `${API_PREFIX}/invalid-task-id`, null, {
      'X-User-OpenID': senderToken
    });

    assert(res.statusCode === 404, `期望 404，实际 ${res.statusCode}`);
    return true;
  });

  // 测试 18: 位置共享切换
  await test('接收者切换位置共享状态', async () => {
    const res = await request('POST', `${LOCATION_PREFIX}/sharing/toggle`, null, {
      'X-User-OpenID': receiverToken
    });

    assert(res.statusCode === 200, `期望 200，实际 ${res.statusCode}`);
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
    console.log('🎉 所有测试通过！导航任务系统工作正常。\n');
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
