/**
 * Repository 工厂函数
 *
 * 内存版使用单例模式，确保所有请求共享同一份数据
 * MySQL 版使用连接池，支持数据持久化
 */

const UserMemoryRepository = require('../auth/repositories/user.memory.repository');
const BindingMemoryRepository = require('../binding/repositories/binding.memory.repository');
const LocationMemoryRepository = require('../location/repositories/location.memory.repository');
const TaskMemoryRepository = require('../task/repositories/task.memory.repository');

const UserMysqlRepository = require('../auth/repositories/user.mysql.repository');

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
 * @param {string} mode - 'memory' 或 'mysql'
 * @returns {Object}
 */
function createRepositories(mode = process.env.REPO_MODE || 'memory') {
  if (mode === 'memory') {
    return getMemoryRepositories();
  }

  if (mode === 'mysql') {
    return {
      userRepo: new UserMysqlRepository(),
      bindingRepo: new BindingMemoryRepository(),  // 待改造
      locationRepo: new LocationMemoryRepository(), // 待改造
      taskRepo: new TaskMemoryRepository()           // 待改造
    };
  }

  throw new Error(`Repository mode "${mode}" not supported. Use 'memory' or 'mysql'.`);
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
