/**
 * 测试 Web 函数
 */
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Hello from qintu-api!' });
});

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'qintu-api is running' });
});

const PORT = process.env.PORT || 9000;
const server = app.listen(PORT, () => {
  console.log(`qintu-test running on port ${PORT}`);
});

exports.main = app;
