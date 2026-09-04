import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pg_paint_widget.dart' show PgPaintWidget;
import 'package:flutter/material.dart';

class PgPaintModel extends FlutterFlowModel<PgPaintWidget> {
  late HeaderModel headerModel;
  late SideBarModel sideBarModel;

  FocusNode? codTransmissaoFocus;
  TextEditingController? codTransmissaoController;
  String? Function(BuildContext, String?)? codTransmissaoValidator;

  FocusNode? serieFazendaFocus;
  TextEditingController? serieFazendaController;
  String? Function(BuildContext, String?)? serieFazendaValidator;

  FocusNode? codFazendaFocus;
  TextEditingController? codFazendaController;
  String? Function(BuildContext, String?)? codFazendaValidator;

  // Série do registro da raça para animais PO (ex.: JLK). Inferida do brinco/
  // codRegistro quando possível; este campo é fallback na config PAINT.
  FocusNode? serieRacaPoFocus;
  TextEditingController? serieRacaPoController;
  String? Function(BuildContext, String?)? serieRacaPoValidator;

  bool carregandoConfig = true;
  bool salvandoConfig = false;
  bool exportando = false;
  bool baixandoExport = false;
  String? mensagemConfig;
  String? mensagemExport;
  String? linkUltimoZip;
  String? exportJobId;
  String? exportJobStatus;
  String? exportJobErro;
  String? exportNomeZip;
  String? exportStoragePath;
  DateTime? exportStartedAt;
  DateTime? exportFinishedAt;
  /// Duração estimada em segundos (heurística ou última exportação bem-sucedida).
  int? exportEstimatedSeconds;

  String? configId;
  String programa = 'P';
  String estrategiaA12 = 'compacto';
  String campoOrigemAnimal = 'numeroAnimal';

  bool carregandoStatus = true;
  bool importandoAuto = false;
  String? mensagemAuto;
  Map<String, int> counts = const {};

  bool resetandoPaint = false;
  String? mensagemReset;

  // Import do ANIMAL.TXT do PAINT (A12 oficial por animal).
  bool importandoA12Oficial = false;
  String? mensagemA12Oficial;
  int a12OficialTotal = 0;
  int a12OficialDivergentes = 0;

  bool exportandoExcel = false;
  bool importandoExcel = false;
  String? mensagemExcel;
  String? tipoExcelAtivo;

  // Filtros opcionais (data nascimento / data avaliação / status) do card
  // Status PAINT, aplicados em "Importar tudo do sistema".
  DateTime? importNascDe;
  DateTime? importNascAte;
  DateTime? importAvDe;
  DateTime? importAvAte;
  String? importStatus = 'Na propriedade';

  // Filtros opcionais por tipo de planilha, aplicados nas exportações Excel.
  final Map<String, DateTime?> excelNascDe = {
    'matrizes': null,
    'desmama': null,
    'sobreano': null,
    'cobertura': null,
  };
  final Map<String, DateTime?> excelNascAte = {
    'matrizes': null,
    'desmama': null,
    'sobreano': null,
    'cobertura': null,
  };
  final Map<String, DateTime?> excelAvDe = {
    'matrizes': null,
    'desmama': null,
    'sobreano': null,
    'cobertura': null,
  };
  final Map<String, DateTime?> excelAvAte = {
    'matrizes': null,
    'desmama': null,
    'sobreano': null,
    'cobertura': null,
  };
  final Map<String, String?> excelStatus = {
    'matrizes': 'Na propriedade',
    'desmama': 'Na propriedade',
    'sobreano': 'Na propriedade',
    // Cobertura filtra a reprodução, não o animal: o status do rebanho não se
    // aplica. Fica nulo para o contador de filtros não marcar um filtro que a
    // planilha ignora.
    'cobertura': null,
  };

  /// Tipo de reprodução da planilha de cobertura. Só essa planilha usa, por
  /// isso um mapa próprio em vez de mais uma chave nos de cima.
  final Map<String, String?> excelTipoRepro = {
    'cobertura': 'Inseminação',
  };

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
    codTransmissaoFocus?.dispose();
    codTransmissaoController?.dispose();
    serieFazendaFocus?.dispose();
    serieFazendaController?.dispose();
    codFazendaFocus?.dispose();
    codFazendaController?.dispose();
    serieRacaPoFocus?.dispose();
    serieRacaPoController?.dispose();
  }
}
