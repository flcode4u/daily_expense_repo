import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'expense_data.dart';
import 'package:intl/intl.dart';

Future<void> generatePdfReport(List<Expense> expenses, DateTime startDate, DateTime endDate) async {
  final pdf = pw.Document();
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Daily Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('From: ${dateFormat.format(startDate)}', style: pw.TextStyle(fontSize: 16)),
            pw.Text('To: ${dateFormat.format(endDate)}', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Name', 'Amount (Rs)', 'Date'],
                ...expenses.map((expense) =>
                    [expense.name, 'Rs ${expense.amount.toStringAsFixed(2)}', dateFormat.format(expense.date)]),
              ],
            ),
          ],
        );
      },
    ),
  );

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/expense_report.pdf');
  await file.writeAsBytes(await pdf.save());
}
