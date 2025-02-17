const express = require('express');
const app = express();

app.use(express.json());

const pontosRoutes = require('./routes/pontos.routes');
app.use('/api', pontosRoutes);

module.exports = app;
