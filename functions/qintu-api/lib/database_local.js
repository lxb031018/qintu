/**
 * 本地内存数据库
 *
 * 用于本地开发测试，数据存储在内存中
 * 重启服务后数据会丢失
 *
 * 支持：
 * - getTable/insertTable/updateTable/deleteTable (RESTful API 风格)
 * - 基本的 query() SQL 解析（用于 bindings.js）
 */

const crypto = require('crypto');

// 生成唯一 ID
function generateId() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2, 9);
}

// 生成 openid
function generateOpenid(phone) {
  const hash = crypto.createHash('md5').update(phone || 'default').digest('hex');
  return `mock_openid_${hash.substr(0, 16)}`;
}

// ==========================================
// 内存数据存储
// ==========================================

const db = {
  // 用户表（空，实际用户由 mock_auth.js 的 userPhoneMap 管理）
  users: [],

  // 绑定关系表（空，实际绑定由 bindings-memory.js 的 mockBindings 管理）
  user_bindings: [],

  // 待确认请求表
  pending_requests: [],

  // 实时位置表（空，实际位置由 locations-memory.js 的 global.userLocations 管理）
  real_time_locations: [],

  // 导航任务表
  navigation_tasks: [],

  // 位置共享设置
  sharing_settings: [],
};

// ==========================================
// 辅助函数
// ==========================================

function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

function matchFilters(item, filters) {
  for (const [key, value] of Object.entries(filters)) {
    if (item[key] !== value) return false;
  }
  return true;
}

// 根据 openid 查找用户
function findUserByOpenid(openid) {
  return db.users.find(u => u.openid === openid);
}

// 根据手机号查找用户
function findUserByPhone(phone) {
  return db.users.find(u => u.phone === phone);
}

// ==========================================
// SQL 解析器（用于 bindings.js）
// ==========================================

/**
 * 解析并执行 SQL 查询
 * 仅支持部分预定义的查询模式
 */
async function query(sql, params = []) {
  const sqlLower = sql.toLowerCase().trim();

  // 获取我的绑定列表 (UNION 查询)
  if (sqlLower.includes('union all') && sqlLower.includes('user_bindings')) {
    return executeBindingListQuery(sql, params);
  }

  // SELECT 查询（获取待确认请求、发出的请求等）
  if (sqlLower.startsWith('select')) {
    return executeSelectQuery(sql, params);
  }

  // UPDATE 查询
  if (sqlLower.startsWith('update')) {
    return executeUpdateQuery(sql, params);
  }

  // INSERT 查询
  if (sqlLower.startsWith('insert')) {
    return executeInsertQuery(sql, params);
  }

  // DELETE 查询
  if (sqlLower.startsWith('delete')) {
    return executeDeleteQuery(sql, params);
  }

  throw new Error(`不支持的 SQL: ${sql.substring(0, 100)}...`);
}

/**
 * 执行绑定列表查询（UNION 查询）
 */
function executeBindingListQuery(sql, params) {
  const openid = params[0]; // sender_openid
  const results = [];

  // 作为发送者的绑定
  const asSender = db.user_bindings.filter(b =>
    b.sender_openid === openid && b.status === 'active'
  );

  for (const binding of asSender) {
    const receiver = findUserByOpenid(binding.receiver_openid);
    if (receiver) {
      results.push({
        id: binding.id,
        status: binding.status,
        remark: binding.remark,
        created_at: binding.created_at,
        updated_at: binding.updated_at,
        my_role: 'sender',
        partner_openid: receiver.openid,
        partner_nickname: receiver.nickname,
        partner_phone: receiver.phone,
        partner_type: receiver.user_type,
        sender_openid: binding.sender_openid,
        receiver_openid: binding.receiver_openid,
      });
    }
  }

  // 作为接收者的绑定
  const asReceiver = db.user_bindings.filter(b =>
    b.receiver_openid === openid && b.status === 'active'
  );

  for (const binding of asReceiver) {
    const sender = findUserByOpenid(binding.sender_openid);
    if (sender) {
      results.push({
        id: binding.id,
        status: binding.status,
        remark: binding.remark,
        created_at: binding.created_at,
        updated_at: binding.updated_at,
        my_role: 'receiver',
        partner_openid: sender.openid,
        partner_nickname: sender.nickname,
        partner_phone: sender.phone,
        partner_type: sender.user_type,
        sender_openid: binding.sender_openid,
        receiver_openid: binding.receiver_openid,
      });
    }
  }

  return results;
}

