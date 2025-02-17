const pool = require('../db/db');

exports.criarPontoParadaCompleto = async (req, res) => {
    const client = await pool.connect();

    try {
        await client.query('BEGIN'); // Inicia a transação

        // 🔹 Captura os dados do request
        const {
            usuario_id,
            geom,
            endereco,
            ponto_interpolado,
            abrigo,
            imagens,
            vistoria
        } = req.body;

        // 🔹 Validação básica
        if (!usuario_id || !geom || !endereco) {
            throw new Error("Campos obrigatórios: usuario_id, geom e endereco");
        }

        console.log("✅ Criando ponto de parada...");

        // 1️⃣ Criar o ponto de parada
        const pontoResult = await client.query(
            `INSERT INTO ponto_parada.tab_ponto_parada (id_usuario, geom, endereco) 
             VALUES ($1, ST_GeomFromText($2, 4326), $3) RETURNING id_ponto_parada`,
            [usuario_id, geom, endereco]
        );
        const idPontoParada = pontoResult.rows[0].id_ponto_parada;

        // 2️⃣ Criar ponto interpolado (se existir)
        if (ponto_interpolado) {
            console.log("✅ Criando ponto interpolado...");
            await client.query(
                `INSERT INTO ponto_parada.tab_ponto_interpol (id_ponto_parada, geom_interpol) 
                 VALUES ($1, ST_GeomFromText($2, 4326))`,
                [idPontoParada, ponto_interpolado.geom]
            );
        }

        // 3️⃣ Criar abrigo (se existir)
        let idAbrigo = null;
        if (abrigo) {
            console.log("✅ Criando abrigo...");
            const abrigoResult = await client.query(
                `INSERT INTO ponto_parada.tab_abrigo (id_ponto_parada, id_tipo_abrigo) 
                 VALUES ($1, $2) RETURNING id_abrigo`,
                [idPontoParada, abrigo.tipo_abrigo_id]
            );
            idAbrigo = abrigoResult.rows[0].id_abrigo;
        }

        // 4️⃣ Salvar imagens (se existirem)
        if (imagens && imagens.length > 0) {
            console.log(`✅ Salvando ${imagens.length} imagens...`);
            for (const img of imagens) {
                await client.query(
                    `INSERT INTO ponto_parada.tab_imagem (id_ponto_parada, id_abrigo, imagem) 
                     VALUES ($1, $2, $3)`,
                    [idPontoParada, idAbrigo, Buffer.from(img.arquivo, 'base64')]
                );
            }
        }

        // 5️⃣ Criar vistoria (se existir)
        let idVistoria = null;
        if (vistoria) {
            console.log("✅ Criando vistoria...");
            const vistoriaResult = await client.query(
                `INSERT INTO ponto_parada.tab_vistoria (id_ponto_parada, data_vistoria) 
                 VALUES ($1, $2) RETURNING id_vistoria`,
                [idPontoParada, vistoria.data_vistoria]
            );
            idVistoria = vistoriaResult.rows[0].id_vistoria;

            // 6️⃣ Inserir patologias associadas à vistoria
            if (vistoria.patologias && vistoria.patologias.length > 0) {
                console.log(`✅ Inserindo ${vistoria.patologias.length} patologias...`);
                for (const idPatologia of vistoria.patologias) {
                    await client.query(
                        `INSERT INTO ponto_parada.tab_vistoria_patologia (id_vistoria, id_abrigo, id_patologia) 
                         VALUES ($1, $2, $3)`,
                        [idVistoria, idAbrigo, idPatologia]
                    );
                }
            }

            // 7️⃣ Inserir acessibilidade associada à vistoria
            if (vistoria.acessibilidade && vistoria.acessibilidade.length > 0) {
                console.log(`✅ Inserindo acessibilidade...`);
                for (const acessibilidade of vistoria.acessibilidade) {
                    const acessibilidadeResult = await client.query(
                        `SELECT id_acessibilidade FROM ponto_parada.tab_acessibilidade WHERE descricao = $1`,
                        [acessibilidade]
                    );

                    if (acessibilidadeResult.rows.length === 0) {
                        console.warn(`⚠️ Aviso: Acessibilidade '${acessibilidade}' não encontrada. Ignorando...`);
                        continue; // Ignora se não encontrar
                    }

                    const idAcessibilidade = acessibilidadeResult.rows[0].id_acessibilidade;

                    await client.query(
                        `INSERT INTO ponto_parada.tab_vistoria_acessibilidade (id_vistoria, id_abrigo, id_acessibilidade) 
             VALUES ($1, $2, $3)`,
                        [idVistoria, idAbrigo, idAcessibilidade]
                    );
                }
            }


            // 8️⃣ Salvar imagens da vistoria
            if (vistoria.imagens && vistoria.imagens.length > 0) {
                console.log(`✅ Salvando imagens da vistoria...`);
                for (const img of vistoria.imagens) {
                    await client.query(
                        `INSERT INTO ponto_parada.tab_imagem (id_vistoria, imagem) 
                         VALUES ($1, $2)`,
                        [idVistoria, Buffer.from(img.arquivo, 'base64')]
                    );
                }
            }
        }

        // 🔥 Finaliza a transação
        await client.query('COMMIT');

        // ✅ Retorna sucesso
        res.status(201).json({
            id_ponto_parada: idPontoParada,
            id_abrigo: idAbrigo,
            id_vistoria: idVistoria,
            message: "Ponto de parada cadastrado com sucesso!"
        });

    } catch (error) {
        await client.query('ROLLBACK'); // ⚠️ Se der erro, desfaz tudo
        console.error("❌ ERRO:", error);
        res.status(500).json({ error: "Erro ao salvar ponto de parada." });
    } finally {
        client.release(); // Libera conexão
    }
};
