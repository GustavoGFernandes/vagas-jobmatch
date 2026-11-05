require('dotenv').config();
const app = require('./app');

const porta = process.env.PORT || 8080;
app.listen(porta, () => console.log(`API do JobMatch rodando em http://localhost:${porta}/api`));
