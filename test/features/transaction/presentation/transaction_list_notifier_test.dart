import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_management/features/transaction/data/transaction_repository_impl.dart';
import 'package:money_management/features/transaction/domain/transaction_data.dart';
import 'package:money_management/features/transaction/domain/transaction_failure.dart';
import 'package:money_management/features/transaction/domain/transaction_repository.dart';
import 'package:money_management/features/transaction/presentation/transaction_list_notifier.dart';

class FakeTransactionRepository implements TransactionRepository {
  /// fake database: list on memory
  final List<TransactionData> transactions = [];

  /// if true, throw error on all method
  /// used for testing failed state
  bool shouldFail = false;

  @override
  Future<TransactionData> add(TransactionData t) async {
    if (shouldFail) throw const TransactionFailure(message: 'fake add error');
    final maxId = transactions.fold(
      0,
      (max, t) => (t.id ?? 0) > max ? t.id! : max,
    );
    final saved = t.copyWith(id: maxId + 1);

    transactions.add(saved);
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    if (shouldFail) {
      throw const TransactionFailure(message: 'fake delete error');
    }
    transactions.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<TransactionData>> getAll() async {
    if (shouldFail) {
      throw const TransactionFailure(message: 'fake getAll error');
    }

    return List.of(transactions);
  }

  @override
  Future<void> update(TransactionData t) async {
    if (shouldFail) {
      throw const TransactionFailure(message: 'fake update error');
    }
    final index = transactions.indexWhere((d) => d.id == t.id);

    if (index != -1) {
      transactions[index] = t;
    }
  }
}

void main() {
  late FakeTransactionRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = FakeTransactionRepository();
    container = ProviderContainer.test(
      overrides: [transactionRepositoryProvider.overrideWithValue(fakeRepo)],
      retry: (_, _) => null,
    );
  });

  group('TransactionListNotifier', () {
    final oldTransaction = TransactionData(
      id: 1,
      title: 'Salary',
      value: 100,
      isIncome: true,
      date: DateTime(2026, 10, 10),
    );

    final newTransaction = TransactionData(
      title: 'Food',
      value: 10,
      isIncome: false,
      date: DateTime(2026, 10, 10),
    );
    test('build loads transactions from repository', () async {
      // arr
      fakeRepo.transactions.add(oldTransaction);

      // act
      final result = await container.read(transactionListProvider.future);

      // Assert
      expect(result, [oldTransaction]);
    });

    test('add puts the saved transaction at the top of the list', () async {
      // arr
      fakeRepo.transactions.add(oldTransaction);
      await container.read(transactionListProvider.future); // wait build() done

      await container
          .read(transactionListProvider.notifier)
          .add(newTransaction);

      // assert
      final state = container.read(transactionListProvider).value;
      expect(state, [newTransaction.copyWith(id: 2), oldTransaction]);
    });

    test('add throws and keeps state when repository fails', () async {
      // arr
      fakeRepo.transactions.add(oldTransaction);
      await container.read(transactionListProvider.future); // wait build() done

      fakeRepo.shouldFail = true; // change to true after build() done

      await expectLater(
        container.read(transactionListProvider.notifier).add(newTransaction),
        throwsA(isA<TransactionFailure>()),
      );

      expect(container.read(transactionListProvider).value, [oldTransaction]);
    });

    test('delete removes only the matching transaction', () async {
      // arr
      final sampleTransaction = TransactionData(
        id: 2,
        title: 'Sample',
        value: 1,
        isIncome: false,
        date: DateTime(2026, 10, 10),
      );

      fakeRepo.transactions.addAll([oldTransaction, sampleTransaction]);
      await container.read(transactionListProvider.future); // wait build() done

      // act
      await container.read(transactionListProvider.notifier).delete(2);

      // assert
      final state = container.read(transactionListProvider).value;
      expect(state, [oldTransaction]);
    });

    test('delete throws and keeps state when repository fails', () async {
      // arr
      final sampleTransaction = TransactionData(
        id: 2,
        title: 'Sample',
        value: 1,
        isIncome: false,
        date: DateTime(2026, 10, 10),
      );

      fakeRepo.transactions.addAll([oldTransaction, sampleTransaction]);
      await container.read(transactionListProvider.future); // wait build() done

      fakeRepo.shouldFail = true;

      // act
      await expectLater(
        container.read(transactionListProvider.notifier).delete(1),
        throwsA(isA<TransactionFailure>()),
      );

      // assert
      expect(container.read(transactionListProvider).value, [
        oldTransaction,
        sampleTransaction,
      ]);
    });

    test('failed to build() return error', () async {
      fakeRepo.shouldFail = true;

      await expectLater(
        container.read(transactionListProvider.future),
        throwsA(isA<TransactionFailure>()),
      );

      expect(container.read(transactionListProvider).hasError, isTrue);
    });
  });
}
