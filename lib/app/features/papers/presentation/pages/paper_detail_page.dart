import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/paper.dart';
import 'pdf_viewer_page.dart';
import '../../../../core/utils/reading_history_service.dart';

class PaperDetailPage extends StatefulWidget {
  final Paper paper;

  const PaperDetailPage(this.paper, {super.key});

  @override
  State<PaperDetailPage> createState() => _PaperDetailPageState();
}

class _PaperDetailPageState extends State<PaperDetailPage> {

  final Color orange = const Color(0xffFF5A3C);

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    try {
      await ReadingHistoryService.addPaper({
        "title": widget.paper.title,
        "summary": widget.paper.summary,
        "author": widget.paper.author,
        "link": widget.paper.link,
        "published": widget.paper.published,
      });
    } catch (e) {
      debugPrint("History save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final paper = widget.paper;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;

    final padding = width * 0.045;
    final titleSize = width * 0.05;
    final subTitleSize = width * 0.035;
    final bodySize = width * 0.038;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Paper Detail",
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: width * 0.045,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, size: width * 0.06),
            onPressed: () => Share.share(paper.link),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 📄 MAIN CARD
            Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black45
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "CS.AI • ${paper.published}",
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: subTitleSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const Text(
                        "Open Access",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: padding * 0.6),

                  /// TITLE
                  Text(
                    paper.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: padding * 0.4),

                  /// AUTHOR
                  Text(
                    paper.author.isEmpty ? "Unknown Author" : paper.author,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                      fontSize: subTitleSize,
                    ),
                  ),

                  SizedBox(height: padding),

                  /// ABSTRACT TITLE
                  Text(
                    "Abstract",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: subTitleSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: padding * 0.5),

                  /// ABSTRACT
                  Text(
                    paper.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontSize: bodySize,
                    ),
                  ),

                  SizedBox(height: padding * 1.2),

                  /// ACTION TITLE
                  Text(
                    "Quick Actions",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: subTitleSize + 1,
                    ),
                  ),

                  SizedBox(height: padding * 0.6),

                  /// 🔥 BUTTONS (EXACT LIKE DESIGN)
                  Row(
                    children: [

                      /// 🔴 READ PDF
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                vertical: width * 0.035),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.picture_as_pdf,
                              size: width * 0.045,
                              color: Colors.white),
                          label: Text(
                            "Read PDF",
                            style: TextStyle(
                              fontSize: width * 0.034,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfViewerPage(paper),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(width: padding * 0.5),

                      /// ⚪ ARXIV BUTTON
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.cardColor,
                            side: BorderSide(color: orange, width: 1.5),
                            padding: EdgeInsets.symmetric(
                                vertical: width * 0.035),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.open_in_new,
                              size: width * 0.045,
                              color: orange),
                          label: Text(
                            "View on arXiv",
                            style: TextStyle(
                              fontSize: width * 0.034,
                              color: orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Share.share(paper.link);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}