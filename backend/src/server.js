require('dotenv').config();
const app = require('./app');

if (!process.env.JWT_SECRET) {
  console.error('Defina JWT_SECRET no arquivo .env (veja o .env.example).');
  process.exit(1);
}

const porta = process.env.PORT || 8080;
app.listen(porta, () => console.log(`API do JobMatch rodando em http://localhost:${porta}/api`));