/**
 * 执行 SELECT 查询
 */
function executeSelectQuery(sql, params) {
  const sqlLower = sql.toLowerCase();

  // 获取待确认请求 (GET /pending)
  if (sqlLower.includes('pending') && sqlLower.includes('user_bindings')) {
    const openid = params[0];
    return db.user_bindings
      .filter(b => b.receiver_openid === openid && b.status === 'pending')
      .map(b => {
        const sender = findUserByOpenid(b.sender_openid);
        return {
          id: b.id,
          sender_name: b.remark,
          created_at: b.created_at,
          expired_at: b.expired_at,
          sender_nickname: sender?.nickname || '未知',
          sender_phone: sender?.phone || '未知',
        };
      });
  }

  // 获取发出的请求 (GET /sent)
  if (sqlLower.includes('sender_openid') && sqlLower.includes('receiver_openid')) {
    const openid = params[0];
    return db.user_bindings
      .filter(b => b.sender_openid === openid)
      .map(b => {
        const receiver = findUserByOpenid(b.receiver_openid);
        return {
          id: b.id,
          status: b.status,
          sender_name: b.remark,
          created_at: b.created_at,
          expired_at: b.expired_at,
          receiver_nickname: receiver?.nickname || '未知',
          receiver_phone: receiver?.phone || '未知',
        };
      });
  }

  // 确认绑定请求 SELECT
  if (sqlLower.includes('confirm-request') || sqlLower.includes('status = \'pending\'')) {
    const bindingId = params[0];
    const binding = db.user_bindings.find(b => b.id === bindingId);
    if (binding) {
      return [{ sender_openid: binding.sender_openid, expired_at: binding.expired_at }];
    }
    return [];
  }

  // 检查用户是否存在（用于 request-phone）
  if (sqlLower.includes('from users') && sqlLower.includes('phone')) {
    const phone = params[2]; // 第三个参数是手机号
    const user = findUserByPhone(phone);
    if (!user) return [];

    // 计算发送者已有的绑定数量
    const senderActiveCount = db.user_bindings.filter(
      b => b.sender_openid === user.openid && b.status === 'active'
    ).length;

    // 计算接收者的待处理请求数量
    const receiverPendingCount = db.user_bindings.filter(
      b => b.receiver_openid === user.openid && b.status in ['active', 'pending']
    ).length;

    // 检查是否已存在绑定关系
    let existingStatus = null;
    const existingBinding = db.user_bindings.find(
      b => b.sender_openid === params[0] && b.receiver_openid === user.openid
    );
    if (existingBinding) {
      existingStatus = existingBinding.status;
    }

    return [{
      receiver_openid: user.openid,
      receiver_nickname: user.nickname,
      sender_active_count: senderActiveCount,
      receiver_pending_count: receiverPendingCount,
      existing_binding_status: existingStatus,
    }];
  }

  return [];
}

/**
 * 执行 UPDATE 查询
 */
function executeUpdateQuery(sql, params) {
  const sqlLower = sql.toLowerCase();

  // 更新绑定状态
  if (sqlLower.includes('user_bindings') && sqlLower.includes('status')) {
    const status = sqlLower.includes('\'active\'') ? 'active' :
                   sqlLower.includes('\'expired\'') ? 'expired' :
                   sqlLower.includes('\'revoked\'') ? 'revoked' : 'pending';

    const bindingId = params[0];
    const binding = db.user_bindings.find(b => b.id === bindingId);
    if (binding) {
      binding.status = status;
      binding.updated_at = new Date().toISOString();
      return { affectedRows: 1 };
    }
    return { affectedRows: 0 };
  }

  return { affectedRows: 0 };
}

