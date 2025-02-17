const pool = require('../db/db');
const multer = require('multer');
const path = require('path');

// Configuração do Multer para armazenar várias imagens em memória
const storage = multer.memoryStorage();
const upload = multer({ storage: storage }).fields([
  { name: 'imagens', maxCount: 5 } 
]);

// Criar uma nova parada com imagens e abrigos
const criarParada = [
  upload, // Middleware para múltiplas imagens
  async (req, res) => {
    try {
      const { endereco, haAbrigo, linhasTransporte, latitude, longitude, latLongInterpolado, abrigos } = req.body;

      //  Inserir parada na tabela `paradas`
      const paradaResult = await pool.query(
        `INSERT INTO paradas (endereco, ha_abrigo, linhas_transporte, latitude, longitude, latlong_interpolado, created_at) 
         VALUES ($1, $2, $3, $4, $5, $6, NOW()) RETURNING id`,
        [endereco, haAbrigo, linhasTransporte, latitude, longitude, latLongInterpolado]
      );

      const paradaId = paradaResult.rows[0].id;

      //  Inserir abrigos associados
      if (abrigos) {
        const parsedAbrigos = JSON.parse(abrigos);
        for (const abrigo of parsedAbrigos) {
          await pool.query(
            `INSERT INTO abrigos (parada_id, tipo, tem_patologia, tem_acessibilidade) 
             VALUES ($1, $2, $3, $4)`,
            [paradaId, abrigo.tipoAbrigo, abrigo.temPatologia, abrigo.temAcessibilidade]
          );
        }
      }

      //  Inserir imagens na tabela `imagens`
      if (req.files && req.files['imagens']) {
        for (const file of req.files['imagens']) {
          await pool.query(
            `INSERT INTO imagens (parada_id, imagem) VALUES ($1, $2)`,
            [paradaId, file.buffer]
          );
        }
      }

      res.status(201).json({ message: "Parada criada com sucesso!", paradaId });

    } catch (error) {
      console.error('Erro ao criar parada:', error);
      res.status(500).json({ error: "Erro ao criar a parada." });
    }
  }
];

//  Obter as imagens de uma parada específica
const getParadaImagens = async (req, res) => {
  try {
    const { id } = req.params;
    const query = `SELECT imagem FROM imagens WHERE parada_id = $1;`;
    const result = await pool.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Nenhuma imagem encontrada' });
    }

    res.setHeader('Content-Type', 'image/jpeg');
    res.send(result.rows[0].imagem); // Retorna a primeira imagem
  } catch (error) {
    console.error('Erro ao buscar imagens:', error.message);
    res.status(500).json({ error: "Erro ao buscar as imagens." });
  }
};

//  Obter todas as paradas com abrigos e imagens
const getTodasParadas = async (req, res) => {
  try {
    const query = `
      SELECT p.*, 
             COALESCE(json_agg(DISTINCT a) FILTER (WHERE a.id IS NOT NULL), '[]') AS abrigos,
             COALESCE(json_agg(DISTINCT i.imagem) FILTER (WHERE i.id IS NOT NULL), '[]') AS imagens
      FROM paradas p
      LEFT JOIN abrigos a ON p.id = a.parada_id
      LEFT JOIN imagens i ON p.id = i.parada_id
      GROUP BY p.id;
    `;
    const result = await pool.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erro ao buscar paradas:', error.message);
    res.status(500).json({ error: "Erro ao buscar as paradas." });
  }
};

module.exports = {
  criarParada,
  getParadaImagens,
  getTodasParadas
};
