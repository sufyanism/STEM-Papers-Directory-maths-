class Paper {
  final String title;
  final String summary;
  final String author;
  final String link;
  final String published;

  Paper({
    required this.title,
    required this.summary,
    required this.author,
    required this.link,
    required this.published,
  });

  /// ✅ ADD THIS (IMPORTANT)
  factory Paper.fromMap(Map<String, dynamic> map) {
    return Paper(
      title: map["title"] ?? "",
      summary: map["summary"] ?? "",
      author: map["author"] ?? "Unknown",   // fallback
      link: map["link"] ?? "",
      published: map["published"] ?? "",   // fallback
    );
  }

  /// ✅ (OPTIONAL but recommended)
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "summary": summary,
      "author": author,
      "link": link,
      "published": published,
    };
  }

  /// Reading time
  int get readingTime {
    final words = summary.split(" ").length;
    return (words / 200).ceil();
  }

  /// Generate PDF link
  String get pdfLink {
    if (link.contains("/abs/")) {
      return "${link.replaceFirst("/abs/", "/pdf/")}.pdf";
    }
    return link;
  }
}