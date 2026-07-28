import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(remote: ref.read(orderRemoteDataSourceProvider));
});

final createOrderUseCaseProvider =
    Provider((ref) => CreateOrderUseCase(ref.read(orderRepositoryProvider)));
