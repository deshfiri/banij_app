import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/invoice_detail_model.dart';

class InvoicePdfService {
  static const _accent = PdfColor.fromInt(0xFFFF6900);

  static String fileName(InvoiceDetailModel invoice) {
    final identifier = (invoice.number ?? invoice.id ?? 'invoice').replaceAll(
      RegExp(r'[^A-Za-z0-9._-]+'),
      '_',
    );
    return 'Invoice_$identifier.pdf';
  }

  static Future<Uint8List> generate(
    InvoiceDetailModel invoice, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansBengali-Regular.ttf',
    );
    final font = pw.Font.ttf(fontData);
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font,
        italic: font,
        boldItalic: font,
      ),
    );
    final information = <(String, String)>[
      ('Invoice number', invoice.displayNumber),
      if (invoice.displayCustomer != '—') ('Customer', invoice.displayCustomer),
      if (invoice.displayPurpose != '—') ('Purpose', invoice.displayPurpose),
      ('Issued date', invoice.issuedDateLabel),
      if (invoice.dueDateLabel != '—') ('Due date', invoice.dueDateLabel),
      ('Payment status', invoice.displayStatus),
      if (invoice.displayPaymentReference != '—')
        ('Payment reference', invoice.displayPaymentReference),
      if (invoice.paidDateLabel != '—') ('Paid date', invoice.paidDateLabel),
    ];

    document.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${invoice.displayNumber}  |  ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: _accent,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.displayNumber,
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    invoice.displayStatus.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'TOTAL AMOUNT',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            invoice.displayTotal,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _accent,
            ),
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Invoice information'),
          pw.SizedBox(height: 6),
          ...information.map(
            (row) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 7),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    row.$1,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Text(
                      row.$2,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (invoice.items.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _sectionTitle('Invoice items'),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: const ['Description', 'Qty', 'Rate', 'Amount'],
              data: invoice.items
                  .map(
                    (item) => [
                      item.description ?? 'Invoice item',
                      item.quantity ?? '—',
                      item.rate ?? '—',
                      item.amount ?? '—',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: _accent),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.all(7),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
            ),
          ],
        ],
      ),
    );
    return document.save();
  }

  static Future<File> saveToDevice(InvoiceDetailModel invoice) async {
    final bytes = await generate(invoice);
    final name = fileName(invoice);
    final downloads = await getDownloadsDirectory();

    if (downloads != null) {
      try {
        return await _writeFile(downloads, name, bytes);
      } on FileSystemException {
        final appDocuments = await getApplicationDocumentsDirectory();
        if (appDocuments.path == downloads.path) rethrow;
        return _writeFile(appDocuments, name, bytes);
      }
    }

    return _writeFile(await getApplicationDocumentsDirectory(), name, bytes);
  }

  static Future<File> _writeFile(
    Directory directory,
    String name,
    Uint8List bytes,
  ) async {
    await directory.create(recursive: true);
    return File('${directory.path}/$name').writeAsBytes(bytes, flush: true);
  }

  static pw.Widget _sectionTitle(String title) => pw.Text(
    title,
    style: pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: _accent,
    ),
  );
}
