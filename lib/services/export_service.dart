import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:divelogtest/models/dive_session.dart';

class ExportService {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _fileDateFormat = DateFormat('yyyyMMdd_HHmm');

  Future<void> exportDiveToPdf(DiveSession dive) async {
    final doc = pw.Document();
    
    // Load font if needed, or use standard ones
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(dive),
            pw.SizedBox(height: 20),
            _buildGeneralInfo(dive),
            pw.SizedBox(height: 10),
            _buildConditionsInfo(dive),
            pw.SizedBox(height: 10),
            _buildDiveDetails(dive),
            pw.SizedBox(height: 10),
            _buildWorkInfo(dive),
            pw.SizedBox(height: 20),
            _buildFooter(dive),
          ];
        },
      ),
    );

    final String fileName = 'Dive_${_fileDateFormat.format(dive.horaEntrada)}.pdf';
    
    // Use printing package to share/print
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: fileName,
    );
  }

  pw.Widget _buildHeader(DiveSession dive) {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Bitácora de Buceo', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text(_dateFormat.format(dive.horaEntrada), style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  pw.Widget _buildGeneralInfo(DiveSession dive) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Información General', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _buildRow('Cliente', dive.cliente),
          _buildRow('Operadora', dive.operadoraBuceo),
          _buildRow('Dirección', dive.direccionOperadora),
          _buildRow('Lugar', dive.lugarBuceo),
          _buildRow('Tipo', dive.tipoBuceo),
          _buildRow('Supervisor', dive.supervisorBuceo),
          _buildRow('Buzos', dive.nombreBuzos.join(', ')),
        ],
      ),
    );
  }

  pw.Widget _buildConditionsInfo(DiveSession dive) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Condiciones', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.Row(
            children: [
              pw.Expanded(child: _buildRow('Estado Mar', '${dive.estadoMar} Beaufort')),
              pw.Expanded(child: _buildRow('Visibilidad', '${dive.visibilidad} m')),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildRow('Temp. Aire', '${dive.temperaturaSuperior}°C')),
              pw.Expanded(child: _buildRow('Temp. Agua', '${dive.temperaturaAgua}°C')),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildRow('Corriente', dive.corrienteAgua)),
              pw.Expanded(child: _buildRow('Tipo Agua', dive.tipoAgua)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDiveDetails(DiveSession dive) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Detalles de Inmersión', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.Row(
            children: [
              pw.Expanded(child: _buildRow('Entrada', _dateFormat.format(dive.horaEntrada))),
              pw.Expanded(child: _buildRow('Salida', _dateFormat.format(dive.horaSalida))),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildRow('Prof. Max', '${dive.maximaProfundidad} m')),
              pw.Expanded(child: _buildRow('Intervalo', '${dive.tiempoIntervaloSuperficie} min')),
            ],
          ),
           pw.Row(
            children: [
              pw.Expanded(child: _buildRow('Tiempo Fondo', '${dive.tiempoFondo} min')),
              pw.Expanded(child: _buildRow('Tiempo Total', '${dive.tiempoTotalInmersion} min')),
            ],
          ),
          if (dive.inicioDescompresion != null)
             _buildRow('Inicio Descomp.', _dateFormat.format(dive.inicioDescompresion!)),
          if (dive.descompresionCompleta != null)
             _buildRow('Fin Descomp.', _dateFormat.format(dive.descompresionCompleta!)),
        ],
      ),
    );
  }

  pw.Widget _buildWorkInfo(DiveSession dive) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Trabajo y Seguridad', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _buildRow('Descripción', dive.descripcionTrabajo),
          _buildRow('Descompresión', dive.descompresionUtilizada),
          if (dive.enfermedadLesion != null && dive.enfermedadLesion!.isNotEmpty)
            _buildRow('Enfermedad/Lesión', dive.enfermedadLesion!),
          pw.Row(
            children: [
              pw.Expanded(child: _buildRow('T. Supervisión', '${dive.tiempoSupervisionAcumulado} hrs')),
              pw.Expanded(child: _buildRow('T. Buceo', '${dive.tiempoBuceoAcumulado} hrs')),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(DiveSession dive) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text('Firma Supervisor'),
              ],
            ),
             pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text('Firma Buzo'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text('Generado por Dive Log App', style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Future<void> exportDiveToCsv(DiveSession dive) async {
    final List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      'ID', 'Fecha', 'Cliente', 'Operadora', 'Lugar', 'Profundidad Max (m)', 
      'Tiempo Fondo (min)', 'Tiempo Total (min)', 'Descripción'
    ]);

    // Data
    rows.add([
      dive.id,
      _dateFormat.format(dive.horaEntrada),
      dive.cliente,
      dive.operadoraBuceo,
      dive.lugarBuceo,
      dive.maximaProfundidad,
      dive.tiempoFondo,
      dive.tiempoTotalInmersion,
      dive.descripcionTrabajo,
    ]);

    // Convert to CSV string
    final String csv = const ListToCsvConverter().convert(rows);
    
    // Share
    final String fileName = 'Dive_${_fileDateFormat.format(dive.horaEntrada)}.csv';
    
    // Create text file
    final XFile file = XFile.fromData(
      Uint8List.fromList(csv.codeUnits),
      mimeType: 'text/csv',
      name: fileName,
    );

    await Share.shareXFiles([file], text: 'Reporte de Buceo CSV');
  }

  Future<void> exportDivesListToCsv(List<DiveSession> dives) async {
    final List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      'ID', 'Fecha', 'Cliente', 'Operadora', 'Lugar', 'Profundidad Max (m)', 
      'Tiempo Fondo (min)', 'Tiempo Total (min)', 'Descripción', 'Supervisor'
    ]);

    // Data
    for (var dive in dives) {
      rows.add([
        dive.id,
        _dateFormat.format(dive.horaEntrada),
        dive.cliente,
        dive.operadoraBuceo,
        dive.lugarBuceo,
        dive.maximaProfundidad,
        dive.tiempoFondo,
        dive.tiempoTotalInmersion,
        dive.descripcionTrabajo,
        dive.supervisorBuceo,
      ]);
    }

    // Convert to CSV string
    final String csv = const ListToCsvConverter().convert(rows);
    
    // Share
    final String fileName = 'Reporte_Buceos_${_fileDateFormat.format(DateTime.now())}.csv';
    
    // Create text file
    final XFile file = XFile.fromData(
      Uint8List.fromList(csv.codeUnits),
      mimeType: 'text/csv',
      name: fileName,
    );

    await Share.shareXFiles([file], text: 'Reporte de Lista de Buceos CSV');
  }

  Future<void> exportDivesListToPdf(List<DiveSession> dives) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Reporte de Buceos', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(_dateFormat.format(DateTime.now()), style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headers: ['Fecha', 'Lugar', 'Operadora', 'Prof. (m)', 'T. Fondo (min)', 'T. Total (min)', 'Supervisor'],
              data: dives.map((dive) => [
                _dateFormat.format(dive.horaEntrada),
                dive.lugarBuceo,
                dive.operadoraBuceo,
                dive.maximaProfundidad.toString(),
                dive.tiempoFondo.toString(),
                dive.tiempoTotalInmersion.toString(),
                dive.supervisorBuceo,
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
             pw.Padding(
               padding: const pw.EdgeInsets.only(top: 20),
               child: pw.Text('Total de inmersiones: ${dives.length}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
             ),
          ];
        },
      ),
    );

    final String fileName = 'Reporte_Buceos_${_fileDateFormat.format(DateTime.now())}.pdf';
    
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: fileName,
    );
  }
}
