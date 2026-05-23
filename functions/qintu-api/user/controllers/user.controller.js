/**
 * 用户控制器
 */

const { success, error } = require('../../shared/lib/response');

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
      const userId = req.user && req.user.userId;
      if (!userId) {
        return res.status(401).json({ code: 401, message: 'Unauthorized' });
      }

      const user = await this.userService.getUserById(userId);
      if (!user) {
        return res.status(404).json({ code: 404, message: 'User not found' });
      }

      return res.json({
        code: 0,
        data: {
          userId: user.userId,
          phone: user.phone,
          nickname: user.nickname || '',
          avatar_url: user.avatar_url || '',
          created_at: user.created_at,
          last_active_at: user.last_active_at
        }
      });
    } catch (err) {
      console.error('[User] 获取用户信息失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }

  /**
   * 更新当前用户信息
   * PUT /api/users/me
   */
  async updateMe(req, res) {
    try {
      const userId = req.user && req.user.userId;
      if (!userId) {
        return res.status(401).json({ code: 401, message: 'Unauthorized' });
      }

      const { nickname, avatar_url } = req.body;

      await this.userService.updateUser(userId, { nickname, avatar_url });

      return res.json({ code: 0, message: 'OK' });
    } catch (err) {
      console.error('[User] 更新用户信息失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }

  /**
   * 同步用户信息
   * POST /api/users/sync
   */
  async syncUser(req, res) {
    try {
      const { phone_number, userId, nickname } = req.body;

      if (!phone_number) {
        return res.status(400).json({ code: 400, message: 'Missing phone_number' });
      }

      const result = await this.userService.syncUser(phone_number, userId, nickname);

      return res.json({
        code: 0,
        userId: result.userId
      });
    } catch (err) {
      console.error('[User] 同步用户信息失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }

  /**
   * 更新最后登录时间
   * POST /api/users/last-login
   */
  async updateLastLogin(req, res) {
    try {
      const userId = req.user && req.user.userId;
      if (!userId) {
        return res.status(401).json({ code: 401, message: 'Unauthorized' });
      }

      await this.userService.updateLastLogin(userId);

      return res.json({ code: 0, message: 'OK' });
    } catch (err) {
      console.error('[User] 更新最后登录时间失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }

  /**
   * 获取指定用户信息
   * GET /api/users/:userId
   */
  async getUser(req, res) {
    try {
      const { userId } = req.params;

      const user = await this.userService.getUserById(userId);
      if (!user) {
        return res.status(404).json({ code: 404, message: 'User not found' });
      }

      return res.json({
        code: 0,
        data: {
          userId: user.userId,
          phone: user.phone,
          nickname: user.nickname || '',
          avatar_url: user.avatar_url || ''
        }
      });
    } catch (err) {
      console.error('[User] 获取用户信息失败:', err);
      return res.status(500).json({ code: 500, message: 'Server Error' });
    }
  }
}

module.exports = UserController;