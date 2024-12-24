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

  Future<void> addExpense(String name, double amount) async {
    final newExpense = Expense(name: name, amount: amount, date: DateTime.now());
    await _database.insert(
      'expenses',
      newExpense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _expenses.add(newExpense);
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
}
