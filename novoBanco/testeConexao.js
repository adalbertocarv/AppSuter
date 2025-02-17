const { Pool } = require('pg');
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'dados_semob',
  schema: 'ponto_parada',
  password: '022002',
  port: 5432,
});

(async () => {
  try {
    const res = await pool.query('SELECT NOW()');
    console.log('Conexão bem-sucedida:', res.rows);
  } catch (error) {
    console.error('Erro ao conectar no banco:', error.message);
  } finally {
    pool.end();
  }
})();
