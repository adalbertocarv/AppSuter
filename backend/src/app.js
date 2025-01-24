const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');

// Configurar variáveis de ambiente
dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Rotas
app.use('/pontos', require('./routes/pontos.routes'));

module.exports = app;
