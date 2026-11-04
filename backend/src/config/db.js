const mysql = require('mysql2/promise');

// Pool de conexões com o MySQL, configurado pelas variáveis DB_* do .env
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  charset: 'utf8mb4',
  timezone: 'Z',             // datas trafegam em UTC; o navegador converte para o horário local
  decimalNumbers: true,      // DECIMAL (salários) chega como número, e não como texto
  dateStrings: ['DATE'],     // DATE chega como 'AAAA-MM-DD', sem mudar de dia por causa do fuso
});

// Toda conexão nova usa UTC, igual ao "timezone" acima
pool.on('connection', (conexao) => conexao.query("SET time_zone = '+00:00'"));

// Atalho: const linhas = await query('SELECT ... WHERE id = ?', [id])
async function query(sql, params) {
  const [linhas] = await pool.query(sql, params);
  return linhas;
}

// Executa várias consultas numa transação: se uma falhar, nada é gravado.
// Dentro da função, use db.query(sql, params), que devolve as linhas (ou o resultado do INSERT/UPDATE).
async function transacao(funcao) {
  const conexao = await pool.getConnection();
  const db = { query: async (sql, params) => (await conexao.query(sql, params))[0] };
  try {
    await conexao.beginTransaction();
    const resultado = await funcao(db);
    await conexao.commit();
    return resultado;
  } catch (erro) {
    await conexao.rollback();
    throw erro;
  } finally {
    conexao.release();
  }
}

async function testarConexao() {
  await pool.query('SELECT 1');
}

module.exports = { pool, query, transacao, testarConexao };
