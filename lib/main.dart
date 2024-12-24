import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_data.dart';
import 'expense_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final expenseData = ExpenseData();
  await expenseData.initializeDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (context) => expenseData,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseScreen(),
    );
  }
}
