/**
 * 任务内存 Repository
 *
 * 管理导航任务数据（navigationTasks）
 */

class TaskMemoryRepository {
  constructor() {
    // taskId -> taskData
    this.tasks = new Map();
  }

  /**
   * 创建任务
   * @param {Object} taskData
   * @returns {Object}
   */
  async create(taskData) {
    const taskId = taskData.task_id;
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    const task = {
      ...taskData,
      status: taskData.status || 'waiting',
      created_at: taskData.created_at || now
    };

    // 序列化 route_data 和 route_summary
    if (task.route_data && typeof task.route_data === 'object') {
      task.route_data = JSON.stringify(task.route_data);
    }
    if (task.route_summary && typeof task.route_summary === 'object') {
      task.route_summary = JSON.stringify(task.route_summary);
    }

    this.tasks.set(taskId, task);
    return task;
  }

  /**
   * 根据 taskId 查找任务
   * @param {string} taskId
   * @returns {Object|null}
   */
  async findByTaskId(taskId) {
    const task = this.tasks.get(taskId);
    if (!task) return null;

    // 反序列化
    if (task.route_data && typeof task.route_data === 'string') {
      try { task.route_data = JSON.parse(task.route_data); } catch (e) { /* ignore */ }
    }
    if (task.route_summary && typeof task.route_summary === 'string') {
      try { task.route_summary = JSON.parse(task.route_summary); } catch (e) { /* ignore */ }
    }

    return task;
  }

  /**
   * 更新任务
   * @param {string} taskId
   * @param {Object} updateData
   * @returns {Object|null}
   */
  async update(taskId, updateData) {
    const task = this.tasks.get(taskId);
    if (!task) return null;

    // 序列化 route_data 和 route_summary
    if (updateData.route_data && typeof updateData.route_data === 'object') {
      updateData.route_data = JSON.stringify(updateData.route_data);
    }
    if (updateData.route_summary && typeof updateData.route_summary === 'object') {
      updateData.route_summary = JSON.stringify(updateData.route_summary);
    }

    Object.assign(task, updateData);
    return task;
  }

  /**
   * 根据条件查找任务列表
   * @param {Object} filters - 过滤条件
   * @param {Object} options - 分页和排序选项
   * @returns {Array}
   */
  async findByFilters(filters, options = {}) {
    const { status, sender_openid, receiver_openid } = filters;
    const { order, limit, offset } = options;

    let result = [];

    for (const task of this.tasks.values()) {
      let match = true;

      if (status && task.status !== status) match = false;
      if (sender_openid && task.sender_openid !== sender_openid) match = false;
      if (receiver_openid && task.receiver_openid !== receiver_openid) match = false;

      if (match) {
        // 反序列化后再加入结果
        const taskCopy = { ...task };
        if (taskCopy.route_data && typeof taskCopy.route_data === 'string') {
          try { taskCopy.route_data = JSON.parse(taskCopy.route_data); } catch (e) { /* ignore */ }
        }
        if (taskCopy.route_summary && typeof taskCopy.route_summary === 'string') {
          try { taskCopy.route_summary = JSON.parse(taskCopy.route_summary); } catch (e) { /* ignore */ }
        }
        result.push(taskCopy);
      }
    }

    // 排序（按 created_at 降序）
    if (order === 'created_at:desc') {
      result.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    }

    // 分页
    const pageOffset = parseInt(offset) || 0;
    const pageLimit = parseInt(limit) || 20;

    return result.slice(pageOffset, pageOffset + pageLimit);
  }

  /**
   * 统计符合条件的任务数量
   * @param {Object} filters
   * @returns {number}
   */
  async countByFilters(filters) {
    const { status, sender_openid, receiver_openid } = filters;

    let count = 0;
    for (const task of this.tasks.values()) {
      let match = true;

      if (status && task.status !== status) match = false;
      if (sender_openid && task.sender_openid !== sender_openid) match = false;
      if (receiver_openid && task.receiver_openid !== receiver_openid) match = false;

      if (match) count++;
    }
    return count;
  }

  /**
   * 获取用户作为发送者或接收者的所有进行中任务
   * @param {string} openid
   * @returns {Array}
   */
  async findInProgressForUser(openid) {
    const result = [];
    const inProgressStatuses = ['waiting', 'accepted', 'navigating'];

    for (const task of this.tasks.values()) {
      if (
        inProgressStatuses.includes(task.status) &&
        (task.sender_openid === openid || task.receiver_openid === openid)
      ) {
        result.push(task);
      }
    }
    return result;
  }

  /**
   * 删除任务
   * @param {string} taskId
   * @returns {boolean}
   */
  async delete(taskId) {
    return this.tasks.delete(taskId);
  }
}

module.exports = TaskMemoryRepository;
