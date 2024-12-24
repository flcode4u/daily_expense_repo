import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class Expense {
  final int? id;
  final String name;
  final double amount;
  final DateTime date;

  Expense({this.id, required this.name, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  Expense copyWith({
    int? id,
    String? name,
    double? amount,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}

class ExpenseData extends ChangeNotifier {
  List<Expense> _expenses = [];
  late Database _database;

  List<Expense> get expenses => _expenses;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'expenses.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, name TEXT, amount REAL, date TEXT)',
        );
      },
      version: 1,
    );
    loadExpenses();
  }

  Future<void> addExpense(String name, double amount, DateTime date) async {
    final newExpense = Expense(name: name, amount: amount, date: date);
    final id = await _database.insert(
      'expenses',
      newExpense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _expenses.add(newExpense.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _database.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    await _database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    final List<Map<String, dynamic>> maps = await _database.query('expenses');
    _expenses = List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        name: maps[i]['name'],
        amount: maps[i]['amount'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
    notifyListeners();
  }

  double getTotalExpensesByMonth(int month, int year) {
    double total = 0;
    for (var expense in _expenses) {
      if (expense.date.month == month && expense.date.year == year) {
        total += expense.amount;
      }
    }
    return total;
  }
}
