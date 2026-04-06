import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/arxiv_api.dart';
import '../../data/repositories/paper_repository_impl.dart';
import '../../domain/entities/paper.dart';

/// ✅ DEFAULT → MATHEMATICS
final categoryProvider =
StateProvider<String>((ref) => "math.GM");

final searchProvider = StateProvider<String>((ref) => "");

final lastDataProvider = StateProvider<List<Paper>>((ref) => []);
final hasLoadedOnceProvider = StateProvider<bool>((ref) => false);

final paperProvider = FutureProvider<List<Paper>>((ref) async {
  final repo = PaperRepositoryImpl(ArxivApi());
  final category = ref.watch(categoryProvider);
  final query = ref.watch(searchProvider);

  final result = await repo.searchPapers(category, query, 0);

  ref.read(lastDataProvider.notifier).state = result;
  ref.read(hasLoadedOnceProvider.notifier).state = true;

  return result;
});