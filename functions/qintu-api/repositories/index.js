/**
 * Repository 工厂函数
 *
 * MySQL 版使用连接池，支持数据持久化
 */

const UserMysqlRepository = require('../auth/repositories/user.mysql.repository');
const BindingMysqlRepository = require('../binding/repositories/binding.mysql.repository');

// 单例实例
let _instances = null;

/**
 * 获取 MySQL 版 Repository 单例实例
 * @returns {Object}
 */
function getMySqlRepositories() {
  if (!_instances) {
    _instances = {
      userRepo: new UserMysqlRepository(),
      bindingRepo: new BindingMysqlRepository()
    };
  }
  return _instances;
}

/**
 * 根据配置创建 Repository
 * @param {string} mode - 'mysql'
 * @returns {Object}
 */
function createRepositories(mode = process.env.REPO_MODE || 'mysql') {
  if (mode === 'mysql') {
    return getMySqlRepositories();
  }

  throw new Error(`Repository mode "${mode}" not supported. Use 'mysql'.`);
}

/**
 * 重置单例（用于测试）
 */
function resetInstances() {
  _instances = null;
}

module.exports = {
  createRepositories,
  getMySqlRepositories,
  resetInstances
};