/**
 * 执行 INSERT 查询
 */
function executeInsertQuery(sql, params) {
  const sqlLower = sql.toLowerCase();

  // 创建绑定请求
  if (sqlLower.includes('user_bindings')) {
    const senderOpenid = params[0];
    const receiverOpenid = params[1];
    const remark = params[2] || '未命名发送者';
    const expiredAt = params[3] || new Date(Date.now() + 7 * 24 * 3600 * 1000).toISOString();

    const newBinding = {
      id: db.user_bindings.length + 1,
      sender_openid: senderOpenid,
      receiver_openid: receiverOpenid,
      status: 'pending',
      remark: remark,
      expired_at: expiredAt,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    db.user_bindings.push(newBinding);
    return { insertId: newBinding.id };
  }

  return { insertId: 0 };
}

/**
 * 执行 DELETE 查询
 */
function executeDeleteQuery(sql, params) {
  return { affectedRows: 0 };
}

/**
 * 事务（不支持）
 */
async function transaction(callback) {
  throw new Error('本地模式不支持事务');
}

// ==========================================
// RESTful API 方法
// ==========================================

/**
 * GET - 查询
 */
async function getTable(table, options = {}) {
  const { filters, select, limit, order } = options;

  if (!db[table]) {
    throw new Error(`表 ${table} 不存在`);
  }

  let results = deepClone(db[table]);

  if (filters) {
    results = results.filter(item => matchFilters(item, filters));
  }

  if (order) {
    const [field, direction] = order.split(':');
    results.sort((a, b) => {
      if (direction === 'desc') {
        return a[field] > b[field] ? -1 : 1;
      }
      return a[field] < b[field] ? -1 : 1;
    });
  }

  if (select) {
    const fields = select.split(',');
    results = results.map(item => {
      const selected = {};
      fields.forEach(f => selected[f.trim()] = item[f.trim()]);
      return selected;
    });
  }

  if (limit) {
    results = results.slice(0, limit);
  }

  return results;
}

/**
 * POST - 插入
 */
async function insertTable(table, data) {
  if (!db[table]) {
    throw new Error(`表 ${table} 不存在`);
  }

  const now = new Date().toISOString();
  const items = Array.isArray(data) ? data : [data];

  const inserted = items.map(item => {
    const newItem = {
      ...item,
      id: item.id || generateId(),
      created_at: now,
      updated_at: now,
    };
    db[table].push(newItem);
    return newItem;
  });

  return Array.isArray(data) ? inserted : inserted[0];
}

/**
 * PATCH - 更新
 */
async function updateTable(table, conditions, data) {
  if (!db[table]) {
    throw new Error(`表 ${table} 不存在`);
  }

  const now = new Date().toISOString();
  let updatedCount = 0;

  db[table] = db[table].map(item => {
    if (matchFilters(item, conditions)) {
      updatedCount++;
      return { ...item, ...data, updated_at: now };
    }
    return item;
  });

  return { affectedRows: updatedCount };
}

/**
 * DELETE - 删除
 */
async function deleteTable(table, conditions) {
  if (!db[table]) {
    throw new Error(`表 ${table} 不存在`);
  }

  const originalLength = db[table].length;
  db[table] = db[table].filter(item => !matchFilters(item, conditions));

  return { affectedRows: originalLength - db[table].length };
}

// ==========================================
// 初始化测试数据
// ==========================================

function initTestData() {
  console.log('📦 本地内存数据库已初始化（无预置数据）');
  console.log(`   - users: ${db.users.length} 条`);
  console.log(`   - user_bindings: ${db.user_bindings.length} 条`);
  console.log(`   - real_time_locations: ${db.real_time_locations.length} 条`);
}

// 启动时初始化
initTestData();

// ==========================================
// 导出
// ==========================================

module.exports = {
  db,
  getTable,
  insertTable,
  updateTable,
  deleteTable,
  query,
  transaction,
  generateId,
  generateOpenid,
  initTestData,
};
