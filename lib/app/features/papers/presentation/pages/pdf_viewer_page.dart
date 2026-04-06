import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/paper.dart';

class PdfViewerPage extends StatefulWidget {
  final Paper paper;

  const PdfViewerPage(this.paper, {super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late Future<FileInfo> cachedPdf;
  final PdfViewerController _controller = PdfViewerController();

  int currentPage = 1;
  int totalPages = 0;

  bool isDrawing = false;
  bool showTools = false;

  List<Offset?> points = [];

  String get noteKey => widget.paper.pdfLink;

  @override
  void initState() {
    super.initState();
    cachedPdf = DefaultCacheManager().downloadFile(widget.paper.pdfLink);
  }

  void _searchText() async {
    String? query = await _inputDialog("Search");
    if (query != null && query.isNotEmpty) {
      _controller.searchText(query);
    }
  }

  void _jumpToPage() async {
    String? page = await _inputDialog("Go to Page");
    if (page != null) {
      _controller.jumpToPage(int.tryParse(page) ?? 1);
    }
  }

  Future<String?> _inputDialog(String title) {
    String text = "";
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(onChanged: (v) => text = v),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, text),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _addNote() async {
    String? text = await _inputDialog("Enter Note");
    if (text == null || text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> stored = prefs.getStringList(noteKey) ?? [];

    stored.add(jsonEncode({"page": currentPage, "content": text}));

    await prefs.setStringList(noteKey, stored);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Note saved")));
  }

  Future<void> _viewNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stored = prefs.getStringList(noteKey) ?? [];

    List<Map<String, dynamic>> notes =
    stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    showModalBottomSheet(
      context: context,
      builder: (_) => notes.isEmpty
          ? const Center(child: Text("No notes yet"))
          : ListView(
        children: notes.map((n) {
          return ListTile(
            title: Text("Page ${n['page']}"),
            subtitle: Text(n['content']),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                notes.remove(n);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setStringList(
                    noteKey,
                    notes.map((e) => jsonEncode(e)).toList());

                Navigator.pop(context);
                _viewNotes();
              },
            ),
            onTap: () {
              _controller.jumpToPage(n['page']);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _clearDraw() => setState(() => points.clear());

  Future<void> _savePdf() async {
    final pdf = pw.Document();
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/edited.pdf");

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Text("Annotated PDF Saved"),
        ),
      ),
    );

    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Saved at ${file.path}")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final iconSize = width * 0.06;
    final textSize = width * 0.03;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          widget.paper.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: width * 0.04,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.search, size: iconSize),
              onPressed: _searchText),
          IconButton(
              icon: Icon(Icons.save, size: iconSize),
              onPressed: _savePdf),
        ],
      ),

      body: FutureBuilder<FileInfo>(
        future: cachedPdf,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SfPdfViewer.file(
                snapshot.data!.file,
                controller: _controller,
                onDocumentLoaded: (d) {
                  totalPages = d.document.pages.count;
                },
                onPageChanged: (d) {
                  setState(() => currentPage = d.newPageNumber);
                },
              ),

              if (isDrawing)
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() => points.add(details.localPosition));
                  },
                  onPanEnd: (_) => points.add(null),
                  child: CustomPaint(
                    painter: DrawPainter(points, theme),
                    size: Size.infinite,
                  ),
                ),

              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03, vertical: width * 0.015),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$currentPage / $totalPages",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: textSize,
                      ),
                    ),
                  ),
                ),
              ),

              if (showTools)
                Positioned(
                  bottom: width * 0.18,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        _tool(Icons.highlight, "Highlight", () {}),
                        _tool(Icons.brush, "Draw", () {
                          setState(() => isDrawing = true);
                        }),
                        _tool(Icons.cleaning_services, "Erase", _clearDraw),
                        _tool(Icons.note, "Note", _addNote),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      bottomNavigationBar: Container(
        height: width * 0.16,
        margin: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _bottom(Icons.grid_view, "Pages", _jumpToPage, iconSize, textSize, theme),
            _bottom(Icons.edit, "Markup", () {
              setState(() => isDrawing = !isDrawing);
            }, iconSize, textSize, theme),
            _center(width, theme),
            _bottom(Icons.notes, "Notes", _viewNotes, iconSize, textSize, theme),
            _bottom(Icons.search, "Search", _searchText, iconSize, textSize, theme),
          ],
        ),
      ),
    );
  }

  Widget _tool(IconData i, String t, VoidCallback f) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: f,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: width * 0.06),
          Text(t, style: TextStyle(fontSize: width * 0.028))
        ],
      ),
    );
  }

  Widget _bottom(
      IconData i, String t, VoidCallback f,
      double iconSize, double textSize, ThemeData theme) {
    return GestureDetector(
      onTap: f,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(i, size: iconSize),
          Text(t, style: TextStyle(fontSize: textSize)),
        ],
      ),
    );
  }

  Widget _center(double width, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() => showTools = !showTools);
      },
      child: Container(
        padding: EdgeInsets.all(width * 0.035),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "A",
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
          ),
        ),
      ),
    );
  }
}

/// DRAW PAINTER
class DrawPainter extends CustomPainter {
  final List<Offset?> points;
  final ThemeData theme;

  DrawPainter(this.points, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}