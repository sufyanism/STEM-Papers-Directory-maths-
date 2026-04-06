import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scholars_horizon/app/features/papers/presentation/pages/paper_detail_page.dart';
import 'package:xml/xml.dart';
import '../../data/datasources/arxiv_api.dart';
import '../../domain/entities/paper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ArxivApi api = ArxivApi();

  Timer? _debounce;

  bool openAccessOnly = true;

  String selectedFilter = "All";
  String searchQuery = "";

  List<Paper> papers = [];
  bool loading = false;

  /// ✅ ONLY DATA CHANGED → PHYSICS FILTERS
  final Map<String, String> filters = {
    "All": "",
    "Algebra": "algebra",
    "Number Theory": "prime numbers",
    "Geometry": "geometry",
    "Probability": "probability",
    "Combinatorics": "graphs",
    "Topology": "topology",
    "Calculus": "integration",
    "Linear Algebra": "matrices",
  };

  /// ✅ ONLY DATA CHANGED → PHYSICS TRENDING
  final List<String> trending = [
    "prime numbers",
    "riemann hypothesis",
    "graph theory",
    "linear algebra",
    "probability theory",
  ];

  @override
  void initState() {
    super.initState();
    fetchPapers();
  }

  Future<void> fetchPapers() async {
    setState(() => loading = true);

    try {
      /// ✅ CHANGED CATEGORY → PHYSICS
      final raw = await api.fetchPapers("math.GM", searchQuery);
      papers = parseArxiv(raw);
    } catch (e) {
      papers = [];
    }

    setState(() => loading = false);
  }

  List<Paper> parseArxiv(String rawXml) {
    try {
      final document = XmlDocument.parse(rawXml);
      final entries = document.findAllElements('entry');

      return entries.map((entry) {
        final authors = entry
            .findAllElements("author")
            .map((a) => a.getElement("name")?.innerText ?? "")
            .where((name) => name.isNotEmpty)
            .join(", ");

        return Paper(
          title: entry.getElement('title')?.innerText.trim() ?? "",
          summary: entry.getElement('summary')?.innerText.trim() ?? "",
          author: authors,
          link: entry.getElement('id')?.innerText.trim() ?? "",
          published: entry.getElement('published')?.innerText.trim() ?? "",
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            /// 🔻 TOP SECTION
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔍 SEARCH BAR
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 500),
                                () {
                              searchQuery = value.trim();
                              fetchPapers();
                            },
                          );
                        },
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: width * 0.035,
                        ),
                        decoration: InputDecoration(
                          /// ✅ TEXT UPDATED
                          hintText: "Search mathematics papers...",
                          hintStyle: TextStyle(
                            fontSize: width * 0.035,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                          prefixIcon: Icon(Icons.search, size: width * 0.06),
                          suffixIcon: Icon(Icons.mic, size: width * 0.06),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(height: padding),

                    /// FILTER TITLE
                    Text(
                      "Quick Filters",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: width * 0.04,
                      ),
                    ),

                    SizedBox(height: padding * 0.5),

                    /// FILTER CHIPS (UNCHANGED UI)
                    SizedBox(
                      height: width * 0.1,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (_, __) => SizedBox(width: padding * 0.5),
                        itemBuilder: (_, index) {
                          final key = filters.keys.elementAt(index);
                          final isActive = selectedFilter == key;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFilter = key;
                                searchQuery = filters[key]!;
                                _controller.text = searchQuery;
                              });
                              fetchPapers();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: padding,
                                vertical: padding * 0.3,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.red.withOpacity(0.15)
                                    : theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.red
                                      : (isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey.shade300),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  key,
                                  style: TextStyle(
                                    fontSize: width * 0.032,
                                    color: isActive
                                        ? Colors.red
                                        : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: padding),

                    /// SWITCH (UNCHANGED)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Open Access only",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontSize: width * 0.035),
                        ),
                        Switch(
                          value: openAccessOnly,
                          activeColor: Colors.red,
                          onChanged: (val) {
                            setState(() {
                              openAccessOnly = val;
                            });
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: padding),

                    /// BUTTON (UNCHANGED)
                    SizedBox(
                      width: double.infinity,
                      height: width * 0.12,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          searchQuery = _controller.text.trim();
                          fetchPapers();
                        },
                        child: Text(
                          "Search Papers",
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                      ),
                    ),

                    SizedBox(height: padding),

                    /// TRENDING (UNCHANGED UI)
                    Text(
                      "Trending",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: width * 0.04,
                      ),
                    ),

                    SizedBox(height: padding * 0.5),

                    Wrap(
                      spacing: padding * 0.5,
                      runSpacing: padding * 0.5,
                      children: trending.map((text) {
                        return GestureDetector(
                          onTap: () {
                            _controller.text = text;
                            searchQuery = text;
                            fetchPapers();
                          },
                          child: Chip(
                            backgroundColor: theme.cardColor,
                            label: Text(
                              text,
                              style: TextStyle(
                                fontSize: width * 0.032,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            /// RESULTS (UNCHANGED)
            Expanded(
              flex: 3,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : papers.isEmpty
                  ? Center(
                child: Text(
                  "No papers found",
                  style: TextStyle(fontSize: width * 0.04),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: papers.length,
                itemBuilder: (_, i) {
                  final paper = papers[i];

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaperDetailPage(paper),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: padding),
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            paper.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: padding * 0.4),
                          Text(
                            paper.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: padding * 0.4),
                          Text(
                            paper.published.length >= 10
                                ? paper.published
                                .substring(0, 10)
                                : "",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}