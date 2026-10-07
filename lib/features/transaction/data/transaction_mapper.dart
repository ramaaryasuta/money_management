import '../domain/transaction_data.dart';

extension TransactionMapper on TransactionData {
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'type': isIncome
          ? 1
          : 0, // sqflite dont know bool. use 1 for true and 0 for false
      'date': date.toIso8601String(),
    };
  }
}

TransactionData transactionDataFromMap(Map<String, Object?> map) {
  return TransactionData(
    id: map['id'] as int,
    title: map['title'] as String,
    value: map['value'] as int,
    isIncome: map['type'] == 1,
    date: DateTime.parse(map['date'] as String),
  );
}
