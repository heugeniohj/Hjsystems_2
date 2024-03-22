import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hjsystems/api/models/model_estoque.dart';
import 'package:hjsystems/api/models/model_grupos.dart';
import 'package:hjsystems/api/models/model_marcas.dart';
import 'package:hjsystems/api/models/model_unidade_empresarial.dart';
import 'package:hjsystems/screens/components/my_custom_text.dart';
import 'package:hjsystems/screens/principal/principal_viewmodel.dart';
import 'package:hjsystems/screens/principal/view_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/response/api_response.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({Key? key}) : super(key: key);

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

Future<ModelUnidadeEmpresarial> getUnidadeEmpresarial() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String? unidade = sp.getString("unidade");
  ModelUnidadeEmpresarial unidadeSelecionada =
      ModelUnidadeEmpresarial.fromJson(jsonDecode(unidade!));
  return unidadeSelecionada;
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  PrincipalViewModel viewModel = PrincipalViewModel();
  ModelUnidadeEmpresarial? unidadeEmpresarial;
  late bool loadingData = true;

  String _searchValue = '';

  List<ModelGrupos> listGrupos = [
    ModelGrupos(grpoId: "000640010000000009", grpoNome: "ATIVO IMOBILIZADO"),
    ModelGrupos(grpoId: "000640010000000002", grpoNome: "BFGOODRICH"),
    ModelGrupos(grpoId: "000640010000000007", grpoNome: "BRINDE PROMOCIONAL"),
    ModelGrupos(grpoId: "000640010000000008", grpoNome: "LUBRIFICANTES"),
    ModelGrupos(grpoId: "000640010000000001", grpoNome: "MICHELIN"),
    ModelGrupos(grpoId: "000640010000000003", grpoNome: "OUTROS"),
    ModelGrupos(grpoId: "000640010000000006", grpoNome: "PECAS"),
    ModelGrupos(grpoId: "000640010000006232", grpoNome: "PNEUS MOTO"),
    ModelGrupos(grpoId: "000640010000000005", grpoNome: "SERVICOS"),
  ];

  ModelGrupos? grupoSelected;

  List<ModelMarcas> listMarcas = [
    ModelMarcas(marcId: "000640010000000002", marcNome: "BFG"),
    ModelMarcas(marcId: "000640010000006233", marcNome: "BOSCH"),
    ModelMarcas(marcId: "000640010000006232", marcNome: "CONTINENTAL"),
    ModelMarcas(marcId: "000640010000006234", marcNome: "DUNLOP"),
    ModelMarcas(marcId: "000640010000000006", marcNome: "GERAL"),
    ModelMarcas(marcId: "000640010000000005", marcNome: "GRIFFE"),
    ModelMarcas(marcId: "000640010000006235", marcNome: "GT RADIAL"),
    ModelMarcas(marcId: "000640010000000001", marcNome: "MICHELIN"),
    ModelMarcas(marcId: "000640010000000003", marcNome: "OUTROS"),
  ];
  ModelMarcas? marcaSelected;

  @override
  void initState() {
    super.initState();
    getUserdata();
  }

  getUserdata() async {
    loadingData = true;
    await getUnidadeEmpresarial().then((value) {
      setState(() {
        unidadeEmpresarial = value;
        viewModel.getEstoqueFilianList(unidadeEmpresarial!.emprId!, "", "");
        loadingData = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(""),
      ),
      body: ChangeNotifierProvider<PrincipalViewModel>(
        create: (BuildContext context) => viewModel,
        child: Consumer<PrincipalViewModel>(
          builder: (context, viewModel, _) {
            switch (viewModel.estoqueResponse.status) {
              case Status.LOADING:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Aguarde, carregando base de dados..."),
                      )
                    ],
                  ),
                );
              case Status.ERROR:
                return const Text("erro");
              case Status.COMPLETED:
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: buildCategoriesView(viewModel.estoqueResponse.data),
                );
              default:
                return const Text("erro");
            }
          },
        ),
      ),
      endDrawer: buildEndDrawer(),
    );
  }

  Drawer buildEndDrawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text('Filtrar por'),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 15.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<ModelGrupos>(
                  elevation: 16,
                  hint: Text("Grupo"),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
                  isDense: true,
                  value: grupoSelected,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  onChanged: (ModelGrupos? value) {
                    setState(() {
                      grupoSelected = value!;
                    });
                  },
                  items: listGrupos.map<DropdownMenuItem<ModelGrupos>>(
                    (ModelGrupos value) {
                      return DropdownMenuItem<ModelGrupos>(
                        value: value,
                        child: Text(value.grpoNome!),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 15.0),
                child: DropdownButton<ModelMarcas>(
                  elevation: 16,
                  hint: Text("Marca"),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
                  isDense: true,
                  value: marcaSelected,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  onChanged: (ModelMarcas? value) {
                    setState(() {
                      marcaSelected = value!;
                    });
                  },
                  items: listMarcas.map<DropdownMenuItem<ModelMarcas>>(
                    (ModelMarcas value) {
                      return DropdownMenuItem<ModelMarcas>(
                        value: value,
                        child: Text(value.marcNome!),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        grupoSelected = null;
                        marcaSelected = null;
                        viewModel.getEstoqueFilianList(
                          unidadeEmpresarial!.emprId!,
                          "",
                          "",
                        );
                      });
                    },
                    child: const Text("Limpar filtro"),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.black,
                      ),
                    ),
                    onPressed: () {
                      viewModel.getEstoqueFilianList(
                        unidadeEmpresarial!.emprId!,
                        grupoSelected?.grpoId,
                        marcaSelected?.marcId,
                      );
                    },
                    child: const Text(
                      "Aplicar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  buildCategoriesView(List<ModelEstoque>? data) {
    List<ModelEstoque> _filteredProducts = data!.where((product) {
      return product.nome!.toLowerCase().contains(_searchValue.toLowerCase()) ||
          product.codigo!.toLowerCase().contains(_searchValue.toLowerCase());
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Filtrar por nome ou código',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _searchValue = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            child: const Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SizedBox(width: 19),
                      Text("G01"),
                    SizedBox(width: 19),
                      Text("G02"),
                        SizedBox(width: 19),
                      Text("G03"),
                    SizedBox(width: 19),
                      Text("G04"),
                      SizedBox(width: 19),
                      Text("G08"),
                       SizedBox(width: 19),
                      Text("GO"),
                        SizedBox(width: 19),
                      Text("G05"),
                       SizedBox(width: 19),
                      Text("G11"),
                        SizedBox(width: 19),
                        Text("G06"),
                        SizedBox(width: 19),
                        Text("G07"),
                        SizedBox(width: 19),
                        Text("G09"),
                        SizedBox(width: 19),
                        Text("G10"),
                       SizedBox(width: 19),
                        Text("DF"),
                       SizedBox(width: 20),
                        Text("Geral",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),),
                       SizedBox(width: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        _filteredProducts.isEmpty
            ? const SliverFillRemaining(
                child: Center(
                  child: Text("Nenhum produto encontrado."),
                ),
              )
            : buildProductsList(_filteredProducts),
      ],
    );
  }
  
  SliverList buildProductsList(List<ModelEstoque> filteredProducts) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final backgroundColor = 
          index % 2 == 0 ? Color.fromARGB(255, 249, 248, 248) : Color(0xfef7ff);
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrincipalProductViewScreen(
                    product: filteredProducts[index],
                  ),
                ),
              );
            },
            child: Container(
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 20),
                        buildColumnText("", filteredProducts[index].g01!),
                        SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].g02!),
                      SizedBox(width: 40),
                        buildColumnText("", filteredProducts[index].g03!),
                      SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].g04!),
                        SizedBox(width: 40),
                        buildColumnText("", filteredProducts[index].g08!),
                        SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].gO!),
                        SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].g11!),
                        SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].g05!),
                        SizedBox(width: 40),
                        buildColumnText("", filteredProducts[index].g06!),
                         SizedBox(width: 40),
                        buildColumnText("", filteredProducts[index].g07!),
                         SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].g09!),
                         SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].g10!),
                        SizedBox(width: 35),
                        buildColumnText("", filteredProducts[index].dF!),
                        SizedBox(width: 35),
                        buildColumnText(
                          "",
                          filteredProducts[index].geral!,
                        ),
                        SizedBox(width: 30),
                      ],
                    ),
                    Text(
                      "Código: ${filteredProducts[index].codigo!}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Nome: ${filteredProducts[index].nome!}"),
                    const Divider(),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: filteredProducts.length,
      ),
    );
  }

  Column buildColumnText(String header, String value) {
    return Column(
      children: [
        Text(
          header,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}

class PrincipalProductViewScreen extends StatefulWidget {
  final ModelEstoque product;

  const PrincipalProductViewScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _PrincipalProductViewScreenState createState() =>
      _PrincipalProductViewScreenState();
}

class _PrincipalProductViewScreenState
    extends State<PrincipalProductViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.nome!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoItem('Código: ', widget.product.codigo!),
              buildInfoItem('Nome: ', widget.product.nome!),
              buildInfoItem('Referência: ', widget.product.referencia!),
              const Divider(),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  buildInfoItemWithoutSpace('G01: ', widget.product.g01!),
                  buildInfoItemWithoutSpace('G02: ', widget.product.g02!),
                  buildInfoItemWithoutSpace('G03: ', widget.product.g03!),
                  buildInfoItemWithoutSpace('G04: ', widget.product.g04!),
                  buildInfoItemWithoutSpace('G08: ', widget.product.g08!),
                  buildInfoItemWithoutSpace('GO: ', widget.product.gO!),
                  buildInfoItemWithoutSpace('G11: ', widget.product.g11!),
                  buildInfoItemWithoutSpace('G05: ', widget.product.g05!),
                  buildInfoItemWithoutSpace('G06: ', widget.product.g06!),
                  buildInfoItemWithoutSpace('G07: ', widget.product.g07!),
                  buildInfoItemWithoutSpace('G09: ', widget.product.g09!),
                  buildInfoItemWithoutSpace('G10: ', widget.product.g10!),
                  buildInfoItemWithoutSpace('DF: ', widget.product.dF!),
                  buildInfoItemWithoutSpace('Geral: ', widget.product.geral!,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoItemWithoutSpace(String label, String value) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget buildInfoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 20),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
