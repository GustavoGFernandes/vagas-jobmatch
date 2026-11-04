const jwt = require('jsonwebtoken');
const { ErroApi, proibido } = require('./erros');

function lerToken(req) {
  const [tipo, token] = (req.headers.authorization || '').split(' ');
  if (tipo !== 'Bearer' || !token) return null;
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch {
    throw new ErroApi(401, 'token_invalido', 'Sessão expirada ou inválida. Entre novamente.');
  }
}

// A rota exige login. Os dados do token ficam em req.usuario.
function autenticar(req, res, next) {
  const dados = lerToken(req);
  if (!dados) return next(new ErroApi(401, 'nao_autenticado', 'Faça login para continuar.'));
  req.usuario = dados;
  next();
}

// Rota pública que muda um pouco com login (ex.: mostra o match e os favoritos).
function autenticarOpcional(req, res, next) {
  req.usuario = lerToken(req) || null;
  next();
}

// Controle por perfil: exigirPerfil('RECRUTADOR'), exigirPerfil('CANDIDATO')...
const exigirPerfil = (...perfis) => (req, res, next) => {
  if (!req.usuario || !perfis.includes(req.usuario.perfil)) return next(proibido());
  next();
};

module.exports = { autenticar, autenticarOpcional, exigirPerfil };
