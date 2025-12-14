// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// crie uma action para fazer o upload local de um arquivo do tipo csv de modo que após o upload eu possa passar como parametro para outra function que recebe um FFUploadedFile fazer a importacao no supabase
import 'package:file_picker/file_picker.dart';

Future<FFUploadedFile> uploadCsvFile() async {
  try {
    // Abre o seletor de arquivos para escolher apenas arquivos CSV
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;

      // Verifica se o arquivo tem dados
      if (file.bytes != null) {
        // Cria o objeto FFUploadedFile com os dados do arquivo CSV
        FFUploadedFile uploadedFile = FFUploadedFile(
          name: file.name,
          bytes: file.bytes!,
          height: null,
          width: null,
          blurHash: null,
        );

        return uploadedFile;
      } else {
        throw Exception('Arquivo não contém dados válidos');
      }
    } else {
      throw Exception('Nenhum arquivo foi selecionado');
    }
  } catch (e) {
    // Em caso de erro, retorna um FFUploadedFile vazio
    throw Exception('Erro ao fazer upload do arquivo CSV: $e');
  }
}
