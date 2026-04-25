/**
 * 绑定控制器
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
      const openid = req.user.openid;
      const result = await this.bindingService.getMyBindings(openid);
      return success(res, result);
    } catch (err) {
      console.error('获取绑定关系失败:', err);
      return error(res, err.message, err.code || 'GET_BINDINGS_FAILED', err.status || 500);
    }
  }

  /**
   * 获取待确认的绑定请求
   * GET /api/bindings/pending
   */
  async getPending(req, res) {
    try {
      const openid = req.user.openid;

      if (openid === 'unknown_user') {
        return success(res, []);
      }

      const result = await this.bindingService.getPendingRequests(openid);
      return success(res, result);
    } catch (err) {
      console.error('获取待确认请求失败:', err);
      return error(res, err.message, err.code || 'GET_PENDING_FAILED', err.status || 500);
    }
  }

  /**
   * 获取我发出的绑定请求
   * GET /api/bindings/sent
   */
  async getSent(req, res) {
    try {
      const openid = req.user.openid;

      if (openid === 'unknown_user') {
        return success(res, []);
      }

      const result = await this.bindingService.getSentRequests(openid);
      return success(res, result);
    } catch (err) {
      console.error('获取已发出请求失败:', err);
      return error(res, err.message, err.code || 'GET_SENT_FAILED', err.status || 500);
    }
  }

  /**
   * 发送绑定请求（通过手机号）
   * POST /api/bindings/request-phone
   */
  async requestByPhone(req, res) {
    try {
      const openid = req.user.openid;
      const { receiver_phone, sender_name, receiver_name } = req.body;

      if (!receiver_phone) {
        return validationError(res, 'receiver_phone 是必填参数');
      }

      if (!openid) {
        return error(res, '缺少用户认证信息', 'UNAUTHORIZED', 401);
      }

      const result = await this.bindingService.requestByPhone(
        openid,
        receiver_phone,
        sender_name,
        receiver_name,
        { ipAddress: req.ip }
      );

      return success(res, result, 201);
    } catch (err) {
      console.error('发送绑定请求失败:', err);
      return error(res, err.message, err.code || 'REQUEST_BINDING_FAILED', err.status || 500);
    }
  }

  /**
   * 确认绑定请求
   * POST /api/bindings/confirm-request
   */
  async confirmRequest(req, res) {
    try {
      const openid = req.user.openid;
      const { request_id } = req.body;

      if (!request_id) {
        return validationError(res, 'request_id 是必填参数');
      }

      const result = await this.bindingService.confirmRequest(
        request_id,
        openid,
        { ipAddress: req.ip }
      );

      return success(res, result);
    } catch (err) {
      console.error('确认绑定失败:', err);
      return error(res, err.message, err.code || 'CONFIRM_REQUEST_FAILED', err.status || 500);
    }
  }

  /**
   * 拒绝绑定请求
   * POST /api/bindings/reject-request
   */
  async rejectRequest(req, res) {
    try {
      const openid = req.user.openid;
      const { request_id } = req.body;

      if (!request_id) {
        return validationError(res, 'request_id 是必填参数');
      }

      const result = await this.bindingService.rejectRequest(
        request_id,
        openid,
        { ipAddress: req.ip }
      );

      return success(res, result);
    } catch (err) {
      console.error('拒绝绑定失败:', err);
      return error(res, err.message, err.code || 'REJECT_REQUEST_FAILED', err.status || 500);
    }
  }

  /**
   * 解除绑定 / 取消请求
   * DELETE /api/bindings/:id
   */
  async revoke(req, res) {
    try {
      const openid = req.user.openid;
      const bindingId = req.params.id;

      const result = await this.bindingService.revoke(
        bindingId,
        openid,
        { ipAddress: req.ip }
      );

      return success(res, result);
    } catch (err) {
      console.error('解除绑定失败:', err);
      return error(res, err.message, err.code || 'REVOKE_BINDING_FAILED', err.status || 500);
    }
  }
}

module.exports = BindingController;
