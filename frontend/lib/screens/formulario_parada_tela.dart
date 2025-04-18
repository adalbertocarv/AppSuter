import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/ponto_model.dart';
import '../providers/ponto_parada_provider.dart';
import '../services/login_service.dart';

class FormularioParadaTela extends StatefulWidget {
  final LatLng latLng;
  final LatLng latLongInterpolado;
  final Map<String, dynamic>? initialData;
  final int? index;

  const FormularioParadaTela({
    super.key,
    required this.latLng,
    required this.latLongInterpolado,
    this.initialData,
    this.index,
  });

  @override
  _FormularioParadaTelaState createState() => _FormularioParadaTelaState();
}

class _FormularioParadaTelaState extends State<FormularioParadaTela> {
  final TextEditingController _addressController = TextEditingController();
  bool _linhaEscolares = false;
  bool _linhaStpc = false;
  bool _baia = false;
  bool _pisoTatil = false;
  bool _rampa = false;
  bool _patologia = false;
  bool _temAbrigo = false;
  bool _temPatologia = false;
  LatLng? _pontoSelecionado;
  int? _idUsuario;
  DateTime _dataVisita = DateTime.now();
  TimeOfDay _horaVisita = TimeOfDay.now();
  List<Map<String, dynamic>> _abrigos = [];
  String? _tipoParadaSelecionado;
  final MapController _mapController = MapController();
  final List<int> _idTiposAbrigos = [
    19,
    1,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    20,
    21,
    22
  ];
  final Map<int, String> _mapIdTipoAbrigo = {
    19: "Ponto Habitual",
    1: "Abrigo Lelé",
    3: "Abrigo Oval",
    4: "Abrigo Reduzido",
    5: "Abrigo Canelete 90",
    6: "Abrigo Cemusa 2001",
    7: "Abrigo Cemusa Foster",
    8: "Abrigo Padrão I",
    9: "Abrigo Grimshaw",
    10: "Abrigo Concretado in loco",
    11: "Abrigo Concreto DER",
    12: "Abrigo Especial Aeroporto",
    13: "Abrigo Metálico ou Brasileiro",
    14: "Abrigo Metrobel",
    15: "Abrigo Padrão II",
    16: "Abrigo Tipo C novo",
    17: "Abrigo Tipo C",
    18: "Abrigo tradicional Niemayer",
    20: "Abrigo atípico",
    21: "Abrigo DNIT",
    22: "Placa de Sinalização"
  };
  // Mapeia cada tipo de abrigo para um asset de imagem correspondente
  final Map<int, String> _mapaImagensAbrigos = {
    19: "assets/images/ponto_habitual.jpg",
    1: "assets/images/abrigo_lele.png",
    2: "assets/images/abrigo_padrao_ii.png",
    3: "assets/images/abrigo_oval.png",
    4: "assets/images/abrigo_reduzido.png",
    5: "assets/images/abrigo_canelete_90.png",
    6: "assets/images/abrigo_cemusa_2001.png",
    7: "assets/images/abrigo_cemusa_foster.png",
    8: "assets/images/abrigo_padrao_i.png",
    9: "assets/images/abrigo_grimshaw.png",
    10: "assets/images/abrigo_concretado.png",
    11: "assets/images/abrigo_concreto_der.png",
    12: "assets/images/abrigo_especial_aeroporto.png",
    13: "assets/images/abrigo_metalico.png",
    14: "assets/images/abrigo_metrobel.png",
    15: "assets/images/abrigo_padrao_ii.png",
    16: "assets/images/abrigo_tipo_c_novo.png",
    17: "assets/images/abrigo_tipo_c.png",
    18: "assets/images/abrigo_tradicional_niemeyer.png",
    20: "assets/images/abrigo_atipico.png",
    21: "assets/images/abrigo_dnit.png",
    22: "assets/images/ponto_sinalizacao.png",
  };

  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();

