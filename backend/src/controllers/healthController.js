const { testarConexao } = require('../config/db');

// GET /api/health — status da API e teste da conexão com o MySQL
async function verificar(req, res) {
  try {
    await testarConexao();
    res.json({ status: 'ok', banco: 'conectado' });
  } catch (erro) {
    res.status(503).json({ status: 'erro', banco: 'sem conexão', mensagem: erro.message });
  }
}

module.exports = { verificar };
