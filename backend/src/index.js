// Importações principais
const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');

// Configuração de variáveis de ambiente
dotenv.config();

// Inicialização do Express
const app = express();
const PORT = process.env.PORT || 3001;

// Importação de rotas
const usuariosRoutes = require('./routes/usuarios.routes');
const pontosRoutes = require('./routes/pontos.routes');
const baciasRoutes = require('./routes/bacias.routes');
const rasRoutes = require('./routes/ras.routes'); // Rotas de RAS
const viasRoutes = require('./routes/vias.routes');  
const paradasRoutes = require('./routes/paradas.routes');

// Middlewares globais
app.use(cors()); // Habilitar CORS
app.use(express.json()); // Parsing de JSON no corpo das requisições

// Definição de rotas
app.use('/pontos', pontosRoutes); // Rotas de pontos
app.use('/usuarios', usuariosRoutes); // Rotas de usuários
app.use('/bacias', baciasRoutes); //  rota para bacias
app.use('/ras', rasRoutes); //  rota para RAS
app.use('/vias', viasRoutes); //   rota para vias
app.use('/paradas', paradasRoutes); 

// Inicialização do servidor (somente fora de ambiente de teste)
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Servidor rodando em http://localhost:${PORT}`);
  });
}

// Exportação do app para testes
module.exports = app;
