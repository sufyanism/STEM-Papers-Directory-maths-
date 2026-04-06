import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholars_horizon/app/features/papers/presentation/providers/paper_provider.dart';
import '../../data/datasources/suggestion_api.dart';

final suggestionProvider =
FutureProvider<List<String>>((ref) async {
  final query = ref.watch(searchProvider);
  final category = ref.watch(categoryProvider);

  final api = SuggestionApi();
  return api.fetchSuggestions(query, category);
});