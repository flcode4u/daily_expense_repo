import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'expense_data.dart';

Future<void> generatePdfReport(List<Expense> expenses) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Daily Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Name', 'Amount', 'Date'],
                ...expenses.map((expense) =>
                    [expense.name, expense.amount.toString(), expense.date.toIso8601String()]),
              ],
            ),
          ],
        );
      },
    ),
  );

  final output = await getExternalStorageDirectory();
  final file = File('${output!.path}/expense_report.pdf');
  await file.writeAsBytes(await pdf.save());
}
