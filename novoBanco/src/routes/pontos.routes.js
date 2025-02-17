const express = require('express');
const router = express.Router();
const pontosController = require('../controllers/pontos.controller');

router.post('/ponto-parada-completo', pontosController.criarPontoParadaCompleto);

module.exports = router;
