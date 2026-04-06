import 'package:flutter/material.dart';
import '../../../../core/utils/saved_paper_service.dart';
import '../../domain/entities/paper.dart';
import 'paper_detail_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<Map<String, dynamic>> saved = [];
  int selectedTab = 0;
  String searchQuery = "";

  /// ✅ NEW: SORT TYPE
  String sortType = "latest";

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final data = await SavedPapersService.getSavedPapers();

    setState(() {
      saved = data.map((e) {
        final map = Map<String, dynamic>.from(e);
        map["type"] ??= "all";
        return map;
      }).toList();
    });
  }

  /// ✅ FILTER + SEARCH + SORT
  List<Map<String, dynamic>> get filteredList {
    List<Map<String, dynamic>> list = saved;

    /// TAB FILTER
    if (selectedTab == 1) {
      list = list.where((e) => e["type"] == "collection").toList();
    } else if (selectedTab == 2) {
      list = list.where((e) => e["type"] == "archived").toList();
    }

    /// SEARCH FILTER
    if (searchQuery.isNotEmpty) {
      list = list.where((e) {
        final title = (e["title"] ?? "").toLowerCase();
        final author = (e["author"] ?? "").toLowerCase();

        return title.contains(searchQuery.toLowerCase()) ||
            author.contains(searchQuery.toLowerCase());
      }).toList();
    }

    /// ✅ SORTING LOGIC
    if (sortType == "latest") {
      list.sort((a, b) =>
          (b["published"] ?? "").compareTo(a["published"] ?? ""));
    } else if (sortType == "oldest") {
      list.sort((a, b) =>
          (a["published"] ?? "").compareTo(b["published"] ?? ""));
    } else if (sortType == "title") {
      list.sort((a, b) =>
          (a["title"] ?? "").compareTo(b["title"] ?? ""));
    }

    return list;
  }

  int _countForTab(int index) {
    if (index == 0) return saved.length;
    if (index == 1) {
      return saved.where((e) => e["type"] == "collection").length;
    }
    return saved.where((e) => e["type"] == "archived").length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04;

    final list = filteredList;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(width, padding, theme, isDark),

            Expanded(
              child: list.isEmpty
                  ? _emptyState(width, isDark)
                  : RefreshIndicator(
                onRefresh: _loadSaved,
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: padding),
                  itemCount: list.length,
                  itemBuilder: (_, i) =>
                      _card(list[i], width, padding, theme, isDark),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _header(double width, double padding, ThemeData theme, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding * 0.8, padding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE + SEARCH + SORT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Saved Papers",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: width * 0.055,
                ),
              ),
              Row(
                children: [

                  /// SEARCH
                  IconButton(
                    icon: Icon(Icons.search, size: width * 0.06),
                    onPressed: () async {
                      final result = await showSearch(
                        context: context,
                        delegate: PaperSearchDelegate(saved),
                      );

                      if (result != null) {
                        setState(() => searchQuery = result);
                      }
                    },
                  ),

                  SizedBox(width: padding),

                  /// ✅ SORT BUTTON
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort, size: width * 0.06),
                    onSelected: (value) {
                      setState(() => sortType = value);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "latest", child: Text("Latest")),
                      PopupMenuItem(value: "oldest", child: Text("Oldest")),
                      PopupMenuItem(value: "title", child: Text("Title")),
                    ],
                  ),
                ],
              )
            ],
          ),

          SizedBox(height: padding),

          /// TABS
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _tab("All", 0, width, isDark),
                _tab("Collections", 1, width, isDark),
                _tab("Archived", 2, width, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= EMPTY =================
  Widget _emptyState(double width, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border,
              size: width * 0.15,
              color: isDark ? Colors.grey[500] : Colors.grey),
          SizedBox(height: width * 0.04),
          Text("No papers found",
              style: TextStyle(
                  fontSize: width * 0.04,
                  color: isDark ? Colors.grey[400] : Colors.grey)),
        ],
      ),
    );
  }

  /// ================= TAB =================
  Widget _tab(String text, int index, double width, bool isDark) {
    final active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: width * 0.025),
          decoration: BoxDecoration(
            color: active ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              "$text (${_countForTab(index)})",
              style: TextStyle(
                fontSize: width * 0.03,
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= CARD =================
  Widget _card(
      Map<String, dynamic> paper,
      double width,
      double padding,
      ThemeData theme,
      bool isDark,
      ) {
    final tags = _extractTags(paper);
    final year = _extractYear(paper["published"]);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaperDetailPage(Paper.fromMap(paper)),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: padding, vertical: padding * 0.4),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.description, size: width * 0.06),
            SizedBox(width: padding),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${paper["title"] ?? ""} ${year.isNotEmpty ? "($year)" : ""}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(paper["author"] ?? "Unknown"),

                  Wrap(
                    spacing: 6,
                    children:
                    tags.map((t) => _tag(t, width, isDark)).toList(),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) async {
                paper["type"] = value;
                await SavedPapersService.updatePaper(paper);
                _loadSaved();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: "all", child: Text("Move to All")),
                PopupMenuItem(value: "collection", child: Text("Add to Collection")),
                PopupMenuItem(value: "archived", child: Text("Archive")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, double width, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: width * 0.01,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xffF1F3F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: width * 0.025)),
    );
  }

  List<String> _extractTags(Map<String, dynamic> paper) {
    List<String> tags = [];
    final title = (paper["title"] ?? "").toLowerCase();

    if (title.contains("transformer")) tags.add("Transformers");
    if (title.contains("vision")) tags.add("Vision");
    if (title.contains("quantum")) tags.add("Quantum");
    if (title.contains("deep")) tags.add("Deep Learning");

    return tags.take(2).toList();
  }

  String _extractYear(String? date) {
    if (date == null || date.isEmpty) return "";
    return date.split("-").first;
  }
}

class PaperSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> papers;

  PaperSearchDelegate(this.papers);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = "",
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = papers.where((e) =>
        (e["title"] ?? "").toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final paper = results[i];

        return ListTile(
          title: Text(paper["title"] ?? ""),
          onTap: () => close(context, query),
        );
      },
    );
  }
}