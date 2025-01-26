const db = require('../db/db');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configura Multer para armazenar a imagem em memória
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    if (ext === '.jpg' || ext === '.jpeg' || ext === '.png') {
      cb(null, true);
    } else {
      cb(new Error('Apenas arquivos .jpg, .jpeg, and .png são permitidos'));
    }
  },
});

// Obter todos as paradas
exports.consultarTodasParadas = async (req, res) => {
  try {
    const query = `
      SELECT 
        id,
        endereco,
        sentido,
        tipo,
        imagem,
        ativo,
        ST_X(geom::geometry) AS longitude,  -- Extrai longitude
        ST_Y(geom::geometry) AS latitude,   -- Extrai latitude
        criado_em,
        atualizado_em
      FROM pontos;
    `;
    const result = await db.query(query);

    // Adicionar a URL da imagem a cada ponto
    const paradas = result.rows.map((parada) => {
      return {
        ...parada,
        imagemUrl: parada.imagem
          ? `${req.protocol}://${req.get('host')}/pontos/${parada.id}/imagem`
          : null, // Adiciona null caso a imagem não exista
        imagem: undefined, // Remove o campo imagem (não incluímos no retorno)
      };
    });

    res.status(200).json(paradas); // Retorna todas as paradas com a URL da imagem
  } catch (error) {
    console.error('Erro ao buscar as paradas:', error.message);
    res.status(500).json({ error: error.message });
  }
};


// Obter uma parada específica por ID
exports.consultarParadasById = async (req, res) => {
  try {
    const { id } = req.params;
    const query = `
      SELECT 
        id,
        endereco,
        sentido,
        tipo,
        imagem,
        ativo,
        ST_X(geom::geometry) AS longitude,
        ST_Y(geom::geometry) AS latitude,
        criado_em,
        atualizado_em
      FROM pontos
      WHERE id = $1;
    `;
    const result = await db.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Parada não encontrada' });
    }

    const ponto = result.rows[0];

    // Adicionar a URL da imagem no retorno, se existir
    if (ponto.imagem) {
      ponto.imagemUrl = `${req.protocol}://${req.get('host')}/pontos/${ponto.id}/imagem`;
    }

    // Remover o campo "imagem" para evitar expor o buffer
    delete ponto.imagem;

    res.status(200).json(ponto);
  } catch (error) {
    console.error('Erro ao buscar parada por ID:', error.message);
    res.status(500).json({ error: error.message });
  }
};
// Carregar a imagem
exports.consultarParadaImagem = async (req, res) => {
  try {
    const { id } = req.params;

    // Consulta para buscar os dados da imagem no banco
    const query = `SELECT imagem FROM pontos WHERE id = $1;`;
    const result = await db.query(query, [id]);

    if (result.rows.length === 0 || !result.rows[0].imagem) {
      return res.status(404).json({ message: 'Imagem não encontrada' });
    }

    const imagemBuffer = result.rows[0].imagem;

    // Envia os dados binários da imagem com o cabeçalho apropriado
    res.setHeader('Content-Type', 'image/jpeg'); // Ajuste o tipo de conteúdo conforme necessário
    res.send(imagemBuffer); // Envia o buffer da imagem diretamente
  } catch (error) {
    console.error('Error fetching image:', error.message);
    res.status(500).json({ error: error.message });
  }
};

// Criar um novo ponto
exports.criarParada = [
  upload.single('imagem'), // Middleware para lidar com o upload da imagem
  async (req, res) => {
    try {
      const { endereco, sentido, tipo, ativo, geom } = req.body;
      const imagem = req.file ? req.file.buffer : null; // Obter a imagem como buffer
      const { lon, lat } = JSON.parse(geom); // Parse de geom para obter latitude e longitude

      // Validar campos obrigatórios
      if (!endereco || !sentido || !tipo || !geom) {
        return res.status(400).json({ error: 'Faltando campos necessários' });
      }

      const query = `
        INSERT INTO pontos (endereco, sentido, tipo, imagem, ativo, geom, criado_em, atualizado_em)
        VALUES ($1, $2, $3, $4, $5, ST_SetSRID(ST_MakePoint($6, $7), 4326), NOW(), NOW())
        RETURNING *;
      `;
      const values = [endereco, sentido, tipo, imagem, ativo === 'true', lon, lat];
      const result = await db.query(query, values);

      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error('Erro criando parada:', error.message, error.stack);
      res.status(500).json({ error: error.message });
    }
  },
];

// Atualizar um ponto
exports.atualizarParada = async (req, res) => {
  try {
    const { id } = req.params;
    const { endereco, sentido, tipo, geom, ativo } = req.body;
    const { lon, lat } = JSON.parse(geom);

    const query = `
      UPDATE pontos
      SET 
        endereco = $1, 
        sentido = $2, 
        tipo = $3, 
        geom = ST_SetSRID(ST_MakePoint($4, $5), 4326), 
        ativo = $6
      WHERE id = $7
      RETURNING 
        id,
        endereco,
        sentido,
        tipo,
        ativo,
        ST_X(geom::geometry) AS longitude,
        ST_Y(geom::geometry) AS latitude,
        criado_em,
        atualizado_em;
    `;
    const values = [endereco, sentido, tipo, lon, lat, ativo === 'true', id];
    const result = await db.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Ponto não encontrado' });
    }

    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error('Error updating point:', error.message);
    res.status(500).json({ error: error.message });
  }
};

// Deletar um ponto
exports.deletarParada = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('DELETE FROM pontos WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Ponto não encontrado' });
    }

    res.status(200).json({ message: 'Ponto removido com sucesso' });
  } catch (error) {
    console.error('Error deleting point:', error.message);
    res.status(500).json({ error: error.message });
  }
};
