const db = require('../db/db');

exports.getBacias = async (req, res) => {
  try {
    const query = `
SELECT jsonb_build_object(
  'type', 'FeatureCollection',
  'features', jsonb_agg(
    jsonb_build_object(
      'type', 'Feature',
      'properties', jsonb_build_object(
        'seq_bacia', seq_bacia,
        'dsc_bacia', dsc_bacia,
        'cod_bacia', cod_bacia
      ),
      'geometry', ST_AsGeoJSON(ST_Transform(ST_Multi(geo_bacia), 4326))::jsonb
    )
  )
) AS geojson
FROM public.tab_bacias;
    `;    const result = await db.query(query);

    // Retorna os dados em formato JSON
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Erro ao buscar as bacias:', error.message);
    res.status(500).json({ error: 'Erro ao buscar as bacias' });
  }
};
