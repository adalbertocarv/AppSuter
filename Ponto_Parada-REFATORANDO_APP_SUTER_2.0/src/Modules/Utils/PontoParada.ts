export function generateImageLink(abrigoNome: string | null): string | null {
    return abrigoNome ? `http://localhost:3000/paradas/${encodeURIComponent(abrigoNome)}/imagem` : null;
  }
  
  export function formatPontoParada(pontosParada: any[]): any[] {
    return pontosParada.map(ponto => ({
      ...ponto,
      abrigo_img: generateImageLink(ponto.abrigo_nome),
    }));
  }
  
// utils/PontoParadaUtils.ts
export const pontoParadaData = (data: any) => ({
    id_usuario: data.id_usuario,
    latitude: data.latitude,
    longitude: data.longitude,
    endereco: data.endereco,
    dt_atualizacao: data.dt_atualizacao,
    linha_escolar: data.linha_escolar,
    linha_stpc: data.linha_stpc,
    baia: data.baia,
    latitudeInterpolado: data.latitudeInterpolado,
    longitudeInterpolado: data.longitudeInterpolado,
    rampa_acessivel: data.rampa_acessivel ?? false,
    piso_tatil: data.piso_tatil ?? false,
    patologia: data.patologia ?? false,
    abrigos: data.abrigos?.map((abrigo: any) => ({
        id_tipo_abrigo: abrigo.id_tipo_abrigo,
        imagens: abrigo.imagens ?? [],
        patologias: abrigo.patologias?.map((patologia: any) => ({
            id_tipo_patologia: patologia.id_tipo_patologia,
            imagens: patologia.imagens ?? []
        })) ?? []
    })) ?? []
});
