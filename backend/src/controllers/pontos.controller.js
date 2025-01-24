const db = require('../db/db');

// Obter todos os pontos
exports.getAllPontos = async (req, res) => {
    try {
        const query = `
      SELECT 
        id,
        endereco,
        sentido,
        tipo,
        ativo,
        ST_X(geom::geometry) AS longitude,  -- Extrai longitude
        ST_Y(geom::geometry) AS latitude,   -- Extrai latitude
        criado_em,
        atualizado_em
      FROM pontos;
      `;               
      const result = await db.query(query);
      res.status(200).json(result.rows);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };
  

// Obter ponto específico
exports.getPontoById = async (req, res) => {
    try {
      const { id } = req.params;
      const query = `
      SELECT 
        id,
        endereco,
        sentido,
        tipo,
        ativo,
        ST_X(geom::geometry) AS longitude,  -- Extrai longitude
        ST_Y(geom::geometry) AS latitude,   -- Extrai latitude
        criado_em,
        atualizado_em
      FROM pontos
      WHERE id = $1;
      `;
      const result = await db.query(query, [id]);
  
      if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Ponto não encontrado' });
      }
  
      res.status(200).json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };
  
// Criar um novo ponto
exports.createPonto = async (req, res) => {
  try {
    const { endereco, sentido, tipo, geom, ativo } = req.body;
    const query = `
      INSERT INTO pontos (endereco, sentido, tipo, geom, ativo)
      VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326), $6)
      RETURNING *;
    `;
    const values = [endereco, sentido, tipo, geom.lon, geom.lat, ativo];
    const result = await db.query(query, values);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Atualizar um ponto
exports.updatePonto = async (req, res) => {
    try {
      const { id } = req.params;
      const { endereco, sentido, tipo, geom, ativo } = req.body;
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
          ST_X(geom::geometry) AS longitude,  -- Extrai longitude
          ST_Y(geom::geometry) AS latitude,   -- Extrai latitude
          criado_em,
          atualizado_em;
      `;
      const values = [endereco, sentido, tipo, geom.lon, geom.lat, ativo, id];
      const result = await db.query(query, values);
  
      if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Ponto não encontrado' });
      }
  
      res.status(200).json(result.rows[0]);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };  

// Deletar um ponto
exports.deletePonto = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('DELETE FROM pontos WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Ponto não encontrado' });
    }
    res.status(200).json({ message: 'Ponto removido com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
