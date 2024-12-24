import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_data.dart';
import 'pdf_generator.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: 'Rs.', decimalDigits: 2);

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate)
      setState(() {
        _startDate = picked;
      });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate)
      setState(() {
        _endDate = picked;
      });
  }

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
              final filteredExpenses = expenseData.expenses.where((expense) {
                return expense.date.isAfter(_startDate) && expense.date.isBefore(_endDate.add(Duration(days: 1)));
              }).toList();
              await generatePdfReport(filteredExpenses, _startDate, _endDate);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF report generated and saved to application documents directory')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _selectStartDate(context);
                  },
                  child: Text("Start Date: ${_dateFormat.format(_startDate)}"),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _selectEndDate(context);
                  },
                  child: Text("End Date: ${_dateFormat.format(_endDate)}"),
                ),
              ),
            ],
          ),
          Expanded(
            child: Consumer<ExpenseData>(
              builder: (context, expenseData, child) {
                final filteredExpenses = expenseData.expenses.where((expense) {
                  return expense.date.isAfter(_startDate.add(Duration(days: -1))) && expense.date.isBefore(_endDate.add(Duration(days: 1)));
                }).toList();

                final totalExpenses = filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);

                return Column(
                  children: [
                    Text(
                      'Total Expenses: ${_currencyFormat.format(totalExpenses)}',
                      style: TextStyle(fontSize: 20),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return ListTile(
                            title: Text(expense.name),
                            subtitle: Text('${_currencyFormat.format(expense.amount)} - ${_dateFormat.format(expense.date)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _nameController.text = expense.name;
                                    _amountController.text = expense.amount.toString();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Edit Expense'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: _nameController,
                                              decoration: InputDecoration(hintText: 'Expense Name'),
                                            ),
                                            TextField(
                                              controller: _amountController,
                                              decoration: InputDecoration(hintText: 'Amount'),
                                              keyboardType: TextInputType.number,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _selectStartDate(context);
                                              },
                                              child: Text("Select Date"),
                                            ),
                                            Text(_dateFormat.format(_startDate)),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final updatedExpense = Expense(
                                                id: expense.id,
                                                name: _nameController.text,
                                                amount: double.parse(_amountController.text),
                                                date: _startDate,
                                              );
                                              Provider.of<ExpenseData>(context, listen: false).updateExpense(updatedExpense);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Save'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense.id!);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        _selectStartDate(context);
                      },
                      child: Text("Select Date"),
                    ),
                    Text(_dateFormat.format(_startDate)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final name = _nameController.text;
                    final amount = double.parse(_amountController.text);
                    if (name.isNotEmpty && amount > 0) {
                      Provider.of<ExpenseData>(context, listen: false).addExpense(name, amount, _startDate);
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
