import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../data/invoice_pdf_service.dart';
import '../model/invoice_detail_model.dart';

class InvoicePdfPreviewScreen extends StatelessWidget {
  final InvoiceDetailModel invoice;

  const InvoicePdfPreviewScreen({super.key, required this.invoice});

  static Future<void> open(
    BuildContext context, {
    required InvoiceDetailModel invoice,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePdfPreviewScreen(invoice: invoice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Invoice Preview',
              subtitle: invoice.displayNumber,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: PdfPreview(
                  build: (format) =>
                      InvoicePdfService.generate(invoice, format: format),
                  pdfFileName: InvoicePdfService.fileName(invoice),
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  allowPrinting: true,
                  allowSharing: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
