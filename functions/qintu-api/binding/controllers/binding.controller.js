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
      const user_ID = req.user.user_ID;
      const { receiver_phone, sender_name, receiver_name } = req.body;

      if (!receiver_phone) {
        return validationError(res, 'receiver_phone 是必填参数');
      }

      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.requestBinding(
        user_ID,
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
      const user_ID = req.user.user_ID;
      if (!user_ID || user_ID === 'unknown_user') {
        return success(res, []);
      }

      const result = await this.bindingService.getPendingRequests(user_ID);
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
      const user_ID = req.user.user_ID;
      if (!user_ID || user_ID === 'unknown_user') {
        return success(res, []);
      }

      const result = await this.bindingService.getSentRequests(user_ID);
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
      const user_ID = req.user.user_ID;
      const { partner_user_id } = req.body;

      if (!partner_user_id) {
        return validationError(res, 'partner_user_id 是必填参数');
      }

      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.confirmRequest(user_ID, partner_user_id);
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
      const user_ID = req.user.user_ID;
      const { partner_user_id } = req.body;

      if (!partner_user_id) {
        return validationError(res, 'partner_user_id 是必填参数');
      }

      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.rejectRequest(user_ID, partner_user_id);
      return success(res, result);
    } catch (err) {
      console.error('拒绝绑定请求失败:', err);
      return error(res, err.message, err.code || 'REJECT_FAILED', err.status || 500);
    }
  }

  /**
   * 取消发出的请求
   * DELETE /api/bindings/pending/:partner_user_id
   */
  async cancelRequest(req, res) {
    try {
      const user_ID = req.user.user_ID;
      const { partner_user_id } = req.params;

      if (!partner_user_id) {
        return validationError(res, 'partner_user_id 是必填参数');
      }

      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.cancelRequest(user_ID, partner_user_id);
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

  /**
   * 修改我对对方的称呼
   * PATCH /api/bindings/:partner_user_id
   */
  async modifyName(req, res) {
    try {
      const user_ID = req.user.user_ID;
      const { partner_user_id } = req.params;
      const { my_name_for_partner } = req.body;

      if (!partner_user_id) {
        return validationError(res, 'partner_user_id 是必填参数');
      }

      if (!my_name_for_partner) {
        return validationError(res, 'my_name_for_partner 是必填参数');
      }

      if (!user_ID || user_ID === 'unknown_user') {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.modifyName(user_ID, partner_user_id, my_name_for_partner);
      return success(res, result);
    } catch (err) {
      console.error('修改称呼失败:', err);
      return error(res, err.message, err.code || 'MODIFY_NAME_FAILED', err.status || 500);
    }
  }
}

module.exports = BindingController;