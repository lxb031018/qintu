/**
 * 用户控制器
 */

const { success, error, notFound } = require('../../shared/lib/response');

class UserController {
  constructor(userService) {
    this.userService = userService;
  }

  /**
   * 获取当前用户信息
   * GET /api/users/me
   */
  async getMe(req, res) {
    try {
      const user_ID = req.user.user_ID;

      if (!user_ID) {
        return error(res, '缺少用户身份', 'UNAUTHORIZED', 401);
      }

      const user = await this.userService.getUserByOpenid(user_ID);

      if (!user) {
        return notFound(res, '用户不存在');
      }

      return success(res, user);
    } catch (err) {
      console.error('获取用户信息失败:', err);
      return error(res, err.message, 'GET_USER_FAILED', 500);
    }
  }

  /**
   * 更新当前用户信息
   * PUT /api/users/me
   */
  async updateMe(req, res) {
    try {
      const user_ID = req.user.user_ID;
      const userData = req.body;

      if (!user_ID) {
        return error(res, '缺少用户身份', 'UNAUTHORIZED', 401);
      }

      const result = await this.userService.upsertUser(user_ID, userData);

      return success(res, result);
    } catch (err) {
      console.error('更新用户信息失败:', err);
      return error(res, err.message, 'UPDATE_USER_FAILED', 500);
    }
  }

  /**
   * 同步用户信息
   * POST /api/users/sync
   */
  async syncUser(req, res) {
    try {
      const user_ID = req.user.user_ID;
      const userData = req.body;

      if (!user_ID) {
        return error(res, '缺少用户身份', 'UNAUTHORIZED', 401);
      }

      const result = await this.userService.upsertUser(user_ID, userData);

      return success(res, result);
    } catch (err) {
      console.error('同步用户信息失败:', err);
      return error(res, err.message, 'SYNC_USER_FAILED', 500);
    }
  }

  /**
   * 获取指定用户信息
   * GET /api/users/:user_ID
   */
  async getUser(req, res) {
    try {
      const user_ID = req.params.user_ID;

      const user = await this.userService.getUserByOpenid(user_ID);

      if (!user) {
        return notFound(res, '用户不存在');
      }

      return success(res, user);
    } catch (err) {
      console.error('获取用户信息失败:', err);
      return error(res, err.message, 'GET_USER_FAILED', 500);
    }
  }
}

module.exports = UserController;
