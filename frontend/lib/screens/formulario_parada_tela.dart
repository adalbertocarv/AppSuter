import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormularioParadaTela extends StatefulWidget {
  final LatLng latLng;
  final LatLng latLongInterpolado;
  final Map<String, dynamic>? initialData;
  final int? index;

  FormularioParadaTela({
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
  bool _pisoTatil = false;
  bool _rampa = false;
  bool _patologia = false;
  bool _temAbrigo = false;
  bool _temPatologia = false;
  int? _idUsuario;
  DateTime _dataVisita = DateTime.now();
  List<Map<String, dynamic>> _abrigos = [];
  List<int> _idTiposAbrigos = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
  ]; // IDs para seleção de abrigo

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _addressController.text =
        widget.initialData?['endereco'] ?? 'Carregando endereço...';

    if (widget.initialData != null) {
      _temAbrigo = widget.initialData?['temAbrigo'] ?? false;
      _temPatologia = widget.initialData?['Patologia'] ?? false;
      _pisoTatil = widget.initialData?['PisoTatil'] ?? false;
      _rampa = widget.initialData?['Rampa'] ?? false;
      _linhaEscolares = widget.initialData?['LinhaEscolares'] ?? false;
      _linhaStpc = widget.initialData?['LinhaStpc'] ?? false;

      if (widget.initialData?['abrigos'] != null) {
        _abrigos =
            List<Map<String, dynamic>>.from(widget.initialData?['abrigos'])
                .map((abrigo) {
          return {
            "idTipoAbrigo": abrigo["idTipoAbrigo"],
            "temPatologia": abrigo["temPatologia"] ?? false,
            "imgBlobPaths": List<String>.from(
                abrigo["imgBlobPaths"] ?? []), // ✅ Conversão correta
            "imagensPatologiaPaths": List<String>.from(
                abrigo["imagensPatologiaPaths"] ?? []), // ✅ Conversão correta
          };
        }).toList();
      }
    }
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _idUsuario = prefs.getInt('idUsuario');
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
        listaDestino.addAll(pickedFiles
            .map((file) => file.path)
            .toList()); // ✅ Conversão correta
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

  void _removerImagem(int index, List<String> listaDestino) {
    setState(() {
      listaDestino.removeAt(index);
    });
  }

  void _selecionarDataVisita(BuildContext context) async {
    DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: _dataVisita,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (novaData != null) {
      setState(() {
        _dataVisita = novaData;
      });
    }
  }

  void _salvarParada(BuildContext context) {
    if (!mounted) return; // Evita erro se o widget já foi desmontado

    final pointProvider = Provider.of<PointProvider>(context, listen: false);

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

    if (widget.index != null) {
      pointProvider.updatePoint(
        widget.index!,
        idUsuario: _idUsuario!,
        endereco: _addressController.text,
        latitude: widget.latLng.latitude,
        longitude: widget.latLng.longitude,
        linhaEscolares: _linhaEscolares,
        linhaStpc: _linhaStpc,
        idTipoAbrigo: _abrigos.isNotEmpty ? _abrigos[0]["idTipoAbrigo"] : null,
        latitudeInterpolado: widget.latLongInterpolado.latitude,
        longitudeInterpolado: widget.latLongInterpolado.longitude,
        dataVisita: _dataVisita.toIso8601String(),
        pisoTatil: _pisoTatil,
        rampa: _rampa,
        patologia: _patologia,
        imgBlobPaths: _abrigos.isNotEmpty ? _abrigos[0]["imgBlobPaths"] : [],
        imagensPatologiaPaths:
        _abrigos.isNotEmpty ? _abrigos[0]["imagensPatologiaPaths"] : [],
        abrigos: _abrigos,
      );
    } else {
      pointProvider.addPoint(
        idUsuario: _idUsuario!,
        endereco: _addressController.text,
        latitude: widget.latLng.latitude,
        longitude: widget.latLng.longitude,
        linhaEscolares: _linhaEscolares,
        linhaStpc: _linhaStpc,
        idTipoAbrigo: _abrigos.isNotEmpty ? _abrigos[0]["idTipoAbrigo"] : null,
        latitudeInterpolado: widget.latLongInterpolado.latitude,
        longitudeInterpolado: widget.latLongInterpolado.longitude,
        dataVisita: _dataVisita.toIso8601String(),
        pisoTatil: _pisoTatil,
        rampa: _rampa,
        patologia: _patologia,
        imgBlobPaths: _abrigos.isNotEmpty ? _abrigos[0]["imgBlobPaths"] : [],
        imagensPatologiaPaths:
        _abrigos.isNotEmpty ? _abrigos[0]["imagensPatologiaPaths"] : [],
        abrigos: _abrigos,
      );
    }

    // Exibir o `SnackBar` ANTES de chamar `Navigator.pop()`
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parada salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Aguarda o `SnackBar` antes de fechar a tela
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
          color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Formulário da Parada',
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coordenadas Selecionadas: ${widget.latLng.latitude}, ${widget.latLng.longitude}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // CAMPO ENDEREÇO
              TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Endereço')
              ),

              const SizedBox(height: 10),

              // SWITCH PARA LINHAS ESCOLARES
              SwitchListTile(
                title: const Text('Linhas Escolares'),
                value: _linhaEscolares,
                onChanged: (value) {
                  setState(() {
                    _linhaEscolares = value;
                  });
                },
              ),

              // SWITCH PARA LINHAS STPC
              SwitchListTile(
                title: const Text('Linhas STPC'),
                value: _linhaStpc,
                onChanged: (value) {
                  setState(() {
                    _linhaStpc = value;
                  });
                },
              ),

              // SWITCH PARA RAMPA
              SwitchListTile(
                title: const Text('Rampa'),
                value: _rampa,
                onChanged: (value) {
                  setState(() {
                    _rampa = value;
                  });
                },
              ),

              // SWITCH PARA PISO TÁTIL
              SwitchListTile(
                title: const Text('Piso Tátil'),
                value: _pisoTatil,
                onChanged: (value) {
                  setState(() {
                    _pisoTatil = value;
                  });
                },
              ),

              // SELEÇÃO DE DATA DA VISITA
              ListTile(
                title: Text(
                  'Data da Visita: ${_dataVisita.day}/${_dataVisita.month}/${_dataVisita.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                onTap: () async {
                  DateTime? novaData = await showDatePicker(
                    context: context,
                    initialDate: _dataVisita,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (novaData != null) {
                    setState(() {
                      _dataVisita = novaData;
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              // SWITCH PARA INDICAR SE TEM ABRIGO
              SwitchListTile(
                title: const Text('Possui Abrigo?'),
                value: _temAbrigo,
                onChanged: (value) {
                  setState(() {
                    _temAbrigo = value;
                  });
                },
              ),

              if (_temAbrigo) ...[
                for (int i = 0; i < _abrigos.length; i++) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.grey[50],
                    shadowColor: Colors.grey,
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: _abrigos[i]["idTipoAbrigo"],
                            items: _idTiposAbrigos.map((id) {
                              return DropdownMenuItem<int>(
                                  value: id, child: Text('Abrigo ID $id'));
                            }).toList(),
                            onChanged: (value) => setState(
                                () => _abrigos[i]["idTipoAbrigo"] = value),
                            decoration: const InputDecoration(
                                labelText: 'Tipo de Abrigo'),
                          ),

                          // SELECIONAR IMAGENS DO ABRIGO
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _selecionarImagemDaGaleria(
                                    _abrigos[i]["imgBlobPaths"]),
                                icon: const Icon(Icons.image),
                                label: const Text('Galeria'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _tirarFotoComCamera(
                                    _abrigos[i]["imgBlobPaths"]),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Câmera'),
                              ),
                            ],
                          ),

                          // EXIBIR IMAGENS DO ABRIGO
                          if (_abrigos[i]["imgBlobPaths"].isNotEmpty)
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
                                          File(_abrigos[i]["imgBlobPaths"]
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
                                          onPressed: () => _removerImagem(index,
                                              _abrigos[i]["imgBlobPaths"]),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                          // SWITCH PARA PATOLOGIA
                          SwitchListTile(
                            title: const Text('Possui Patologia?'),
                            value: _abrigos[i]["temPatologia"],
                            onChanged: (value) => setState(
                                () => _abrigos[i]["temPatologia"] = value),
                          ),

                          // SELECIONAR IMAGENS DA PATOLOGIA
                          if (_abrigos[i]["temPatologia"]) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _selecionarImagemDaGaleria(
                                      _abrigos[i]["imagensPatologiaPaths"]),
                                  icon: const Icon(Icons.image),
                                  label: const Text('Galeria'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _tirarFotoComCamera(
                                      _abrigos[i]["imagensPatologiaPaths"]),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Câmera'),
                                ),
                              ],
                            ),

                            // EXIBIR IMAGENS DA PATOLOGIA
                            if (_abrigos[i]["imagensPatologiaPaths"].isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _abrigos[i]
                                          ["imagensPatologiaPaths"]
                                      .length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Image.file(
                                            File(_abrigos[i]
                                                    ["imagensPatologiaPaths"]
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
                                                _abrigos[i]
                                                    ["imagensPatologiaPaths"]),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],

                          // BOTÃO PARA REMOVER O ABRIGO
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
                ],
                Center(
                  child: ElevatedButton(
                    onPressed: _adicionarAbrigo,
                    child: const Text('Adicionar Abrigo'),
                  ),
                ),
              ],

              const SizedBox(height: 10),
              Text(
                'Ponto interpolado com rede de vias: ${widget.latLongInterpolado}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () => _salvarParada(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Salvar Parada'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}