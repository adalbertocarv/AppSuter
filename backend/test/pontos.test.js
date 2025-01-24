const request = require('supertest');
const app = require('../src/index'); // Certifique-se de exportar o `app` no arquivo index.js

describe('API de Pontos - Testes', () => {
  // Variável para armazenar o ID do ponto criado durante os testes
  let pontoId;

  // Teste de criação de um ponto
  it('Deve criar um novo ponto (POST /pontos)', async () => {
    const res = await request(app)
      .post('/pontos')
      .send({
        endereco: 'Rua Principal, 123',
        sentido: 'Norte',
        tipo: 'Ônibus',
        geom: { lon: -47.9292, lat: -15.7801 },
        ativo: true,
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.endereco).toBe('Rua Principal, 123');
    pontoId = res.body.id; // Armazena o ID para os próximos testes
  });

  // Teste de listagem de todos os pontos
  it('Deve listar todos os pontos (GET /pontos)', async () => {
    const res = await request(app).get('/pontos');
    expect(res.statusCode).toBe(200);
    expect(res.body).toBeInstanceOf(Array);
    expect(res.body[0]).toHaveProperty('latitude');
    expect(res.body[0]).toHaveProperty('longitude');
  });

  // Teste de busca de um ponto específico
  it('Deve buscar um ponto por ID (GET /pontos/:id)', async () => {
    const res = await request(app).get(`/pontos/${pontoId}`);
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('id', pontoId);
    expect(res.body).toHaveProperty('latitude');
    expect(res.body).toHaveProperty('longitude');
  });

  // Teste de busca de um ponto inexistente
  it('Deve retornar 404 para ponto inexistente (GET /pontos/:id)', async () => {
    const res = await request(app).get('/pontos/99999');
    expect(res.statusCode).toBe(404);
    expect(res.body.message).toBe('Ponto não encontrado');
  });

  // Teste de atualização de um ponto
  it('Deve atualizar um ponto existente (PUT /pontos/:id)', async () => {
    const res = await request(app)
      .put(`/pontos/${pontoId}`)
      .send({
        endereco: 'Rua Atualizada, 456',
        sentido: 'Sul',
        tipo: 'Trem',
        geom: { lon: -47.9000, lat: -15.8000 },
        ativo: false,
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.endereco).toBe('Rua Atualizada, 456');
    expect(res.body.sentido).toBe('Sul');
    expect(res.body.latitude).toBe(-15.8000);
    expect(res.body.longitude).toBe(-47.9000);
  });

  // Teste de exclusão de um ponto
  it('Deve excluir um ponto existente (DELETE /pontos/:id)', async () => {
    const res = await request(app).delete(`/pontos/${pontoId}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('Ponto removido com sucesso');
  });

  // Teste de exclusão de um ponto inexistente
  it('Deve retornar 404 para ponto inexistente (DELETE /pontos/:id)', async () => {
    const res = await request(app).delete(`/pontos/99999`);
    expect(res.statusCode).toBe(404);
    expect(res.body.message).toBe('Ponto não encontrado');
  });
});
