import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

class SuggestionApi {
  final Dio dio = Dio();
  final Map<String, List<String>> _cache = {};

  Future<List<String>> fetchSuggestions(
      String query,
      String category,
      ) async {
    final cleanQuery = query.trim();

    /// ✅ Avoid unnecessary API calls
    if (cleanQuery.length < 3) return [];

    final key = "$category-$cleanQuery";

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final response = await dio.get(
        "https://export.arxiv.org/api/query",
        queryParameters: {
          "search_query": "(cat:$category) AND all:$cleanQuery",
          "start": 0,
          "max_results": 8,
        },
        options: Options(responseType: ResponseType.plain),
      );

      final document = XmlDocument.parse(response.data.toString());
      final entries = document.findAllElements('entry');

      final results = entries.map((e) {
        return e
            .getElement('title')
            ?.innerText
            .replaceAll('\n', ' ')
            .trim() ??
            "";
      }).toList();

      _cache[key] = results;
      return results;
    } catch (_) {
      return [];
    }
  }
}