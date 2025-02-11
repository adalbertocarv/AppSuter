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
            'geometry', ST_AsGeoJSON(ST_Transform(geo_rede_via, 4326))::json,
            'properties', json_build_object(
                'seq_rede_via', seq_rede_via,
                'seq_rede_v', seq_rede_v,
                'dsc_rede_v', dsc_rede_v,
                'seq_tipo_v', seq_tipo_v,
                'num_veloci', num_veloci,
                'bln_pavime', bln_pavime,
                'num_extens', num_extens
            )
        )
    )
) AS geojson_result
FROM public.tab_rede_vias trv
WHERE ST_DWithin(
    ST_Transform(geo_rede_via, 4326)::geography, 
    ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography, 
    100
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
