/**
 * 测试 CloudBase 云函数连接
 */

const https = require('https');

const testUrls = [
  // 1. 测试健康检查（不带云函数前缀）
  'https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/health',
  // 2. 测试云函数健康检查
  'https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/health',
  // 3. 测试 API 路由
  'https://qintu-cloudebase-5f5bpuj13bc6467.service.tcloudbase.com/qintu-api/api/bindings/my',
];

function testUrl(url) {
  return new Promise((resolve, reject) => {
    console.log(`\n测试: ${url}`);
    const start = Date.now();
    
    https.get(url, { timeout: 10000 }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        const duration = Date.now() - start;
        console.log(`✅ 响应成功 (${duration}ms)`);
        console.log(`状态码: ${res.statusCode}`);
        console.log(`响应: ${data.substring(0, 200)}`);
        resolve({ success: true, statusCode: res.statusCode, duration });
      });
    }).on('error', (err) => {
      const duration = Date.now() - start;
      console.log(`❌ 请求失败 (${duration}ms)`);
      console.log(`错误: ${err.message}`);
      resolve({ success: false, error: err.message, duration });
    }).on('timeout', () => {
      console.log('⏱️  请求超时');
      resolve({ success: false, error: 'timeout' });
    });
  });
}

async function runTests() {
  console.log('========== CloudBase 连接测试 ==========\n');
  
  for (const url of testUrls) {
    await testUrl(url);
  }
  
  console.log('\n========== 测试完成 ==========');
}

runTests();
