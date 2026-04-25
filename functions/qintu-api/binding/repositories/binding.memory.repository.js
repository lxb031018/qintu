/**
 * 绑定关系内存 Repository
 *
 * 单向+确认模式：sender发请求，receiver确认后绑定生效
 */

class BindingMemoryRepository {
  constructor() {
    // bindingId -> bindingData
    this.bindings = new Map();
    this.nextId = 1;
  }

  /**
   * 创建待确认绑定
   */
  async createPending({
    senderOpenid,
    receiverOpenid,
    senderName,
    receiverName,
    senderPhone,
    receiverPhone,
    expiredAt
  }) {
    const id = this.nextId++;
    const now = new Date().toISOString();

    const binding = {
      id,
      sender_openid: senderOpenid,
      receiver_openid: receiverOpenid,
      sender_nickname: senderName || '发送者',
      receiver_nickname: receiverName || '接收者',
      sender_phone: senderPhone || null,
      receiver_phone: receiverPhone || null,
      status: 'pending',
      remark: receiverName || '未命名接收者',
      created_at: now,
      updated_at: now,
      expired_at: expiredAt.toISOString()
    };

    this.bindings.set(String(id), binding);
    return binding;
  }

  /**
   * 根据 ID 查找
   */
  async findById(id) {
    return this.bindings.get(String(id)) || null;
  }

  /**
   * 查找双方之间的 active 绑定
   */
  async findActiveBetween(openidA, openidB) {
    for (const binding of this.bindings.values()) {
      if (
        binding.status === 'active' &&
        ((binding.sender_openid === openidA && binding.receiver_openid === openidB) ||
         (binding.sender_openid === openidB && binding.receiver_openid === openidA))
      ) {
        return binding;
      }
    }
    return null;
  }

  /**
   * 更新绑定状态
   */
  async updateStatus(id, status, extra = {}) {
    const binding = this.bindings.get(String(id));
    if (!binding) return null;

    binding.status = status;
    binding.updated_at = new Date().toISOString();

    if (extra.rejected_at) binding.rejected_at = extra.rejected_at;

    return binding;
  }

  /**
   * 获取用户作为发送者的 active 绑定数量
   */
  async countActiveAsSender(openid) {
    let count = 0;
    for (const binding of this.bindings.values()) {
      if (binding.sender_openid === openid && binding.status === 'active') {
        count++;
      }
    }
    return count;
  }

  /**
   * 获取用户作为接收者的 pending + active 绑定数量
   */
  async countPendingAsReceiver(openid) {
    let count = 0;
    for (const binding of this.bindings.values()) {
      if (
        binding.receiver_openid === openid &&
        (binding.status === 'active' || binding.status === 'pending')
      ) {
        count++;
      }
    }
    return count;
  }

  /**
   * 获取用户作为发送者或接收者的所有 active 绑定
   */
  async findAllActiveForUser(openid) {
    const result = [];
    for (const binding of this.bindings.values()) {
      if (
        binding.status === 'active' &&
        (binding.sender_openid === openid || binding.receiver_openid === openid)
      ) {
        result.push(binding);
      }
    }
    return result;
  }

  /**
   * 获取用户收到的所有 pending 绑定请求
   */
  async findPendingForReceiver(openid) {
    const result = [];
    const now = new Date();

    for (const binding of this.bindings.values()) {
      if (binding.receiver_openid === openid && binding.status === 'pending') {
        // 检查是否过期
        const expiredAt = new Date(binding.expired_at);
        if (expiredAt < now) {
          binding.status = 'expired';
        } else {
          result.push(binding);
        }
      }
    }
    return result;
  }

  /**
   * 获取用户发出的所有绑定请求（包括各种状态）
   */
  async findAllBySender(openid) {
    const result = [];
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    for (const binding of this.bindings.values()) {
      if (binding.sender_openid === openid) {
        const createdAt = new Date(binding.created_at);
        // 只返回7天内的
        if (createdAt >= sevenDaysAgo) {
          // 检查pending是否过期
          if (binding.status === 'pending' && binding.expired_at) {
            const expiredAt = new Date(binding.expired_at);
            if (expiredAt < new Date()) {
              binding.status = 'expired';
            }
          }
          result.push(binding);
        }
      }
    }
    return result;
  }

  /**
   * 清理过期和已撤销的旧记录
   */
  async cleanupOldRecords() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const keysToDelete = [];
    for (const [key, binding] of this.bindings.entries()) {
      if (
        (binding.status === 'expired' || binding.status === 'revoked') &&
        binding.expired_at &&
        new Date(binding.expired_at) < thirtyDaysAgo
      ) {
        keysToDelete.push(key);
      }
    }
    keysToDelete.forEach(key => this.bindings.delete(key));
  }

  /**
   * 删除绑定
   */
  async delete(id) {
    return this.bindings.delete(String(id));
  }
}

module.exports = BindingMemoryRepository;
