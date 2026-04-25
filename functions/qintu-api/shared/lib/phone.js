/**
 * 手机号处理工具
 *
 * 统一处理中国手机号的规范化、验证等逻辑
 */

/**
 * 规范化手机号格式
 * 移除 +86、空格、横杠等前缀，返回 11 位纯数字
 *
 * @param {string} phone - 原始手机号（如 "+86 182 7714 5175"）
 * @returns {string} - 规范化后的 11 位手机号（如 "18277145175"）
 */
function normalizePhone(phone) {
  if (!phone) return '';
  let cleaned = phone.replace(/[^\d]/g, '');
  // 处理带国家代码的手机号（如 8618277145175 → 18277145175）
  if (cleaned.startsWith('86') && cleaned.length === 13) {
    cleaned = cleaned.substring(2);
  }
  return cleaned;
}

/**
 * 验证中国手机号格式
 *
 * @param {string} phone - 手机号（应为 11 位纯数字）
 * @returns {boolean} - 是否为有效中国手机号
 */
function isValidChinesePhone(phone) {
  return /^\d{11}$/.test(phone) && /^1[3-9]\d{9}$/.test(phone);
}

/**
 * 手机号脱敏（用于日志和显示）
 *
 * @param {string} phone - 原始手机号
 * @returns {string} - 脱敏后的手机号（如 "182****5175"）
 */
function maskPhone(phone) {
  if (!phone || phone.length < 7) return '***';
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}

module.exports = { normalizePhone, isValidChinesePhone, maskPhone };
