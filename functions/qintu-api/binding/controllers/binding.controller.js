/**
 * 绑定控制器（简化版）
 */

const { success, validationError, error } = require('../../shared/lib/response');

class BindingController {
  constructor(bindingService) {
    this.bindingService = bindingService;
  }

  /**
   * 获取我的所有绑定
   * GET /api/bindings/my
   */
  async getMyBindings(req, res) {
    try {
      const user_ID = req.user.user_ID;
      if (!user_ID || user_ID === 'unknown_user') {
        return success(res, { total: 0, bindings: [] });
      }
      const result = await this.bindingService.getMyBindings(user_ID);
      return success(res, result);
    } catch (err) {
      console.error('获取绑定关系失败:', err);
      return error(res, err.message, err.code || 'GET_BINDINGS_FAILED', err.status || 500);
    }
  }

  /**
   * 绑定用户（通过手机号）
   * POST /api/bindings
   */
  async bindByPhone(req, res) {
    try {
      const user_ID = req.user.user_ID;
      const { receiver_phone } = req.body;

      if (!receiver_phone) {
        return validationError(res, 'receiver_phone 是必填参数');
      }

      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.bindByPhone(user_ID, receiver_phone);
      return success(res, result, 201);
    } catch (err) {
      console.error('绑定失败:', err);
      return error(res, err.message, err.code || 'BIND_FAILED', err.status || 500);
    }
  }

  /**
   * 解绑用户
   * DELETE /api/bindings/:partner_user_id
   */
  async unbind(req, res) {
    try {
      const user_ID = req.user.user_ID;
      const { partner_user_id } = req.params;

      if (!partner_user_id) {
        return validationError(res, 'partner_user_id 是必填参数');
      }

      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.unbind(user_ID, partner_user_id);
      return success(res, result);
    } catch (err) {
      console.error('解绑失败:', err);
      return error(res, err.message, err.code || 'UNBIND_FAILED', err.status || 500);
    }
  }
}

module.exports = BindingController;