    if (widget.initialData != null) {
      _addressController.text = widget.initialData?['endereco'] ?? '';
      _linhaEscolares = widget.initialData?['LinhaEscolares'] ?? false;
      _linhaStpc = widget.initialData?['LinhaStpc'] ?? false;
      _pisoTatil = widget.initialData?['PisoTatil'] ?? false;
      _rampa = widget.initialData?['Rampa'] ?? false;
      _patologia = widget.initialData?['Patologia'] ?? false;
      _baia = widget.initialData?['Baia'] ?? false; // Correção adicionada

      _dataVisita =
          DateTime.tryParse(widget.initialData?['DataVisita'] ?? '') ??
              DateTime.now();

      // Criando cópias separadas para evitar referência compartilhada
      _abrigos = (widget.initialData?['abrigos'] as List?)?.map((abrigo) {
            return {
              "idTipoAbrigo": abrigo["idTipoAbrigo"],
              "temPatologia": abrigo["temPatologia"] ?? false,
              "imgBlobPaths": List<String>.from(abrigo["imgBlobPaths"] ?? []),
              "imagensPatologiaPaths":
                  List<String>.from(abrigo["imagensPatologiaPaths"] ?? []),
            };
          }).toList() ??
          [];

      _temAbrigo = _abrigos.isNotEmpty; // Correção na lógica do haAbrigo
    }
  }

  Future<void> _carregarDadosUsuario() async {
    final id = await LoginService.getUsuarioId();
    if (mounted) {
      setState(() {
        _idUsuario = id;
      });
    }
  }

  void _adicionarAbrigo() {
    setState(() {
      _abrigos.add({
        "idTipoAbrigo": null,
        "temPatologia": false,
        "imgBlobPaths": <String>[],
        "imagensPatologiaPaths": <String>[],
      });
    });
  }

  // Função para exibir a janela modal com o GridView de tipos de abrigo
  void _showTipoAbrigoModal(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87, // Cor de fundo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400, // Altura da janela modal
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selecione o tipo de Abrigo",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Número de colunas
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1, // Mantém os quadrados proporcionais
                  ),
                  itemCount: _idTiposAbrigos.length,
                  itemBuilder: (context, i) {
                    int tipoId = _idTiposAbrigos[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _abrigos[index]["idTipoAbrigo"] = tipoId;
                        });
                        Navigator.pop(context); // Fecha a janela após a seleção
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔥 Exibe a imagem do asset correspondente ao abrigo
                            Image.asset(
                              _mapaImagensAbrigos[tipoId] ??
                                  "assets/images/default.png",
                              width: 50, // Ajuste conforme necessário
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _mapIdTipoAbrigo[tipoId] ?? "Desconhecido",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removerAbrigo(int index) {
    setState(() {
      _abrigos.removeAt(index);
    });
  }

  Future<void> _selecionarImagemDaGaleria(List<String> listaDestino) async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        listaDestino.addAll(pickedFiles.map((file) => file.path).toList());
      });
    }
  }

  Future<void> _tirarFotoComCamera(List<String> listaDestino) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        listaDestino.add(pickedFile.path);
      });
    }
  }

  void _removerImagem(int index, List<String> listaDestino, int abrigoIndex) {
    setState(() {
      _abrigos[abrigoIndex]["imagensPatologiaPaths"] =
          List<String>.from(_abrigos[abrigoIndex]["imagensPatologiaPaths"]);
      _abrigos[abrigoIndex]["imagensPatologiaPaths"].removeAt(index);
    });
  }

  /// Método para selecionar a data e hora
  void _selecionarDataHora(BuildContext context) async {
    DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: _dataVisita,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (novaData != null) {
      TimeOfDay? novaHora = await showTimePicker(
        context: context,
        initialTime: _horaVisita,
      );

      if (novaHora != null) {
        setState(() {
          _dataVisita = novaData;
          _horaVisita = novaHora;
        });
      }
    }
  }

  void _salvarParada(BuildContext context) {
    if (!mounted) return;

    final pontoProvider = Provider.of<PontoProvider>(context, listen: false);

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Endereço Vazio! Preencha com o endereço.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final abrigosInvalidos = _abrigos.where((abrigo) =>
    abrigo["idTipoAbrigo"] == null ||
        !_mapIdTipoAbrigo.containsKey(abrigo["idTipoAbrigo"]));

    if (abrigosInvalidos.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Campo obrigatório"),
          content: const Text("Você precisa selecionar o tipo de Parada/Abrigo para cadastrar um ponto de parada."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final ponto = PontoModel()
      ..idUsuario = _idUsuario!
      ..endereco = _addressController.text
      ..latitude = widget.latLng.latitude
      ..longitude = widget.latLng.longitude
      ..linhaEscolares = _linhaEscolares
      ..linhaStpc = _linhaStpc
      ..latitudeInterpolado = widget.latLongInterpolado.latitude
      ..longitudeInterpolado = widget.latLongInterpolado.longitude
      ..dataVisita = _dataVisita.toIso8601String()
      ..pisoTatil = _pisoTatil
      ..rampa = _rampa
      ..patologia = _patologia
      ..baia = _baia
      ..imgBlobPaths = [] // opcional se necessário fora de abrigo
      ..imagensPatologiaPaths = []
      ..abrigos = _abrigos.map((abrigo) {
        return AbrigoModel()
          ..idTipoAbrigo = abrigo["idTipoAbrigo"]
          ..temPatologia = abrigo["temPatologia"]
          ..imgBlobPaths = List<String>.from(abrigo["imgBlobPaths"] ?? [])
          ..imagensPatologiaPaths = List<String>.from(abrigo["imagensPatologiaPaths"] ?? []);
      }).toList();

    if (widget.index != null) {
      pontoProvider.atualizarPonto(widget.index!, ponto);
    } else {
      pontoProvider.adicionarPonto(ponto);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parada salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

//
// // Função auxiliar para formatar JSON no console
//   void printJson(Map<String, dynamic> json) {
//     const JsonEncoder encoder = JsonEncoder.withIndent("  ");
//     print(encoder.convert(json));
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Text(
                      "Formulário da Parada",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildTextField("Endereço", _addressController),


                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12), // Borda arredondada de 12
                  child: SizedBox(
                    height: 300,
                    width: 400,
                    child: FlutterMap(
                      options: MapOptions(
                          initialCenter: widget.latLng,
                          initialZoom: 16.0,
                          interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate
                          )
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.ponto.parada.frontend',
                          tileProvider: _tileProvider,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: widget.latLng,
                              width: 45.0,
                              height: 45.0,
                              child: Transform.translate(
                                offset: const Offset(0, -22),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 45,
                                ),
                              ),
                            ),
                            if (_pontoSelecionado != null)
                              Marker(
                                point: _pontoSelecionado!,
                                width: 45.0,
                                height: 45.0,
                                child: Transform.translate(
                                  offset: const Offset(0, -22),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.greenAccent,
                                    size: 45,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSwitch("Linhas Escolares", _linhaEscolares, (value) {
                  setState(() => _linhaEscolares = value);
                }),
                _buildSwitch("Linhas STPC", _linhaStpc, (value) {
                  setState(() => _linhaStpc = value);
                }),
                _buildSwitch("Baia", _baia, (value) {
                  setState(() => _baia = value);
                }),

                const SizedBox(height: 15),
                const Text(
                  "Acessibilidade",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),

                _buildSwitch("Rampa", _rampa, (value) {
                  setState(() => _rampa = value);
                }),
                _buildSwitch("Piso Tátil", _pisoTatil, (value) {
                  setState(() => _pisoTatil = value);
                }),

                const SizedBox(height: 20),

                _buildDateTile(context),

                const SizedBox(height: 10),

                // _buildSwitch("Possui Abrigo?", _temAbrigo, (value) {
                //   setState(() => _temAbrigo = value);
                // }),
                //
                // if (_temAbrigo) _buildAbrigos(),
                _buildAbrigos(),

                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _salvarParada(context),
                    child: const Text(
                      "Salvar Parada",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

  /// Switch to toggle "Possui Patologia?"
  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      value: value,
      activeColor: Colors.orange,
      onChanged: (val) {
        setState(() {
          onChanged(val);

          // 🔹 Ensure _temPatologia is updated when "Possui Patologia?" is toggled
          if (title == "Possui Patologia?") {
            _temPatologia = val;
          }
        });
      },
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }

  /// Widget para exibir e selecionar a data e hora
  Widget _buildDateTile(BuildContext context) {
    return Card(
      color: Colors.black.withValues(alpha: 0.2), // Fundo translúcido
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: const Text(
          'Data e Hora da Visita',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '${_dataVisita.day.toString().padLeft(2, '0')}/'
          '${_dataVisita.month.toString().padLeft(2, '0')}/'
          '${_dataVisita.year} às '
          '${_horaVisita.hour.toString().padLeft(2, '0')}:'
          '${_horaVisita.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        trailing: const Icon(Icons.calendar_today, color: Colors.orangeAccent),
        onTap: () => _selecionarDataHora(context),
      ),
    );
  }

  Widget _buildAbrigos() {
    return Column(
      children: [
        for (int i = 0; i < _abrigos.length; i++)
          Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white.withValues(alpha: 0.2),
            shadowColor: Colors.grey,
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔻 Dropdown para Tipo de Abrigo
                  const Text(
                    "Tipo da parada/Abrigo",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

// Botão que abre a janela de seleção
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () =>
                        _showTipoAbrigoModal(context, i), // Chama o modal
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          _mapIdTipoAbrigo[_abrigos[i]["idTipoAbrigo"]] ??
                              "Selecione o tipo",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔻 Botões para adicionar imagens
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _selecionarImagemDaGaleria(
                            _abrigos[i]["imgBlobPaths"]),
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text("Galeria",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _tirarFotoComCamera(_abrigos[i]["imgBlobPaths"]),
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text("Câmera",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🔻 Exibição de imagens (CORRIGIDO PARA NÃO DESAPARECER)
                  if (_abrigos[i]["imgBlobPaths"] != null &&
                      _abrigos[i]["imgBlobPaths"].isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _abrigos[i]["imgBlobPaths"].length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.file(
                                  File(_abrigos[i]["imgBlobPaths"][index]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _abrigos[i]["imgBlobPaths"] =
                                          List<String>.from(
                                              _abrigos[i]["imgBlobPaths"]);
                                      _abrigos[i]["imgBlobPaths"]
                                          .removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),

                  //  Switch para indicar se possui patologia
                  SwitchListTile(
                    title: const Text("Possui Patologia?",
                        style: TextStyle(color: Colors.white)),
                    value: _abrigos[i]["temPatologia"] ??
                        false, // 🔹 Usa o valor do abrigo específico
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      setState(() {
                        _abrigos[i]["temPatologia"] = value;
                      });
                    },
                  ),

                  // 🔻 Se o abrigo tiver patologia, exibe opções de imagem (CORRIGIDO)
                  if (_abrigos[i]["temPatologia"] == true) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _selecionarImagemDaGaleria(
                              _abrigos[i]["imagensPatologiaPaths"]),
                          icon: const Icon(Icons.image, color: Colors.white),
                          label: const Text("Galeria",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _tirarFotoComCamera(
                              _abrigos[i]["imagensPatologiaPaths"]),
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text("Câmera",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Exibir imagens da patologia (CORRIGIDO)
                    if (_abrigos[i]["imagensPatologiaPaths"] != null &&
                        _abrigos[i]["imagensPatologiaPaths"].isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              _abrigos[i]["imagensPatologiaPaths"].length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.file(
                                    File(_abrigos[i]["imagensPatologiaPaths"]
                                        [index]),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => _removerImagem(
                                      index,
                                      _abrigos[i]["imagensPatologiaPaths"],
                                      i,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],

                  const SizedBox(height: 10),

                  // 🔻 Botão para remover o abrigo
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerAbrigo(i),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Botão para adicionar abrigo
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _adicionarAbrigo,
            child: const Text(
              "Adicionar Parada/Abrigo",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
