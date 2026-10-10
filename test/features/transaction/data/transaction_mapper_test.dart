import 'package:flutter_test/flutter_test.dart';
import 'package:money_management/features/transaction/data/transaction_mapper.dart';
import 'package:money_management/features/transaction/domain/transaction_data.dart';

void main() {
  group('TransactionMapper', () {
    final incomeTransaction = TransactionData(
      id: 1,
      title: 'Coffe',
      value: 100,
      isIncome: true,
      date: DateTime(2026, 10, 10),
    );

    final expenseTransaction = incomeTransaction.copyWith(isIncome: false);

    test('toMap income uses database column names and formats', () {
      final map = incomeTransaction.toMap();

      expect(map, {
        'id': 1,
        'title': 'Coffe',
        'amount': 100,
        'type': 1,
        'date': '2026-10-10T00:00:00.000',
      });
    });

    test('toMap expense uses database column names and formats', () {
      final map = expenseTransaction.toMap();

      expect(map, {
        'id': 1,
        'title': 'Coffe',
        'amount': 100,
        'type': 0,
        'date': '2026-10-10T00:00:00.000',
      });
    });

    test('fromMap(toMap()) for income return an equal object', () {
      final result = transactionDataFromMap(incomeTransaction.toMap());

      expect(result, incomeTransaction);
    });

    test('fromMap(toMap()) for expense return an equal object', () {
      final result = transactionDataFromMap(expenseTransaction.toMap());

      expect(result, expenseTransaction);
    });

    test('fromMap reads a database row for income', () {
      final result = transactionDataFromMap({
        'id': 1,
        'title': 'Coffe',
        'amount': 100,
        'type': 1,
        'date': '2026-10-10T00:00:00.000',
      });

      expect(result, incomeTransaction);
    });

    test('fromMap reads a database row for expense', () {
      final result = transactionDataFromMap({
        'id': 1,
        'title': 'Coffe',
        'amount': 100,
        'type': 0,
        'date': '2026-10-10T00:00:00.000',
      });

      expect(result, expenseTransaction);
    });
  });
}
