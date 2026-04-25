/**
 * 任务服务
 *
 * 职责：
 * 1. 创建导航任务
 * 2. 任务状态机（waiting → accepted → navigating → finished/cancelled）
 * 3. 任务权限校验
 */

const { v4: uuidv4 } = require('uuid');

class TaskService {
  constructor(bindingRepository, taskRepository) {
    this.bindingRepo = bindingRepository;
    this.taskRepo = taskRepository;
  }

  /**
   * 创建导航任务
   * @param {string} senderOpenid - 发送者 openid
   * @param {Object} taskData
   * @returns {Object}
   */
  async createTask(senderOpenid, taskData) {
    const {
      receiver_openid,
      start_name,
      start_latitude,
      start_longitude,
      start_address,
      end_name,
      end_latitude,
      end_longitude,
      end_address,
      route_data,
      route_summary,
      transport_mode,
      distance_meters,
      duration_seconds
    } = taskData;

    // 验证绑定关系
    const binding = await this.bindingRepo.findActiveBetween(senderOpenid, receiver_openid);
    if (!binding) {
      throw Object.assign(new Error('与该接收者没有绑定关系'), { code: 'NO_BINDING', status: 403 });
    }

    // 检查接收者是否有进行中的任务
    const inProgressTasks = await this.taskRepo.findInProgressForUser(receiver_openid);
    if (inProgressTasks.length > 0) {
      throw Object.assign(
        new Error(`该接收者有进行中的任务（${inProgressTasks[0].status}）`),
        { code: 'TASK_IN_PROGRESS', status: 409 }
      );
    }

    // 生成任务 ID
    const taskId = uuidv4();
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');

    const task = await this.taskRepo.create({
      task_id: taskId,
      sender_openid: senderOpenid,
      receiver_openid,
      status: 'waiting',
      start_name: start_name || null,
      start_latitude: start_latitude || null,
      start_longitude: start_longitude || null,
      start_address: start_address || null,
      end_name,
      end_latitude,
      end_longitude,
      end_address: end_address || null,
      route_data,
      route_summary: route_summary || null,
      transport_mode: transport_mode || 'drive',
      distance_meters: distance_meters || null,
      duration_seconds: duration_seconds || null,
      created_at: now
    });

    return {
      message: '导航任务已创建并发送给接收者',
      task: {
        ...task,
        route_data,
        route_summary
      }
    };
  }

  /**
   * 获取我的任务列表
   * @param {string} openid
   * @param {Object} query - { role, status, page, limit }
   * @returns {Object}
   */
  async getMyTasks(openid, query = {}) {
    const { role, status, page = 1, limit = 20 } = query;

    const pageNum = Math.max(1, parseInt(page) || 1);
    const limitNum = Math.min(100, Math.max(1, parseInt(limit) || 20));

    const filterKey = role === 'receiver' ? 'receiver_openid' : 'sender_openid';
    const filters = { [filterKey]: openid };
    if (status) filters.status = status;

    const tasks = await this.taskRepo.findByFilters(filters, {
      order: 'created_at:desc',
      limit: String(limitNum),
      offset: String((pageNum - 1) * limitNum)
    });

    const total = await this.taskRepo.countByFilters(filters);

    return { total, page: pageNum, limit: limitNum, tasks };
  }

  /**
   * 获取待处理任务（接收者的 waiting 任务）
   * @param {string} openid
   * @returns {Object}
   */
  async getPendingTasks(openid) {
    const tasks = await this.taskRepo.findByFilters({
      receiver_openid: openid,
      status: 'waiting'
    }, { order: 'created_at:desc' });

    return { total: tasks.length, tasks };
  }

  /**
   * 获取任务详情
   * @param {string} taskId
   * @param {string} openid
   * @returns {Object}
   */
  async getTaskDetail(taskId, openid) {
    const task = await this.taskRepo.findByTaskId(taskId);

    if (!task) {
      throw Object.assign(new Error('任务不存在'), { code: 'NOT_FOUND', status: 404 });
    }

    if (task.sender_openid !== openid && task.receiver_openid !== openid) {
      throw Object.assign(new Error('无权查看此任务'), { code: 'PERMISSION_DENIED', status: 403 });
    }

    return task;
  }

  /**
   * 接受任务（接收者）
   * @param {string} taskId
   * @param {string} openid
   * @returns {Object}
   */
  async acceptTask(taskId, openid) {
    const task = await this.taskRepo.findByTaskId(taskId);

    if (!task) {
      throw Object.assign(new Error('任务不存在'), { code: 'NOT_FOUND', status: 404 });
    }

    if (task.receiver_openid !== openid) {
      throw Object.assign(new Error('无权操作此任务'), { code: 'PERMISSION_DENIED', status: 403 });
    }

    if (task.status !== 'waiting') {
      throw Object.assign(new Error(`任务状态为 ${task.status}，无法接受`), { code: 'INVALID_STATUS', status: 400 });
    }

    await this.taskRepo.update(taskId, {
      status: 'accepted',
      accepted_at: new Date().toISOString().slice(0, 19).replace('T', ' ')
    });

    return { message: '任务已接受' };
  }

