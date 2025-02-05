const express = require('express');
const { buscarViasProximas } = require('../controllers/vias.controller');

const router = express.Router();

// Rota para buscar vias próximas
router.get('/proximas', buscarViasProximas);

module.exports = router;
