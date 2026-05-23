/**
 * 绑定控制器
 */

const { success, validationError, error } = require('../../shared/lib/response');

class BindingController {
  constructor(bindingService) {
    this.bindingService = bindingService;
  }

  /**
   * 发送绑定请求
   * POST /api/bindings/request-phone
   */
  async requestBinding(req, res) {
    try {
      const userId = req.user.userId;
      const { receiver_phone, sender_name, receiver_name } = req.body;

      if (!receiver_phone) {
        return validationError(res, 'receiver_phone 是必填参数');
      }

      if (!userId || userId === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.requestBinding(
        userId,
        receiver_phone,
        sender_name || '',
        receiver_name || ''
      );
      return success(res, result, 201);
    } catch (err) {
      console.error('发送绑定请求失败:', err);
      return error(res, err.message, err.code || 'REQUEST_BINDING_FAILED', err.status || 500);
    }
  }

  /**
   * 获取我收到的待确认请求
   * GET /api/bindings/pending
   */
  async getPendingRequests(req, res) {
    try {
      const userId = req.user.userId;
      if (!userId || userId === 'unknown_user') {
        return success(res, []);
      }

      const result = await this.bindingService.getPendingRequests(userId);
      return success(res, result);
    } catch (err) {
      console.error('获取待确认请求失败:', err);
      return error(res, err.message, err.code || 'GET_PENDING_FAILED', err.status || 500);
    }
  }

  /**
   * 获取我发出的请求
   * GET /api/bindings/sent
   */
  async getSentRequests(req, res) {
    try {
      const userId = req.user.userId;
      if (!userId || userId === 'unknown_user') {
        return success(res, []);
      }

      const result = await this.bindingService.getSentRequests(userId);
      return success(res, result);
    } catch (err) {
      console.error('获取发出的请求失败:', err);
      return error(res, err.message, err.code || 'GET_SENT_FAILED', err.status || 500);
    }
  }

  /**
   * 确认绑定请求（接受）
   * POST /api/bindings/confirm-request
   */
  async confirmRequest(req, res) {
    try {
      const userId = req.user.userId;
      const { partner_userId } = req.body;

      if (!partner_userId) {
        return validationError(res, 'partner_userId 是必填参数');
      }

      if (!userId || userId === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.confirmRequest(userId, partner_userId);
      return success(res, result);
    } catch (err) {
      console.error('确认绑定请求失败:', err);
      return error(res, err.message, err.code || 'CONFIRM_FAILED', err.status || 500);
    }
  }

  /**
   * 拒绝绑定请求
   * POST /api/bindings/reject-request
   */
  async rejectRequest(req, res) {
    try {
      const userId = req.user.userId;
      const { partner_userId } = req.body;

      if (!partner_userId) {
        return validationError(res, 'partner_userId 是必填参数');
      }

      if (!userId || userId === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.rejectRequest(userId, partner_userId);
      return success(res, result);
    } catch (err) {
      console.error('拒绝绑定请求失败:', err);
      return error(res, err.message, err.code || 'REJECT_FAILED', err.status || 500);
    }
  }

  /**
   * 取消发出的请求
   * DELETE /api/bindings/pending/:partner_userId
   */
  async cancelRequest(req, res) {
    try {
      const userId = req.user.userId;
      const { partner_userId } = req.params;

      if (!partner_userId) {
        return validationError(res, 'partner_userId 是必填参数');
      }

      if (!userId || userId === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.cancelRequest(userId, partner_userId);
      return success(res, result);
    } catch (err) {
      console.error('取消请求失败:', err);
      return error(res, err.message, err.code || 'CANCEL_FAILED', err.status || 500);
    }
  }

  /**
   * 获取我的所有绑定
   * GET /api/bindings/my
   */
  async getMyBindings(req, res) {
    try {
      const userId = req.user.userId;
      if (!userId || userId === 'unknown_user') {
        return success(res, { total: 0, bindings: [] });
      }

      const result = await this.bindingService.getMyBindings(userId);
      return success(res, result);
    } catch (err) {
      console.error('获取绑定关系失败:', err);
      return error(res, err.message, err.code || 'GET_BINDINGS_FAILED', err.status || 500);
    }
  }

  /**
   * 解绑用户
   * DELETE /api/bindings/:partner_userId
   */
  async unbind(req, res) {
    try {
      const userId = req.user.userId;
      const { partner_userId } = req.params;

      if (!partner_userId) {
        return validationError(res, 'partner_userId 是必填参数');
      }

      if (!userId || userId === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.unbind(userId, partner_userId);
      return success(res, result);
    } catch (err) {
      console.error('解绑失败:', err);
      return error(res, err.message, err.code || 'UNBIND_FAILED', err.status || 500);
    }
  }

  /**
   * 修改我对对方的称呼
   * PATCH /api/bindings/:partner_userId
   */
  async modifyName(req, res) {
    try {
      const userId = req.user.userId;
      const { partner_userId } = req.params;
      const { my_name_for_partner } = req.body;

      if (!partner_userId) {
        return validationError(res, 'partner_userId 是必填参数');
      }

      if (!my_name_for_partner) {
        return validationError(res, 'my_name_for_partner 是必填参数');
      }

      if (!userId || userId === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.modifyName(userId, partner_userId, my_name_for_partner);
      return success(res, result);
    } catch (err) {
      console.error('修改称呼失败:', err);
      return error(res, err.message, err.code || 'MODIFY_NAME_FAILED', err.status || 500);
    }
  }
}

module.exports = BindingController;