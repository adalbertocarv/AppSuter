import 'package:flutter/material.dart';
import '../models/bacias_model.dart';
import '../models/ra_model.dart';
import '../services/ra_service.dart';
import '../services/bacias_service.dart';

class RaSeletorWidget extends StatefulWidget {
  final Function(RaModel?) onRaSelecionada;
  final Function(BaciaModel?) onBaciaSelecionada;
  const RaSeletorWidget({
    super.key,
    required this.onRaSelecionada,
    required this.onBaciaSelecionada,
  });
  @override
  State<RaSeletorWidget> createState() => _RaSeletorWidgetState();
}

class _RaSeletorWidgetState extends State<RaSeletorWidget> {
  final List<String> ras = [
    "ÁGUAS CLARAS",
    "BRASÍLIA",
    "BRAZLÂNDIA",
    "CANDANGOLÂNDIA",
    "CEILÂNDIA",
    "CRUZEIRO",
    "GAMA",
    "GUARÁ",
    "ITAPOÃ",
    "JARDIM BOTÂNICO",
    "LAGO NORTE",
    "LAGO SUL",
    "NÚCLEO BANDEIRANTE",
    "PARANOÁ",
    "PARK WAY",
    "PLANALTINA",
    "RECANTO DAS EMAS",
    "RIACHO FUNDO",
    "RIACHO FUNDO II",
    "SAMAMBAIA",
    "SANTA MARIA",
    "SÃO SEBASTIÃO",
    "SCIA",
    "SIA",
    "SOBRADINHO",
    "SOBRADINHO II",
    "SUDOESTE/OCTOGONAL",
    "TAGUATINGA",
    "VARJÃO",
    "VICENTE PIRES"
  ];

  final List<String> bacias = [
    'Sem Bacia',
    'Norte',
    'Sudeste',
    'Sudoeste',
    'Centro-Oeste',
    'Noroeste'
  ];

  String? tipoSelecionado; // 'RA' ou 'Bacia'
  String? itemSelecionado;

  @override
  Widget build(BuildContext context) {
    List<String> listaDropdown = [];
    if (tipoSelecionado == 'RA') {
      listaDropdown = ras;
    } else if (tipoSelecionado == 'Bacia') {
      listaDropdown = bacias;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: tipoSelecionado,
          hint: const Text('Deseja visualizar por...'),
          isExpanded: true,
          items: ['RA', 'Bacia']
              .map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child:
                        Text(tipo == 'RA' ? 'Região Administrativa' : 'Bacia'),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              tipoSelecionado = value;
              itemSelecionado = null;
            });
            //  Limpa os polígonos ao trocar entre RA e Bacia
            widget.onRaSelecionada(null);
            widget.onBaciaSelecionada(null);
          },
        ),
        if (tipoSelecionado != null)
          Expanded(
              child: DropdownButton<String>(
            value: itemSelecionado,
            hint:
                Text('Selecione a ${tipoSelecionado == 'RA' ? 'RA' : 'Bacia'}'),
            isExpanded: true,
            items: listaDropdown
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: (value) async {
              setState(() {
                itemSelecionado = value;
              });
              if (tipoSelecionado == 'RA') {
                final raModel = await RaService.buscarRaPorNome(value!);
                widget.onRaSelecionada(raModel);
                widget.onBaciaSelecionada(null); // limpa bacia se RA for selecionada
              } else {
                final baciaModel = await BaciaService.buscarBaciaPorNome(value!);
                widget.onBaciaSelecionada(baciaModel);
                widget.onRaSelecionada(null); // limpa RA se Bacia for selecionada
              }
            },
          ))
      ],
    );
  }
}
