import 'package:bbnij/feature/finance/data/invoice_pdf_service.dart';
import 'package:bbnij/feature/finance/model/invoice_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates a PDF from invoice detail data', () async {
    final invoice = InvoiceDetailModel.fromJson({
      'data': {
        'id': '01M7PXDRYAF3DFZHTQB7NPJ2PN',
        'number': 'INV-2026-000001',
        'purpose_label': 'Wholesale order',
        'total': {
          'amount': '150.00',
          'currency': 'BDT',
          'formatted': '৳150.00',
        },
        'issued_at': '2026-11-18T14:47:25+06:00',
        'is_paid': true,
        'payment_status': 'Paid',
        'items': [
          {
            'description': 'Wholesale supply',
            'quantity': 2,
            'rate': '৳75.00',
            'amount': '৳150.00',
          },
        ],
      },
    });

    final bytes = await InvoicePdfService.generate(invoice);

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(InvoicePdfService.fileName(invoice), 'Invoice_INV-2026-000001.pdf');
  });
}
