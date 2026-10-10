import 'package:flutter_test/flutter_test.dart';
import 'package:money_management/features/transaction/domain/transaction_data.dart';

void main() {
  group('TransactionData equality', () {
    final date = DateTime(2026, 10, 1);
    test('equal objects have the same hashCode', () {
      final a = TransactionData(
        title: 'Coffe',
        value: 100,
        isIncome: false,
        date: date,
      );
      final b = TransactionData(
        title: 'Coffe',
        value: 100,
        isIncome: false,
        date: date,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('objects with different fields are not equal', () {
      final a = TransactionData(
        title: 'Coffe',
        value: 100,
        isIncome: false,
        date: date,
      );
      final b = TransactionData(
        title: 'Coffe',
        value: 400,
        isIncome: false,
        date: date,
      );

      expect(a, isNot(b));
    });
  });

  group('TransactionData.signedValue', () {
    final date = DateTime(2026, 10, 1);

    test('returns positive value for income', () {
      // Arrange : prepare data
      final transaction = TransactionData(
        title: 'Test income',
        value: 20000,
        isIncome: true,
        date: date,
      );

      // Act : testing code
      final result = transaction.signedValue;

      // Assert : check result
      expect(result, 20000);
    });

    test('returns negative value for expense', () {
      // Arr
      final transaction = TransactionData(
        title: 'Test expense',
        value: 1500,
        isIncome: false,
        date: date,
      );

      // Act
      final result = transaction.signedValue;

      // Assert
      expect(result, -1500);
    });
  });

  group('TransactionData.copyWith', () {
    final date = DateTime(2026, 10, 1);
    final original = TransactionData(
      title: 'Lunch',
      value: 25000,
      isIncome: false,
      date: date,
    );

    test('replaces all fields when all are given', () {
      // Act
      final result = original.copyWith(
        id: 5,
        title: 'Coffe',
        value: 120,
        isIncome: true,
        date: DateTime(2026, 8, 8),
      );

      // Assert
      expect(
        result,
        TransactionData(
          id: 5,
          title: 'Coffe',
          value: 120,
          isIncome: true,
          date: DateTime(2026, 8, 8),
        ),
      );

      expect(original.id, isNull);
    });

    test('returns an equal object when no field is given', () {
      // Act
      final result = original.copyWith();

      // Assert
      expect(
        result,
        TransactionData(
          title: 'Lunch',
          value: 25000,
          isIncome: false,
          date: date,
        ),
      );
    });

    test('replaces id and keeps other fields', () {
      // Act
      final result = original.copyWith(id: 5);

      // Assert
      expect(
        result,
        TransactionData(
          id: 5,
          title: 'Lunch',
          value: 25000,
          isIncome: false,
          date: date,
        ),
      );
    });
  });
}
