const express = require('express');
const router = express.Router();
const baciasController = require('../controllers/bacias.controller');

// Endpoint para obter as bacias
router.get('/', baciasController.getBacias);

module.exports = router;
