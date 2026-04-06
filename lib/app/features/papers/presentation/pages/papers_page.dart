import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import '../../data/datasources/arxiv_api.dart';
import '../../domain/entities/paper.dart';
import '../../../../core/utils/saved_paper_service.dart';
import 'paper_detail_page.dart';

class PapersPage extends StatefulWidget {
  final String title;
  final String category;

  const PapersPage({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  State<PapersPage> createState() => _PapersPageState();
}

class _PapersPageState extends State<PapersPage> {
  final ArxivApi api = ArxivApi();

  List<Paper> papers = [];
  bool isLoading = true;
  String error = "";

  Set<String> savedPapers = {};

  @override
  void initState() {
    super.initState();
    loadSaved();
    loadPapers();
  }

  Future<void> loadSaved() async {
    final data = await SavedPapersService.getSavedPapers();
    setState(() {
      savedPapers = data.map((e) => e["link"] as String).toSet();
    });
  }

  String fixCategory(String code) {
    if (code.startsWith("bio.")) {
      return code.replaceFirst("bio.", "q-bio.");
    }
    return code;
  }

  Future<void> loadPapers() async {
    try {
      final fixedCategory = fixCategory(widget.category);
      final raw = await api.fetchPapers(fixedCategory, "");

      final document = XmlDocument.parse(raw);
      final entries = document.findAllElements("entry").toList();

      if (entries.isEmpty) {
        setState(() {
          error = "No papers found";
          isLoading = false;
        });
        return;
      }

      final parsed = entries.map((e) {
        final authors = e
            .findAllElements("author")
            .map((a) => a.getElement("name")?.innerText ?? "")
            .where((name) => name.isNotEmpty)
            .join(", ");

        String paperLink = "";

        for (var link in e.findElements("link")) {
          final rel = link.getAttribute("rel");
          final href = link.getAttribute("href") ?? "";

          if (rel == "alternate") {
            paperLink = href;
          }
        }

        return Paper(
          title: (e.getElement("title")?.innerText ?? "").trim(),
          summary: (e.getElement("summary")?.innerText ?? "").trim(),
          author: authors,
          published: e.getElement("published")?.innerText ?? "",
          link: paperLink,
        );
      }).toList();

      setState(() {
        papers = parsed;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04;
    final titleSize = width * 0.045;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: titleSize),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.iconTheme?.color,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : papers.isEmpty
          ? const Center(child: Text("No papers found"))
          : ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: papers.length,
        itemBuilder: (_, i) {
          return _paperCard(
              papers[i], width, padding, theme, isDark);
        },
      ),
    );
  }

  /// ================= CARD =================
  Widget _paperCard(
      Paper paper,
      double width,
      double padding,
      ThemeData theme,
      bool isDark,
      ) {
    final isSaved = savedPapers.contains(paper.link);

    final titleSize = width * 0.04;
    final authorSize = width * 0.032;
    final summarySize = width * 0.035;
    final dateSize = width * 0.03;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaperDetailPage(paper),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: padding),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Text(
              paper.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: titleSize,
              ),
            ),

            SizedBox(height: padding * 0.4),

            /// AUTHOR
            Text(
              paper.author.isEmpty ? "Unknown authors" : paper.author,
              style: TextStyle(
                fontSize: authorSize,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),

            SizedBox(height: padding * 0.6),

            /// SUMMARY
            Text(
              paper.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: summarySize,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                height: 1.4,
              ),
            ),

            SizedBox(height: padding * 0.6),

            /// DATE + SAVE
            Row(
              children: [
                Expanded(
                  child: Text(
                    paper.published,
                    style: TextStyle(
                      fontSize: dateSize,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),

                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: width * 0.06,
                  ),
                  onPressed: () async {
                    final newSaved = !isSaved;

                    setState(() {
                      newSaved
                          ? savedPapers.add(paper.link)
                          : savedPapers.remove(paper.link);
                    });

                    if (newSaved) {
                      await SavedPapersService.savePaper({
                        "title": paper.title,
                        "summary": paper.summary,
                        "author": paper.author,
                        "link": paper.link,
                        "published": paper.published,
                      });
                    } else {
                      await SavedPapersService.removePaper(paper.link);
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}