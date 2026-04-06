import 'package:dio/dio.dart';

class ArxivApi {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// ✅ Cache to reduce API calls
  final Map<String, String> _cache = {};

  /// ✅ Track last API call time (for rate limiting)
  DateTime? _lastCallTime;

  /// ✅ Minimum delay between calls (arXiv safe limit)
  final int _minDelaySeconds = 3;

  Future<String> fetchPapers(String category, String query) async {
    final cleanQuery = query.trim();

    /// ✅ Build query
    final searchQuery = cleanQuery.isEmpty
        ? "cat:$category"
        : "(cat:$category) AND all:$cleanQuery";

    final cacheKey = "$category-$searchQuery";

    /// ✅ 1. RETURN FROM CACHE (FAST + NO API HIT)
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    /// ✅ 2. RATE LIMIT CONTROL (MOST IMPORTANT)
    await _applyRateLimit();

    try {
      final response = await dio.get(
        "https://export.arxiv.org/api/query",
        queryParameters: {
          "search_query": searchQuery,
          "start": 0,
          "max_results": 20,
          "sortBy": "submittedDate",
          "sortOrder": "descending",
        },
        options: Options(responseType: ResponseType.plain),
      );

      /// ✅ Update last call time AFTER request
      _lastCallTime = DateTime.now();

      if (response.statusCode == 200) {
        final data = response.data.toString();

        /// ✅ Save in cache
        _cache[cacheKey] = data;

        return data;
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      /// 🔥 HANDLE 429 (AUTO RETRY)
      if (e.response?.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 4));
        return fetchPapers(category, query);
      }

      /// 🔥 HANDLE TIMEOUTS
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection timeout");
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Server slow");
      }

      throw Exception("Network error: ${e.message}");
    }
  }

  /// ✅ Rate limiting logic
  Future<void> _applyRateLimit() async {
    if (_lastCallTime == null) return;

    final diff = DateTime.now().difference(_lastCallTime!);

    if (diff.inSeconds < _minDelaySeconds) {
      final waitTime = _minDelaySeconds - diff.inSeconds;
      await Future.delayed(Duration(seconds: waitTime));
    }
  }
}