class TransactionFailure implements Exception {
  const TransactionFailure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() {
    return cause == null
        ? 'Transaction failure: $message'
        : 'Transaction failure: $message (cause : $cause)';
  }
}
