const db = require('../db/db'); // Importa a conexão com o banco de dados

// Controlador para buscar todas as regiões administrativas (RAS)
exports.getRas = async (req, res) => {
  try {
    // Query para buscar as RAS com geometria em GeoJSON
    const query = `
SELECT jsonb_build_object(
  'type', 'FeatureCollection',
  'features', jsonb_agg(
    jsonb_build_object(
      'type', 'Feature',
      'properties', jsonb_build_object(
        'seq_ras', seq_ras,
        'dsc_nome', dsc_nome,
        'dsc_prefixo_ra', dsc_prefixo_ra,
        'dsc_area', dsc_area
      ),
      'geometry', ST_AsGeoJSON(ST_Transform(geom, 4326))::jsonb
    )
  )
) AS geojson
FROM public.tab_ras;
    `;
    const result = await db.query(query);

    // Retorna os dados em formato JSON
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erro ao buscar as RAS:', error.message);
    res.status(500).json({ error: 'Erro ao buscar as RAS' });
  }
};
