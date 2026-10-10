import '../../../core/database/transaction_column.dart';
import '../domain/transaction_data.dart';

extension TransactionMapper on TransactionData {
  Map<String, Object?> toMap() {
    return {
      TransactionColumn.id: id,
      TransactionColumn.title: title,
      TransactionColumn.amount: value,
      TransactionColumn.type: isIncome
          ? 1
          : 0, // sqflite dont know bool. use 1 for true and 0 for false
      TransactionColumn.date: date.toIso8601String(),
    };
  }
}

TransactionData transactionDataFromMap(Map<String, Object?> map) {
  return TransactionData(
    id: map[TransactionColumn.id] as int,
    title: map[TransactionColumn.title] as String,
    value: map[TransactionColumn.amount] as int,
    isIncome: map[TransactionColumn.type] == 1,
    date: DateTime.parse(map[TransactionColumn.date] as String),
  );
}
