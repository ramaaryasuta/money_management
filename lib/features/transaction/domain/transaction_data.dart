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

  TransactionData copyWith({
    int? id,
    String? title,
    int? value,
    bool? isIncome,
    DateTime? date,
  }) {
    return TransactionData(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      isIncome: isIncome ?? this.isIncome,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionData &&
        other.id == id &&
        other.title == title &&
        other.value == value &&
        other.isIncome == isIncome &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(id, title, value, isIncome, date);

  @override
  String toString() =>
      'TransactionData(id: $id, title: $title, value: $value, isIncome: $isIncome, date: $date)';
}
