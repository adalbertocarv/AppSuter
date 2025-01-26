const express = require('express');
const router = express.Router();
const rasController = require('../controllers/ras.controller');

// Endpoint para obter todas as RAS
router.get('/', rasController.getRas);

module.exports = router;
