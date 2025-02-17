const express = require('express');
const router = express.Router();
const {
  criarParada,
  getParadaImagens,
  getTodasParadas
} = require('../controllers/paradas.controller'); 

//  Criar uma nova parada
router.post('/', criarParada);

//  Obter todas as paradas
router.get('/', getTodasParadas);

//  Obter imagens de uma parada específica
router.get('/:id/imagens', getParadaImagens);

module.exports = router;
