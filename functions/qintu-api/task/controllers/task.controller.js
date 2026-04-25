/**
 * 任务控制器
 */

const { success, validationError, error, notFound } = require('../../shared/lib/response');

class TaskController {
  constructor(taskService) {
    this.taskService = taskService;
  }

  /**
   * 创建任务
   * POST /api/tasks
   */
  async createTask(req, res) {
    try {
      const senderOpenid = req.user.openid;
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
      } = req.body;

      // 参数验证
      if (!receiver_openid || !end_name || end_latitude === undefined || end_longitude === undefined) {
        return validationError(res, '缺少必需参数：receiver_openid, end_name, end_latitude, end_longitude');
      }

      if (!route_data) {
        return validationError(res, 'route_data 是必需参数（高德地图路线数据）');
      }

      const result = await this.taskService.createTask(senderOpenid, {
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
      });

      return success(res, result, 201);
    } catch (err) {
      console.error('创建导航任务失败:', err);
      return error(res, err.message, err.code || 'CREATE_TASK_FAILED', err.status || 500);
    }
  }

  /**
   * 获取我的任务列表
   * GET /api/tasks/my
   */
  async getMyTasks(req, res) {
    try {
      const openid = req.user.openid;
      const { role, status, page, limit } = req.query;

      const result = await this.taskService.getMyTasks(openid, { role, status, page, limit });

      return success(res, result);
    } catch (err) {
      console.error('获取任务列表失败:', err);
      return error(res, err.message, err.code || 'GET_TASKS_FAILED', err.status || 500);
    }
  }

  /**
   * 获取待处理任务
   * GET /api/tasks/pending
   */
  async getPendingTasks(req, res) {
    try {
      const openid = req.user.openid;

      const result = await this.taskService.getPendingTasks(openid);

      return success(res, result);
    } catch (err) {
      console.error('获取待处理任务失败:', err);
      return error(res, err.message, err.code || 'GET_PENDING_FAILED', err.status || 500);
    }
  }

  /**
   * 获取任务详情
   * GET /api/tasks/:taskId
   */
  async getTaskDetail(req, res) {
    try {
      const openid = req.user.openid;
      const taskId = req.params.taskId;

      const result = await this.taskService.getTaskDetail(taskId, openid);

      return success(res, result);
    } catch (err) {
      console.error('获取任务详情失败:', err);
      if (err.code === 'NOT_FOUND') {
        return notFound(res, '任务不存在');
      }
      if (err.code === 'PERMISSION_DENIED') {
        return error(res, err.message, 'PERMISSION_DENIED', 403);
      }
      return error(res, err.message, err.code || 'GET_TASK_FAILED', err.status || 500);
    }
  }

  /**
   * 接受任务
   * POST /api/tasks/:taskId/accept
   */
  async acceptTask(req, res) {
    try {
      const openid = req.user.openid;
      const taskId = req.params.taskId;

      const result = await this.taskService.acceptTask(taskId, openid);

      return success(res, result);
    } catch (err) {
      console.error('接受任务失败:', err);
      if (err.code === 'NOT_FOUND') {
        return notFound(res, '任务不存在');
      }
      if (err.code === 'PERMISSION_DENIED') {
        return error(res, err.message, 'PERMISSION_DENIED', 403);
      }
      if (err.code === 'INVALID_STATUS') {
        return error(res, err.message, 'INVALID_STATUS', 400);
      }
      return error(res, err.message, err.code || 'ACCEPT_TASK_FAILED', err.status || 500);
    }
  }

  /**
   * 开始导航
   * POST /api/tasks/:taskId/start
   */
  async startNavigation(req, res) {
    try {
      const openid = req.user.openid;
      const taskId = req.params.taskId;

      const result = await this.taskService.startNavigation(taskId, openid);

      return success(res, result);
    } catch (err) {
      console.error('开始导航失败:', err);
      if (err.code === 'NOT_FOUND') {
        return notFound(res, '任务不存在');
      }
      if (err.code === 'PERMISSION_DENIED') {
        return error(res, err.message, 'PERMISSION_DENIED', 403);
      }
      if (err.code === 'INVALID_STATUS') {
        return error(res, err.message, 'INVALID_STATUS', 400);
      }
      return error(res, err.message, err.code || 'START_NAV_FAILED', err.status || 500);
    }
  }

  /**
   * 完成任务
   * POST /api/tasks/:taskId/finish
   */
  async finishTask(req, res) {
    try {
      const openid = req.user.openid;
      const taskId = req.params.taskId;

      const result = await this.taskService.finishTask(taskId, openid);

      return success(res, result);
    } catch (err) {
      console.error('完成任务失败:', err);
      if (err.code === 'NOT_FOUND') {
        return notFound(res, '任务不存在');
      }
      if (err.code === 'PERMISSION_DENIED') {
        return error(res, err.message, 'PERMISSION_DENIED', 403);
      }
      if (err.code === 'INVALID_STATUS') {
        return error(res, err.message, 'INVALID_STATUS', 400);
      }
      return error(res, err.message, err.code || 'FINISH_TASK_FAILED', err.status || 500);
    }
  }

  /**
   * 取消任务
   * POST /api/tasks/:taskId/cancel
   */
  async cancelTask(req, res) {
    try {
      const openid = req.user.openid;
      const taskId = req.params.taskId;
      const { reason } = req.body;

      const result = await this.taskService.cancelTask(taskId, openid, reason);

      return success(res, result);
    } catch (err) {
      console.error('取消任务失败:', err);
      if (err.code === 'NOT_FOUND') {
        return notFound(res, '任务不存在');
      }
      if (err.code === 'PERMISSION_DENIED') {
        return error(res, err.message, 'PERMISSION_DENIED', 403);
      }
      if (err.code === 'INVALID_STATUS') {
        return error(res, err.message, 'INVALID_STATUS', 400);
      }
      return error(res, err.message, err.code || 'CANCEL_TASK_FAILED', err.status || 500);
    }
  }

  /**
   * 更新路线
   * PUT /api/tasks/:taskId/route
   */
  async updateRoute(req, res) {
    try {
      const openid = req.user.openid;
      const taskId = req.params.taskId;
      const { route_data, route_summary, distance_meters, duration_seconds } = req.body;

      if (!route_data) {
        return validationError(res, 'route_data 是必需参数');
      }

      const result = await this.taskService.updateRoute(taskId, openid, {
        route_data,
        route_summary,
        distance_meters,
        duration_seconds
      });

      return success(res, result);
    } catch (err) {
      console.error('更新路线失败:', err);
      if (err.code === 'INVALID_PARAM') {
        return validationError(res, err.message);
      }
      if (err.code === 'NOT_FOUND') {
        return notFound(res, '任务不存在');
      }
      if (err.code === 'PERMISSION_DENIED') {
        return error(res, err.message, 'PERMISSION_DENIED', 403);
      }
      if (err.code === 'INVALID_STATUS') {
        return error(res, err.message, 'INVALID_STATUS', 400);
      }
      return error(res, err.message, err.code || 'UPDATE_ROUTE_FAILED', err.status || 500);
    }
  }
}

module.exports = TaskController;
