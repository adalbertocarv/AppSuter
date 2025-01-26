const express = require('express');
const router = express.Router();
const pontosController = require('../controllers/pontos.controller');
const autenticarUsuario = require('../middlewares/auth');

// Endpoints para CRUD de pontos
router.get('/', pontosController.getAllPontos); // Lista todos os pontos
router.get('/:id', pontosController.getPontoById); // Obtém um ponto específico por ID
router.get('/:id/imagem', pontosController.getPontoImagem); // Buscar imagem do ponto por ID
router.post('/', autenticarUsuario, pontosController.createPonto); // Cria um ponto com autenticação
router.put('/:id', autenticarUsuario, pontosController.updatePonto); // Atualiza um ponto por ID
router.delete('/:id', autenticarUsuario, pontosController.deletePonto); // Remove um ponto por ID

module.exports = router;
