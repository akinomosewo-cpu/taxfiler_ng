import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../entities/tax_entities.dart';

/// Builds a ready-to-submit PDF tax return summary from a [TaxAssessment].
class PdfGenerator {
  static Future<void> shareAssessment(TaxAssessment assessment, {String? taxpayerName}) async {
    final bytes = await _buildDocument(assessment, taxpayerName: taxpayerName);
    await Printing.sharePdf(bytes: bytes, filename: 'taxfiler_ng_${assessment.year.label}_return.pdf');
  }

  static Future<void> printAssessment(TaxAssessment assessment, {String? taxpayerName}) async {
    final bytes = await _buildDocument(assessment, taxpayerName: taxpayerName);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<List<int>> _buildDocument(TaxAssessment a, {String? taxpayerName}) async {
    final fmt = NumberFormat('#,##0.00', 'en_NG');
    final doc = pw.Document();

    pw.Widget row(String label, String value, {bool bold = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
              pw.Text(value, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            ],
          ),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'TaxFiler NG — Self-Assessment Tax Return'),
          if (taxpayerName != null) pw.Text('Taxpayer: $taxpayerName'),
          pw.Text('Tax Year: ${a.year.label}'),
          pw.Text('Prepared: ${DateFormat('d MMMM yyyy').format(a.calculatedAt)}'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Income Summary'),
          row('Gross Income', '₦${fmt.format(a.grossIncome)}'),
          row('Less: Allowable Business Expenses', '-₦${fmt.format(a.totalExpenses)}'),
          row('Net Income', '₦${fmt.format(a.netIncome)}', bold: true),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Deductions & Reliefs'),
          row('Pension Contribution', '-₦${fmt.format(a.pensionDeduction)}'),
          row('National Housing Fund (NHF)', '-₦${fmt.format(a.nhfDeduction)}'),
          row('National Health Insurance (NHI)', '-₦${fmt.format(a.nhiDeduction)}'),
          row('Consolidated Relief Allowance', '-₦${fmt.format(a.consolidatedRelief)}'),
          pw.Divider(),
          row('Total Deductions', '-₦${fmt.format(a.totalDeductions)}', bold: true),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Tax Computation'),
          row('Taxable Income', '₦${fmt.format(a.taxableIncome)}', bold: true),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Band', 'Rate', 'Taxable Amount', 'Tax'],
            data: a.bandBreakdown
                .map((b) => [
                      b.label,
                      '${(b.rate * 100).toStringAsFixed(0)}%',
                      '₦${fmt.format(b.taxable)}',
                      '₦${fmt.format(b.tax)}',
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 12),
          row('Total Tax Liability', '₦${fmt.format(a.taxLiability)}', bold: true),
          row('Effective Tax Rate', '${a.effectiveTaxRate.toStringAsFixed(2)}%'),
          pw.SizedBox(height: 24),
          pw.Text(
            a.isNilReturn
                ? 'This is a NIL return — no tax is owed for this period based on the figures above.'
                : 'File this return and remit the tax liability above on or before 31 March to avoid a '
                    '₦100,000 late filing penalty plus ₦50,000 for every additional month.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
