/**
 * Repository 工厂函数
 *
 * 内存版使用单例模式，确保所有请求共享同一份数据
 */

const UserMemoryRepository = require('../auth/repositories/user.memory.repository');
const BindingMemoryRepository = require('../binding/repositories/binding.memory.repository');
const LocationMemoryRepository = require('../location/repositories/location.memory.repository');
const TaskMemoryRepository = require('../task/repositories/task.memory.repository');

// 单例实例
let _instances = null;

/**
 * 获取内存版 Repository 单例实例
 * @returns {Object} - 包含所有 repository 实例
 */
function getMemoryRepositories() {
  if (!_instances) {
    _instances = {
      userRepo: new UserMemoryRepository(),
      bindingRepo: new BindingMemoryRepository(),
      locationRepo: new LocationMemoryRepository(),
      taskRepo: new TaskMemoryRepository()
    };
  }
  return _instances;
}

/**
 * 根据配置创建 Repository
 * @param {string} mode - 'memory' (仅支持内存版)
 * @returns {Object}
 */
function createRepositories(mode = 'memory') {
  if (mode === 'memory') {
    return getMemoryRepositories();
  }

  // 后续支持 PostgreSQL
  throw new Error(`Repository mode "${mode}" not supported yet. Use 'memory'.`);
}

/**
 * 重置单例（用于测试）
 */
function resetInstances() {
  _instances = null;
}

module.exports = {
  createRepositories,
  getMemoryRepositories,
  resetInstances
};
