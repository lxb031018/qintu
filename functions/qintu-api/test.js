/**
 * 本地测试脚本
 * 
 * 用于在本地测试云函数接口
 */

const http = require('http');

const BASE_URL = 'http://localhost:9000';

/**
 * 发送 HTTP 请求
 */
async function request(method, path, body = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    };

    const req = http.request(options, (res) => {
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
 * 测试函数
 */
async function runTests() {
  console.log('🚀 开始测试云函数...\n');

  // 测试 1: 健康检查
  console.log('📋 测试 1: 健康检查');
  try {
    const result = await request('GET', '/health');
    console.log('✅ 状态码:', result.statusCode);
    console.log('✅ 响应:', JSON.stringify(result.data, null, 2));
  } catch (e) {
    console.log('❌ 错误:', e.message);
  }
  console.log('');

  // 测试 2: 用户注册
  console.log('📋 测试 2: 用户注册');
  try {
    const result = await request('POST', '/api/users/register', {
      openid: 'test_openid_123',
      phone: '+86 13800138000',
      nickname: '测试用户',
      user_type: 'both',
    });
    console.log('✅ 状态码:', result.statusCode);
    console.log('✅ 响应:', JSON.stringify(result.data, null, 2));
  } catch (e) {
    console.log('❌ 错误:', e.message);
  }
  console.log('');

  // 测试 3: 获取用户信息
  console.log('📋 测试 3: 获取用户信息');
  try {
    const result = await request('GET', '/api/users/me', null, {
      'X-User-OpenID': 'test_openid_123',
    });
    console.log('✅ 状态码:', result.statusCode);
    console.log('✅ 响应:', JSON.stringify(result.data, null, 2));
  } catch (e) {
    console.log('❌ 错误:', e.message);
  }
  console.log('');

  // 测试 4: 生成绑定码
  console.log('📋 测试 4: 生成绑定码');
  try {
    const result = await request('POST', '/api/bindings/generate', {}, {
      'X-User-OpenID': 'test_openid_123',
    });
    console.log('✅ 状态码:', result.statusCode);
    console.log('✅ 响应:', JSON.stringify(result.data, null, 2));
  } catch (e) {
    console.log('❌ 错误:', e.message);
  }
  console.log('');

  // 测试 5: 404 测试
  console.log('📋 测试 5: 404 测试');
  try {
    const result = await request('GET', '/api/not-found');
    console.log('✅ 状态码:', result.statusCode);
    console.log('✅ 响应:', JSON.stringify(result.data, null, 2));
  } catch (e) {
    console.log('❌ 错误:', e.message);
  }
  console.log('');

  console.log('✅ 测试完成！');
}

// 运行测试
runTests().catch(console.error);
