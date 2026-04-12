/**
 * 测试 CloudBase MySQL RESTful API
 * 参考文档: https://docs.cloudbase.net/http-api/mysqldb/mysql-restful-api
 */

const https = require('https');

// 配置
const ENV_ID = 'qintu-cloudebase-5f5bpuj13bc6467';
const PUBLISHABLE_KEY = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjlkMWRjMzFlLWI0ZDAtNDQ4Yi1hNzZmLWIwY2M2M2Q4MTQ5OCJ9.eyJpc3MiOiJodHRwczovL3FpbnR1LWNsb3VkZWJhc2UtNWY1YnB1ajEzYmM2NDY3LmFwLXNoYW5naGFpLnRjYi1hcGkudGVuY2VudGNsb3VkYXBpLmNvbSIsInN1YiI6ImFub24iLCJhdWQiOiJxaW50dS1jbG91ZGViYXNlLTVmNWJwdWoxM2JjNjQ2NyIsImV4cCI6NDA3ODg3MDg5MywiaWF0IjoxNzc1MTg3NjkzLCJub25jZSI6IjZOeTVQbHBtU215WHdIZjZ2eWFnTlEiLCJhdF9oYXNoIjoiNk55NVBscG1TbXlYd0hmNnZ5YWdOUSIsIm5hbWUiOiJBbm9ueW1vdXMiLCJzY29wZSI6ImFub255bW91cyIsInByb2plY3RfaWQiOiJxaW50dS1jbG91ZGViYXNlLTVmNWJwdWoxM2JjNjQ2NyIsIm1ldGEiOnsicGxhdGZvcm0iOiJQdWJsaXNoYWJsZUtleSJ9LCJ1c2VyX3R5cGUiOiIiLCJjbGllbnRfdHlwZSI6ImNsaWVudF91c2VyIiwiaXNfc3lzdGVtX2FkbWluIjpmYWxzZX0.oLl3ED22kCq_1tnWzxGb-jV4xsJMNlsnLBZ_eEptkGs5Q0Wfe3T75HC3HsuAbFogS7PnlLBieLkYLXGflMdz_IZN_RUZCd4SC9HTH1N9wf4Ov7OfucNO1qQgpaQU74XUAWC70gwnRsNjnmXOgKuDI0-iPOzsMSPWtV-3ci95zFlu2oG1EF7A3M0NWBuS5nNkYeLfQLWskNHt-4bnsNjGvStGKbs2Kz7JqI2PoV07an9WcfOtVKXafzCJwLJUesrlR2jq6d15pbBSStsPgZ4EAkMBzPsBUJFiq8SKhsTOgwhhLow3Ax_JcnhYXcUH43iJ11ky4n7BCemx_r_hbus0Ow';

// 测试 API 端点
const testEndpoints = [
  // 测试 1: 系统数据库（推荐）
  {
    name: '系统数据库 - users 表',
    url: `https://${ENV_ID}.api.tcloudbasegateway.com/v1/rdb/rest/users`,
    method: 'GET'
  },
  // 测试 2: 查询 user_bindings 表
  {
    name: '系统数据库 - user_bindings 表',
    url: `https://${ENV_ID}.api.tcloudbasegateway.com/v1/rdb/rest/user_bindings`,
    method: 'GET'
  }
];

function testEndpoint(config) {
  return new Promise((resolve) => {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`测试: ${config.name}`);
    console.log(`URL: ${config.url}`);
    console.log(`${'='.repeat(60)}`);
    
    const url = new URL(config.url);
    const options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method: config.method,
      headers: {
        'Authorization': `Bearer ${PUBLISHABLE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      timeout: 10000
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        console.log(`✅ 响应状态: ${res.statusCode}`);
        console.log(`响应内容:`);
        try {
          const parsed = JSON.parse(data);
          console.log(JSON.stringify(parsed, null, 2).substring(0, 500));
        } catch {
          console.log(data.substring(0, 500));
        }
        resolve({ success: res.statusCode < 400, statusCode: res.statusCode });
      });
    });

    req.on('error', (error) => {
      console.log(`❌ 请求失败: ${error.message}`);
      resolve({ success: false, error: error.message });
    });

    req.on('timeout', () => {
      req.destroy();
      console.log('⏱️  请求超时');
      resolve({ success: false, error: 'timeout' });
    });

    req.end();
  });
}

async function runTests() {
  console.log('\n🚀 CloudBase MySQL RESTful API 测试\n');
  
  for (const endpoint of testEndpoints) {
    await testEndpoint(endpoint);
  }
  
  console.log('\n✅ 测试完成\n');
}

runTests();
