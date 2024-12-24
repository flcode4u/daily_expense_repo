import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_data.dart';
import 'pdf_generator.dart';

class ExpenseScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final expenseData = Provider.of<ExpenseData>(context, listen: false);
              await generatePdfReport(expenseData.expenses);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ExpenseData>(
              builder: (context, expenseData, child) {
                return ListView.builder(
                  itemCount: expenseData.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseData.expenses[index];
                    return ListTile(
                      title: Text(expense.name),
                      subtitle: Text('\$${expense.amount.toStringAsFixed(2)} - ${expense.date.toLocal().toString().split(' ')[0]}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: 'Expense Name'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: InputDecoration(hintText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final name = _nameController.text;
                    final amount = double.parse(_amountController.text);
                    if (name.isNotEmpty && amount > 0) {
                      Provider.of<ExpenseData>(context, listen: false).addExpense(name, amount);
                      _nameController.clear();
                      _amountController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
