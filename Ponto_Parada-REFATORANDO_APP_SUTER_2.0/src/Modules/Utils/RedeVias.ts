export class RedeViasUtils {
    /**
     * Formata o resultado da consulta para retornar JSON válido.
     * O banco de dados já retorna GeoJSON, então apenas garante que o JSON esteja correto.
     * @param result - Resultado da query SQL (lista de objetos)
     * @returns Lista de objetos no formato correto
     */
    static formatGeoJson(result: any[]): any[] {
      return result.map(row => ({
        vias_proximas: JSON.parse(row.vias_proximas) // Garante que o dado seja JSON válido
      }));
    }
  }
  