const express = require('express');
const router = express.Router();
const pontosController = require('../controllers/pontos.controller');
const autenticarUsuario = require('../middlewares/auth');

// Endpoints
router.get('/', pontosController.getAllPontos);
router.get('/:id', pontosController.getPontoById);
router.post('/', autenticarUsuario, pontosController.createPonto);
router.put('/:id', autenticarUsuario, pontosController.updatePonto);
router.delete('/:id', autenticarUsuario, pontosController.deletePonto);


module.exports = router;
