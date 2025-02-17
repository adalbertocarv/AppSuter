require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT
});

// Configura o esquema padrão ao conectar
(async () => {
    try {
        const client = await pool.connect();
        await client.query(`SET search_path TO ${process.env.DB_SCHEMA}, public`);
        console.log(`✅ Conectado ao PostgreSQL no esquema: ${process.env.DB_SCHEMA}`);
        client.release();
    } catch (error) {
        console.error("❌ Erro ao conectar ao banco:", error);
    }
})();

module.exports = pool;