  /**
   * 开始导航（接收者）
   * @param {string} taskId
   * @param {string} openid
   * @returns {Object}
   */
  async startNavigation(taskId, openid) {
    const task = await this.taskRepo.findByTaskId(taskId);

    if (!task) {
      throw Object.assign(new Error('任务不存在'), { code: 'NOT_FOUND', status: 404 });
    }

    if (task.receiver_openid !== openid) {
      throw Object.assign(new Error('无权操作此任务'), { code: 'PERMISSION_DENIED', status: 403 });
    }

    if (task.status !== 'accepted') {
      throw Object.assign(new Error(`任务状态为 ${task.status}，无法开始导航`), { code: 'INVALID_STATUS', status: 400 });
    }

    await this.taskRepo.update(taskId, {
      status: 'navigating',
      started_at: new Date().toISOString().slice(0, 19).replace('T', ' ')
    });

    return { message: '导航已开始' };
  }

  /**
   * 完成任务（接收者）
   * @param {string} taskId
   * @param {string} openid
   * @returns {Object}
   */
  async finishTask(taskId, openid) {
    const task = await this.taskRepo.findByTaskId(taskId);

    if (!task) {
      throw Object.assign(new Error('任务不存在'), { code: 'NOT_FOUND', status: 404 });
    }

    if (task.receiver_openid !== openid) {
      throw Object.assign(new Error('无权操作此任务'), { code: 'PERMISSION_DENIED', status: 403 });
    }

    if (!['accepted', 'navigating'].includes(task.status)) {
      throw Object.assign(new Error(`任务状态为 ${task.status}，无法完成`), { code: 'INVALID_STATUS', status: 400 });
    }

    await this.taskRepo.update(taskId, {
      status: 'finished',
      finished_at: new Date().toISOString().slice(0, 19).replace('T', ' ')
    });

    return { message: '导航已完成' };
  }

  /**
   * 取消任务（发送者或接收者）
   * @param {string} taskId
   * @param {string} openid
   * @param {string} reason - 取消原因
   * @returns {Object}
   */
  async cancelTask(taskId, openid, reason) {
    const task = await this.taskRepo.findByTaskId(taskId);

    if (!task) {
      throw Object.assign(new Error('任务不存在'), { code: 'NOT_FOUND', status: 404 });
    }

    if (task.sender_openid !== openid && task.receiver_openid !== openid) {
      throw Object.assign(new Error('无权操作此任务'), { code: 'PERMISSION_DENIED', status: 403 });
    }

    if (!['waiting', 'accepted', 'navigating'].includes(task.status)) {
      throw Object.assign(new Error(`任务状态为 ${task.status}，无法取消`), { code: 'INVALID_STATUS', status: 400 });
    }

    const cancelledBy = task.sender_openid === openid ? 'sender' : 'receiver';

    await this.taskRepo.update(taskId, {
      status: 'cancelled',
      cancelled_at: new Date().toISOString().slice(0, 19).replace('T', ' '),
      cancel_reason: reason || null,
      cancelled_by: cancelledBy
    });

    return { message: '任务已取消' };
  }

  /**
   * 更新路线（发送者，中途干预）
   * @param {string} taskId
   * @param {string} openid
   * @param {Object} updateData - { route_data, route_summary, distance_meters, duration_seconds }
   * @returns {Object}
   */
  async updateRoute(taskId, openid, updateData) {
    const { route_data, route_summary, distance_meters, duration_seconds } = updateData;

    if (!route_data) {
      throw Object.assign(new Error('route_data 是必需参数'), { code: 'INVALID_PARAM', status: 400 });
    }

    const task = await this.taskRepo.findByTaskId(taskId);

    if (!task) {
      throw Object.assign(new Error('任务不存在'), { code: 'NOT_FOUND', status: 404 });
    }

    if (task.sender_openid !== openid) {
      throw Object.assign(new Error('无权操作此任务'), { code: 'PERMISSION_DENIED', status: 403 });
    }

    if (!['accepted', 'navigating'].includes(task.status)) {
      throw Object.assign(new Error(`任务状态为 ${task.status}，无法更新路线`), { code: 'INVALID_STATUS', status: 400 });
    }

    await this.taskRepo.update(taskId, {
      route_data,
      route_summary: route_summary || null,
      distance_meters: distance_meters || null,
      duration_seconds: duration_seconds || null
    });

    return { message: '路线已更新' };
  }
}

module.exports = TaskService;
