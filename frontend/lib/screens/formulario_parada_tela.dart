import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';

class FormularioParadaTela extends StatefulWidget {
  final LatLng latLng;
  final LatLng latLongInterpolado;
  final Map<String, dynamic>? initialData;
  final int? index;

  const FormularioParadaTela({super.key,
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
  int? _idUsuario;
  DateTime _dataVisita = DateTime.now();
  TimeOfDay _horaVisita = TimeOfDay.now();
  List<Map<String, dynamic>> _abrigos = [];
  final List<int> _idTiposAbrigos = [
    19,
    1,
    2,
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
    20
  ];
  final Map<int, String> _mapIdTipoAbrigo = {
    19: "Ponto Habitual",
    1: "Abrigo Lelé",
    2: "Tipo Padrão II",
    3: "Abrigo Oval",
    4: "Abrigo Reduzido",
    5: "Abrigo Canelete 90",
    6: "Abrigo Cemusa 2001",
    7: "Abrigo Cemusa Foster",
    8: "Tipo Padrão I",
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
    20: "Abrigo atípico"
  };

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
    setState(() {
      _idUsuario = 1;
    });
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
    if (!mounted) return; // Evita erro se o widget já foi desmontado

    final pointProvider = Provider.of<PointProvider>(context, listen: false);

    // Validação dos campos obrigatórios
    if (_idUsuario == null || _addressController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: usuário ou endereço inválido!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Construção do objeto parada
    final parada = {
      "idUsuario": _idUsuario!,
      "endereco": _addressController.text,
      "latitude": widget.latLng.latitude,
      "longitude": widget.latLng.longitude,
      "LinhaEscolares": _linhaEscolares,
      "LinhaStpc": _linhaStpc,
      "idTipoAbrigo": _abrigos.isNotEmpty ? _abrigos[0]["idTipoAbrigo"] : null,
      "latitudeInterpolado": widget.latLongInterpolado.latitude,
      "longitudeInterpolado": widget.latLongInterpolado.longitude,
      "DataVisita": _dataVisita.toIso8601String(),
      "Baia": _baia ?? false, // Garante que nunca será null
      "PisoTatil": _pisoTatil,
      "Rampa": _rampa,
      "Patologia": _patologia,
      "abrigos": _abrigos,
    };

    // Atualiza ou adiciona a parada no provider
    if (widget.index != null) {
      pointProvider.atualizarPontos(
        widget.index!,
        idUsuario: parada["idUsuario"],
        endereco: parada["endereco"],
        latitude: parada["latitude"],
        longitude: parada["longitude"],
        linhaEscolares: parada["LinhaEscolares"],
        linhaStpc: parada["LinhaStpc"],
        idTipoAbrigo: parada["idTipoAbrigo"],
        latitudeInterpolado: parada["latitudeInterpolado"],
        longitudeInterpolado: parada["longitudeInterpolado"],
        dataVisita: parada["DataVisita"],
        baia: parada["Baia"],
        pisoTatil: parada["PisoTatil"],
        rampa: parada["Rampa"],
        patologia: parada["Patologia"],
        abrigos: parada["abrigos"],
      );
    } else {
      pointProvider.adicionarPontos(
        idUsuario: parada["idUsuario"],
        endereco: parada["endereco"],
        latitude: parada["latitude"],
        longitude: parada["longitude"],
        linhaEscolares: parada["LinhaEscolares"],
        linhaStpc: parada["LinhaStpc"],
        idTipoAbrigo: parada["idTipoAbrigo"],
        latitudeInterpolado: parada["latitudeInterpolado"],
        longitudeInterpolado: parada["longitudeInterpolado"],
        dataVisita: parada["DataVisita"],
        baia: parada["Baia"],
        pisoTatil: parada["PisoTatil"],
        rampa: parada["Rampa"],
        patologia: parada["Patologia"],
        abrigos: parada["abrigos"],
      );
    }

    // Exibe o `SnackBar` ANTES de fechar a tela
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parada salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Aguarda o `SnackBar` antes de fechar a tela
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

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
                const Center(
                  child: Text(
                    "Formulário da Parada",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField("Endereço", _addressController),

                const SizedBox(height: 10),

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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ));
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
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    "Tipo da parada",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<int>(
                    value: _abrigos[i]["idTipoAbrigo"],
                    dropdownColor: Colors.black87,
                    items: _idTiposAbrigos.map((id) {
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text(
                          _mapIdTipoAbrigo[id] ?? 'Desconhecido',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _abrigos[i]["idTipoAbrigo"] = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔻 Botões para adicionar imagens
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _selecionarImagemDaGaleria(_abrigos[i]["imgBlobPaths"]),
                        icon: const Icon(Icons.image, color: Colors.white),
                        label: const Text("Galeria", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _tirarFotoComCamera(_abrigos[i]["imgBlobPaths"]),
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text("Câmera", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🔻 Exibição de imagens (CORRIGIDO PARA NÃO DESAPARECER)
                  if (_abrigos[i]["imgBlobPaths"] != null && _abrigos[i]["imgBlobPaths"].isNotEmpty)
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
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _abrigos[i]["imgBlobPaths"] =
                                      List<String>.from(_abrigos[i]["imgBlobPaths"]);
                                      _abrigos[i]["imgBlobPaths"].removeAt(index);
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
                    title: const Text("Possui Patologia?", style: TextStyle(color: Colors.white)),
                    value: _abrigos[i]["temPatologia"] ?? false, // 🔹 Usa o valor do abrigo específico
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
                          onPressed: () => _selecionarImagemDaGaleria(_abrigos[i]["imagensPatologiaPaths"]),
                          icon: const Icon(Icons.image, color: Colors.white),
                          label: const Text("Galeria", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _tirarFotoComCamera(_abrigos[i]["imagensPatologiaPaths"]),
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text("Câmera", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Exibir imagens da patologia (CORRIGIDO)
                    if (_abrigos[i]["imagensPatologiaPaths"] != null && _abrigos[i]["imagensPatologiaPaths"].isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _abrigos[i]["imagensPatologiaPaths"].length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.file(
                                    File(_abrigos[i]["imagensPatologiaPaths"][index]),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _adicionarAbrigo,
            child: const Text(
              "Adicionar Parada",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
