/**
 * 任务路由
 */

const express = require('express');
const router = express.Router();
const TaskController = require('../../task/controllers/task.controller');
const { requireAuth } = require('../../shared/middleware/auth.middleware');

/**
 * 创建任务路由
 * @param {TaskService} taskService - 任务服务实例
 */
function createTaskRoutes(taskService) {
  const taskController = new TaskController(taskService);

  // 需要认证
  router.use(requireAuth);

  // 创建任务
  router.post('/', (req, res) => taskController.createTask(req, res));

  // 获取我的任务列表
  router.get('/my', (req, res) => taskController.getMyTasks(req, res));

  // 获取待处理任务
  router.get('/pending', (req, res) => taskController.getPendingTasks(req, res));

  // 获取任务详情
  router.get('/:taskId', (req, res) => taskController.getTaskDetail(req, res));

  // 接受任务
  router.post('/:taskId/accept', (req, res) => taskController.acceptTask(req, res));

  // 开始导航
  router.post('/:taskId/start', (req, res) => taskController.startNavigation(req, res));

  // 完成任务
  router.post('/:taskId/finish', (req, res) => taskController.finishTask(req, res));

  // 取消任务
  router.post('/:taskId/cancel', (req, res) => taskController.cancelTask(req, res));

  // 更新路线
  router.put('/:taskId/route', (req, res) => taskController.updateRoute(req, res));

  return router;
}

module.exports = createTaskRoutes;
