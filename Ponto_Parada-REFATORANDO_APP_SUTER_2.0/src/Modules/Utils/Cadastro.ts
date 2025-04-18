export const visitaData = (data: any) => ({
  data_visita: data.data_visita,
  rampa_acessivel: data.rampa_acessivel ?? false,
  piso_tatil: data.piso_tatil ?? false,
  patologia: data.patologia ?? false,
  abrigos: data.abrigos?.map((abrigo: any) => ({
    id_abrigo: abrigo.id_abrigo, // ⚠️ agora obrigatório para associar patologias às imagens
    patologias: abrigo.patologias?.map((patologia: any) => ({
      id_tipo_patologia: patologia.id_tipo_patologia,
      imagens: patologia.imagens ?? []
    })) ?? []
  })) ?? []
});
