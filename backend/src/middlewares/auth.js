const jwt = require('jsonwebtoken');

const autenticarUsuario = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'Acesso não autorizado' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded; // Adiciona os dados do usuário no request
    next();
  } catch (error) {
    return res.status(403).json({ message: 'Token inválido' });
  }
};

module.exports = autenticarUsuario;
