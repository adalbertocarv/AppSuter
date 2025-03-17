import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(File file, {int quality = 60, int maxWidth = 800}) async {
  // Lê a imagem original
  Uint8List imageBytes = await file.readAsBytes();
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) return file; // Se não conseguir processar, retorna a imagem original

  // Redimensiona a imagem mantendo a proporção
  img.Image resizedImage = img.copyResize(image, width: maxWidth);

  // Converte para JPEG com qualidade reduzida
  Uint8List compressedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: quality));

  // Criar um novo arquivo temporário para armazenar a imagem comprimida
  final tempDir = await getTemporaryDirectory();
  final compressedFile = File('${tempDir.path}/compressed_${file.path.split('/').last}');

  // Salva a imagem comprimida no novo arquivo
  await compressedFile.writeAsBytes(compressedBytes);

  return compressedFile;
}
