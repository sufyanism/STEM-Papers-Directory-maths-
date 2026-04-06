import '../../domain/entities/paper.dart';

class PaperModel extends Paper {
  PaperModel({
    required super.title,
    required super.summary,
    required super.author,
    required super.link,
    required super.published,
  });
}