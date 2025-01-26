const fs = require('fs');
const request = require('supertest');
const app = require('../src/index'); // Certifique-se de que o caminho está correto

describe('API de Pontos - Testes', () => {
  let pontoId; // Variável para armazenar o ID do ponto criado
  let token; // Variável para armazenar o token de autenticação

  // Registrar usuário e fazer login antes dos testes
  beforeAll(async () => {
    // Registrar usuário
    await request(app).post('/usuarios/registro').send({
      nome: 'Teste',
      email: 'teste@example.com',
      senha: '123456',
    });

    // Fazer login e obter o token
    const res = await request(app).post('/usuarios/login').send({
      email: 'teste@example.com',
      senha: '123456',
    });

    token = res.body.token; // Armazena o token para uso nos testes
  });

  // Teste de criação de um ponto com imagem
  const path = require('path');

  it('Deve criar um novo ponto com imagem (POST /pontos)', async () => {
    const res = await request(app)
      .post('/pontos')
      .set('Authorization', `Bearer ${token}`) // Adiciona o token no cabeçalho
      .field('endereco', 'Rua Principal, 123')
      .field('sentido', 'Norte')
      .field('tipo', 'Ônibus')
      .field('geom', JSON.stringify({ lon: -47.9292, lat: -15.7801 }))
      .field('ativo', true)
      .attach(
        'imagem',
        fs.readFileSync(path.join(__dirname, 'tesla.jpeg')), // Ajusta o caminho do arquivo
        'tesla.jpeg'
      );
  
    expect(res.statusCode).toBe(201); // Verifica o status
    expect(res.body).toHaveProperty('id'); // Verifica se o ID foi retornado
    expect(res.body.endereco).toBe('Rua Principal, 123'); // Verifica o endereço
    pontoId = res.body.id; // Armazena o ID para outros testes
  });  

  // Teste de listagem de todos os pontos
  it('Deve listar todos os pontos (GET /pontos)', async () => {
    const res = await request(app)
      .get('/pontos')
      .set('Authorization', `Bearer ${token}`); // Adiciona o token no cabeçalho

    expect(res.statusCode).toBe(200);
    expect(res.body).toBeInstanceOf(Array);
    if (res.body.length > 0) {
      expect(res.body[0]).toHaveProperty('latitude');
      expect(res.body[0]).toHaveProperty('longitude');
    }
  });

  // Teste de busca de um ponto específico por ID
  it('Deve buscar um ponto por ID (GET /pontos/:id)', async () => {
    const res = await request(app)
      .get(`/pontos/${pontoId}`)
      .set('Authorization', `Bearer ${token}`); // Adiciona o token no cabeçalho

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('id', pontoId);
    expect(res.body).toHaveProperty('latitude');
    expect(res.body).toHaveProperty('longitude');
  });

  // Teste de busca de um ponto inexistente
  it('Deve retornar 404 para ponto inexistente (GET /pontos/:id)', async () => {
    const res = await request(app)
      .get('/pontos/99999')
      .set('Authorization', `Bearer ${token}`); // Adiciona o token no cabeçalho

    expect(res.statusCode).toBe(404);
    expect(res.body.message).toBe('Parada não encontrada');
  });

  // Teste de atualização de um ponto existente
  it('Deve atualizar um ponto existente (PUT /pontos/:id)', async () => {
    const res = await request(app)
      .put(`/pontos/${pontoId}`)
      .set('Authorization', `Bearer ${token}`) // Adiciona o token no cabeçalho
      .send({
        endereco: 'Rua Atualizada, 456',
        sentido: 'Sul',
        tipo: 'Trem',
        geom: JSON.stringify({ lon: -47.9000, lat: -15.8000 }),
        ativo: false,
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.endereco).toBe('Rua Atualizada, 456');
    expect(res.body.sentido).toBe('Sul');
    expect(res.body.latitude).toBeCloseTo(-15.8000);
    expect(res.body.longitude).toBeCloseTo(-47.9000);
  });

  // Teste de exclusão de um ponto existente
  it('Deve excluir um ponto existente (DELETE /pontos/:id)', async () => {
    const res = await request(app)
      .delete(`/pontos/${pontoId}`)
      .set('Authorization', `Bearer ${token}`); // Adiciona o token no cabeçalho

    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('Ponto removido com sucesso');
  });

  // Teste de exclusão de um ponto inexistente
  it('Deve retornar 404 para ponto inexistente (DELETE /pontos/:id)', async () => {
    const res = await request(app)
      .delete('/pontos/99999')
      .set('Authorization', `Bearer ${token}`); // Adiciona o token no cabeçalho

    expect(res.statusCode).toBe(404);
    expect(res.body.message).toBe('Ponto não encontrado');
  });
});
