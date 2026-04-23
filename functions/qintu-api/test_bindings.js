const db = require('./lib/database_config');

const openid = 'mock_openid_05f0671d60250e79';

const sql = `(SELECT b.id, b.status, b.remark, b.created_at, b.updated_at,
        'sender' as my_role,
        r.openid as partner_openid, r.nickname as partner_nickname,
        r.phone as partner_phone, r.user_type as partner_type,
        b.sender_openid, b.receiver_openid
 FROM user_bindings b
 INNER JOIN users r ON b.receiver_openid = r.openid
 WHERE b.sender_openid = ? AND b.status = 'active')
UNION ALL
(SELECT b.id, b.status, b.remark, b.created_at, b.updated_at,
        'receiver' as my_role,
        s.openid as partner_openid, s.nickname as partner_nickname,
        s.phone as partner_phone, s.user_type as partner_type,
        b.sender_openid, b.receiver_openid
 FROM user_bindings b
 INNER JOIN users s ON b.sender_openid = s.openid
 WHERE b.receiver_openid = ? AND b.status = 'active')
ORDER BY created_at DESC`;

db.query(sql, [openid, openid]).then(result => {
  console.log('Query returned', result.length, 'rows');
  console.log('Result:', JSON.stringify(result, null, 2));
}).catch(err => {
  console.error('Query error:', err);
});
