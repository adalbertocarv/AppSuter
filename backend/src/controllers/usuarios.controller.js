const db = require('../db/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Registrar Usuário
exports.registrarUsuario = async (req, res) => {
  const { nome, email, senha } = req.body;
  try {
    // Verificar se o e-mail já está em uso
    const emailExistente = await db.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (emailExistente.rows.length > 0) {
      return res.status(400).json({ message: 'E-mail já está em uso' });
    }

    // Hash da senha
    const salt = await bcrypt.genSalt(10);
    const senhaHash = await bcrypt.hash(senha, salt);

    // Inserir o usuário no banco
    const query = `
      INSERT INTO usuarios (nome, email, senha)
      VALUES ($1, $2, $3)
      RETURNING id, nome, email, criado_em;
    `;
    const values = [nome, email, senhaHash];
    const result = await db.query(query, values);

    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Login de Usuário
exports.loginUsuario = async (req, res) => {
  const { email, senha } = req.body;
  try {
    // Verificar se o e-mail existe
    const usuario = await db.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (usuario.rows.length === 0) {
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }

    // Comparar senha
    const senhaValida = await bcrypt.compare(senha, usuario.rows[0].senha);
    if (!senhaValida) {
      return res.status(401).json({ message: 'Senha inválida' });
    }

    // Gerar token JWT
    const token = jwt.sign(
      { id: usuario.rows[0].id, email: usuario.rows[0].email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' } // Token expira em 1 hora
    );

    res.status(200).json({ token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};