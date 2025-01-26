const express = require('express');
const router = express.Router();
const pontosController = require('../controllers/pontos.controller');
const autenticarUsuario = require('../middlewares/auth');

// Endpoints para CRUD de pontos
router.get('/', pontosController.consultarTodasParadas); // Lista todos os pontos
router.get('/:id', pontosController.consultarParadasById); // Obtém um ponto específico por ID
router.get('/:id/imagem', pontosController.consultarParadaImagem); // Buscar imagem do ponto por ID
router.post('/', autenticarUsuario, pontosController.criarParada); // Cria um ponto com autenticação
router.put('/:id', autenticarUsuario, pontosController.atualizarParada); // Atualiza um ponto por ID
router.delete('/:id', autenticarUsuario, pontosController.deletarParada); // Remove um ponto por ID

module.exports = router;
