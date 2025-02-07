const db = require('../db/db');

const buscarViasProximas = async (req, res) => {
    const { latitude, longitude } = req.query;

    if (!latitude || !longitude) {
        return res.status(400).json({ error: 'Latitude e longitude são obrigatórias' });
    }

    try {
        const query = `
      SELECT json_build_object(
    'type', 'FeatureCollection',
    'features', json_agg(
        json_build_object(
            'type', 'Feature',
            'geometry', ST_AsGeoJSON(ST_Transform(geom, 4326))::json,
            'properties', json_build_object(
                'seq_vias', seq_vias,
                'cod_seguimento_pista', cod_seguimento_pista,
                'dsc_nome', dsc_nome,
                'dsc_nome_seguimento_pista', dsc_nome_seguimento_pista,
                'dsc_principal', dsc_principal,
                'dsc_complemento', dsc_complemento,
                'bln_rota_onibus', bln_rota_onibus
            )
        )
    )
) AS geojson_result
FROM public.tab_vias
WHERE ST_DWithin(
    ST_Transform(geom, 4326)::geography, 
    ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography, 
    50
);
    `;

        const result = await db.query(query, [longitude, latitude]);
        res.json(result.rows[0].geojson_result);

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Erro ao buscar vias próximas' });
    }
};

module.exports = { buscarViasProximas };
