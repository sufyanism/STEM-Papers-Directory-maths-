import 'package:xml/xml.dart';
import '../../domain/entities/paper.dart';
import '../datasources/arxiv_api.dart';

class PaperRepositoryImpl {
  final ArxivApi api;

  PaperRepositoryImpl(this.api);

  Future<List<Paper>> searchPapers(
      String category,
      String query,
      int start,
      ) async {

    final xmlString = await api.fetchPapers(category, query);

    if (xmlString.isEmpty) return [];

    final document = XmlDocument.parse(xmlString);
    final entries = document.findAllElements('entry');

    List<Paper> papers = [];

    for (final entry in entries) {
      final title =
          entry.getElement('title')?.innerText.trim() ?? "";

      final summary =
          entry.getElement('summary')?.innerText.trim() ?? "";

      final id =
          entry.getElement('id')?.innerText.trim() ?? "";

      final authorElement = entry.findElements('author').isNotEmpty
          ? entry.findElements('author').first
          : null;

      final author = authorElement
          ?.getElement('name')
          ?.innerText
          .trim() ??
          "Unknown";

      final published =
          entry.getElement('published')?.innerText.trim() ?? "";

      papers.add(
        Paper(
          title: title,
          summary: summary,
          author: author,
          link: id,
          published: published,
        ),
      );
    }

    return papers;
  }
}