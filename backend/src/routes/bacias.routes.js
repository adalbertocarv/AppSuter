const express = require('express');
const router = express.Router();
const baciasController = require('../controllers/bacias.controller');

router.get('/', baciasController.getBacias);

module.exports = router;
