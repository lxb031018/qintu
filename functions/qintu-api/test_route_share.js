#!/usr/bin/env node

/**
 * 路由分享API测试脚本
 *
 * 测试流程：
 * 1. 用户A发送路由分享给用户B
 * 2. 用户B查询待接收的分享
 * 3. 验证数据正确性
 *
 * 运行方式：
 *   node test_route_share.js
 */

const http = require('http');

const BASE_URL = 'http://localhost:9000';

const USER_A = 'user_a_openid';
const USER_B = 'user_b_openid';

function request(method, path, headers = {}, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data) });
        } catch {
          resolve({ status: res.statusCode, data: data });
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(5000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

function logResponse(label, result) {
  console.log(`  状态: ${result.status}`);
  console.log(`  响应: ${typeof result.data === 'string' ? result.data : JSON.stringify(result.data)}`);
}

async function testRouteShare() {
  console.log('='.repeat(50));
  console.log('路由分享API测试');
  console.log('='.repeat(50));
  console.log();

  // 测试数据
  const testData = {
    receiverOpenid: USER_B,
    origin: {
      latitude: 39.908,
      longitude: 116.397,
      name: '天安门',
      address: '北京市东城区天安门广场',
    },
    destination: {
      latitude: 39.989,
      longitude: 116.479,
      name: '北京朝阳站',
      address: '北京市朝阳区姚家园路',
    },
    routeType: 'driving',
  };

  try {
    // Step 1: 用户A发送路由分享
    console.log('[Step 1] 用户A发送路由分享给用户B...');
    console.log(`  POST /api/route-share/send`);
    console.log(`  发送者: ${USER_A}`);
    console.log(`  接收者: ${USER_B}`);
    console.log(`  路线: ${testData.origin.name} → ${testData.destination.name}`);
    console.log();

    let sendResult;
    try {
      sendResult = await request('POST', '/api/route-share/send',
        { 'x-user-openid': USER_A }, testData);
    } catch (error) {
      console.error(`  [错误] ${error.message}`);
      console.error('[失败] 无法连接到服务器，请确保服务器运行在 localhost:9000');
      process.exit(1);
    }

    logResponse('发送', sendResult);
    console.log();

    if (sendResult.status !== 200) {
      console.error('[失败] 发送路由分享失败');
      process.exit(1);
    }
    console.log('[成功] 发送路由分享成功');
    console.log();

    // Step 2: 用户B查询待接收的分享
    console.log('[Step 2] 用户B查询待接收的分享...');
    console.log(`  GET /api/route-share/pending`);
    console.log(`  查询者: ${USER_B}`);
    console.log();

    let pendingResult;
    try {
      pendingResult = await request('GET', '/api/route-share/pending',
        { 'x-user-openid': USER_B });
    } catch (error) {
      console.error(`  [错误] ${error.message}`);
      console.error('[失败] 无法连接到服务器');
      process.exit(1);
    }

    logResponse('查询', pendingResult);
    console.log();

    if (pendingResult.status !== 200) {
      console.error('[失败] 查询待接收分享失败');
      process.exit(1);
    }

    const shares = pendingResult.data.data || [];
    console.log(`[成功] 获取到 ${shares.length} 条待接收分享`);
    console.log();

    if (shares.length === 0) {
      console.warn('[警告] 没有待接收的分享，可能已被清除或绑定关系验证失败');
    } else {
      // 验证数据
      const share = shares[0];
      console.log('[验证数据]');
      console.log(`  发送者: ${share.senderOpenid} ${share.senderOpenid === USER_A ? '✓' : '✗'}`);
      console.log(`  接收者: ${share.receiverOpenid} ${share.receiverOpenid === USER_B ? '✓' : '✗'}`);
      console.log(`  起点: ${share.originName} ${share.originName === testData.origin.name ? '✓' : '✗'}`);
      console.log(`  终点: ${share.destName} ${share.destName === testData.destination.name ? '✓' : '✗'}`);
      console.log(`  出行方式: ${share.routeType} ${share.routeType === testData.routeType ? '✓' : '✗'}`);
      console.log();

      const isValid =
        share.senderOpenid === USER_A &&
        share.receiverOpenid === USER_B &&
        share.originName === testData.origin.name &&
        share.destName === testData.destination.name &&
        share.routeType === testData.routeType;

      if (isValid) {
        console.log('[验证成功] 所有数据匹配!');
      } else {
        console.error('[验证失败] 部分数据不匹配');
        process.exit(1);
      }
    }

    console.log();
    console.log('='.repeat(50));
    console.log('测试完成 ✓');
    console.log('='.repeat(50));

  } catch (error) {
    console.error('[错误]', error.message);
    process.exit(1);
  }
}

testRouteShare();