// Erro "esperado" da API: vira uma resposta { erro, mensagem } com o status HTTP indicado.
class ErroApi extends Error {
  constructor(status, codigo, mensagem, detalhes) {
    super(mensagem);
    this.status = status;
    this.codigo = codigo;
    this.detalhes = detalhes;
  }
}

const naoEncontrado = (mensagem) => new ErroApi(404, 'nao_encontrado', mensagem);
const proibido = (mensagem = 'Você não tem permissão para esta ação.') => new ErroApi(403, 'proibido', mensagem);
const conflito = (codigo, mensagem) => new ErroApi(409, codigo, mensagem);
const invalido = (detalhes) => new ErroApi(400, 'dados_invalidos', 'Alguns campos estão inválidos.', detalhes);

// Lê um id numérico da URL ou do corpo
function lerId(valor) {
  const id = Number(valor);
  if (!Number.isInteger(id) || id <= 0) throw invalido({ id: 'Identificador inválido.' });
  return id;
}

function rotaNaoEncontrada(req, res) {
  res.status(404).json({ erro: 'rota_nao_encontrada', mensagem: `Rota ${req.method} ${req.path} não existe.` });
}

// Último middleware do app: transforma qualquer erro em JSON
// eslint-disable-next-line no-unused-vars
function tratarErros(erro, req, res, next) {
  if (erro instanceof ErroApi) {
    return res.status(erro.status).json({ erro: erro.codigo, mensagem: erro.message, detalhes: erro.detalhes });
  }
  if (erro.type === 'entity.parse.failed') {
    return res.status(400).json({ erro: 'json_invalido', mensagem: 'O corpo da requisição não é um JSON válido.' });
  }
  // Restrições do banco que escaparam das validações
  if (erro.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ erro: 'duplicado', mensagem: 'Esse registro já existe.' });
  }
  if (['ER_CHECK_CONSTRAINT_VIOLATED', 'ER_NO_REFERENCED_ROW_2', 'ER_DATA_TOO_LONG', 'ER_TRUNCATED_WRONG_VALUE_FOR_FIELD', 'WARN_DATA_TRUNCATED'].includes(erro.code)) {
    return res.status(400).json({ erro: 'dados_invalidos', mensagem: 'Os dados enviados não são válidos.' });
  }
  console.error(erro);
  res.status(500).json({ erro: 'erro_interno', mensagem: 'Erro inesperado no servidor.' });
}

module.exports = { ErroApi, naoEncontrado, proibido, conflito, invalido, lerId, rotaNaoEncontrada, tratarErros };
