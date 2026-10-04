class TransactionData {
  final int? id;
  final String title;
  final int value;
  final bool isIncome;
  final DateTime date;

  TransactionData({
    this.id,
    required this.title,
    required this.value,
    required this.isIncome,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'value': value,
    'type': isIncome ? 1 : 0,
    'date': date.toIso8601String(),
  };

  factory TransactionData.fromMap(Map<String, dynamic> map) {
    return TransactionData(
      id: map['id'] as int,
      title: map['title'] as String,
      value: map['value'] as int,
      isIncome: map['type'] == 1,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
