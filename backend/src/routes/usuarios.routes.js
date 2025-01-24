const express = require('express');
const router = express.Router();
const usuariosController = require('../controllers/usuarios.controller');

// Rotas
router.post('/registro', usuariosController.registrarUsuario); // Registrar
router.post('/login', usuariosController.loginUsuario);        // Login

module.exports = router;