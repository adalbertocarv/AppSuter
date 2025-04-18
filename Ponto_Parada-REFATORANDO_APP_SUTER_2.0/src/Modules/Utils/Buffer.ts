import * as sharp from 'sharp';

export async function convertBase64ToBuffer(
    base64String: string | null | undefined,
    porcentagem: number = 50, // Redução de tamanho em porcentagem
    qualidade: number = 50 // Qualidade da imagem (0 a 100, onde 100 é máxima qualidade)
): Promise<Buffer | null> {
    if (!base64String || base64String.trim() === "") {
        console.warn("⚠️ Aviso: Imagem Base64 vazia ou inválida. Ignorando conversão.");
        return null;
    }

    try {
        // Converter Base64 para Buffer
        const imageBuffer = Buffer.from(base64String, 'base64');

        // Obtém metadados da imagem
        const metadata = await sharp(imageBuffer).metadata();

        // Calcula o novo tamanho baseado na porcentagem fornecida
        const novaLargura = Math.floor(metadata.width! * (porcentagem / 100));
        const novaAltura = Math.floor(metadata.height! * (porcentagem / 100));

        // Redimensiona e aplica compressão de qualidade
        const resizedBuffer = await sharp(imageBuffer)
            .resize({ width: novaLargura, height: novaAltura })
            .jpeg({ quality: qualidade }) // Aplica compressão na qualidade
            .toBuffer();

        return resizedBuffer;
    } catch (error) {
        console.error("❌ Erro ao processar a imagem:", error);
        return null;
    }
}
