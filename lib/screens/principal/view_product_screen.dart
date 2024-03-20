import 'package:flutter/material.dart';
import 'package:hjsystems/api/models/model_estoque.dart';

class ViewProductScreen extends StatefulWidget {
  ModelEstoque product;
  ViewProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ViewProductScreen> createState() => _ViewProductScreenState();
}

class _ViewProductScreenState extends State<ViewProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                spacing: 10.0, // Espaçamento horizontal entre os cartões
                runSpacing: 10.0, // Espaçamento vertical entre os cartões
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
                  buildInfoItemWithoutSpace('Geral: ', widget.product.geral!),
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
      width: MediaQuery.of(context).size.width / 2.5, // Definindo a largura do cartão
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
