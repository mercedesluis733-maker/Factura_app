import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const FacturaApp());
}

class FacturaApp extends StatelessWidget {
  const FacturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Factura',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FacturaPage(),
    );
  }
}

class FacturaPage extends StatefulWidget {
  const FacturaPage({super.key});

  @override
  State<FacturaPage> createState() => _FacturaPageState();
}

class _FacturaPageState extends State<FacturaPage> {
  final clienteController = TextEditingController();
  final descripcionController = TextEditingController();
  final cantidadController = TextEditingController(text: '1');
  final precioController = TextEditingController();

  double get total {
    final cantidad =
        double.tryParse(cantidadController.text.replaceAll(',', '.')) ?? 0;
    final precio =
        double.tryParse(precioController.text.replaceAll(',', '.')) ?? 0;

    return cantidad * precio;
  }

  @override
  void dispose() {
    clienteController.dispose();
    descripcionController.dispose();
    cantidadController.dispose();
    precioController.dispose();
    super.dispose();
  }

  Future<Uint8List> crearPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Customer: ${clienteController.text}',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 25),
              pw.TableHelper.fromTextArray(
                headers: const [
                  'Description',
                  'Quantity',
                  'Price',
                  'Total',
                ],
                data: [
                  [
                    descripcionController.text,
                    cantidadController.text,
                    '\$${precioController.text}',
                    '\$${total.toStringAsFixed(2)}',
                  ],
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TOTAL: \$${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> compartirFactura() async {
    final bytes = await crearPdf();

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/invoice.pdf');

    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Invoice',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factura'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: clienteController,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: precioController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 25),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: compartirFactura,
                icon: const Icon(Icons.share),
                label: const Text(
                  'Generar y compartir factura',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}