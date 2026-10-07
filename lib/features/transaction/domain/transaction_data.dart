class TransactionData {
  final int? id;
  final String title;
  final int value;
  final bool isIncome;
  final DateTime date;

  const TransactionData({
    this.id,
    required this.title,
    required this.value,
    required this.isIncome,
    required this.date,
  });

  /// used for logic total saldo
  int get signedValue => isIncome ? value : -value;
}
