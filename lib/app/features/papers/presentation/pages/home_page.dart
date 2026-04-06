import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholars_horizon/app/features/papers/presentation/pages/paper_detail_page.dart';
import 'package:scholars_horizon/app/features/papers/presentation/pages/profile_page.dart';
import 'package:scholars_horizon/app/features/papers/presentation/pages/saved_paper_page.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/saved_paper_service.dart';
import '../providers/paper_provider.dart';
import 'category_page.dart';
import 'search_page.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int currentIndex = 0;
  int selectedTab = 0;
  int selectedTrendingFilter = 1;

  Set<String> savedPapers = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(categoryProvider.notifier).state = "physics.gen-ph"; // ✅ UPDATED
      ref.read(searchProvider.notifier).state = "";
    });

    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final data = await SavedPapersService.getSavedPapers();
    setState(() {
      savedPapers = data.map((e) => e["link"] as String).toSet();
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final papersAsync = ref.watch(paperProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: [
            _homeUI(papersAsync, theme, isDark),
            const SearchPage(),
            const CsCategoryPage(),
            const SavedPage(),
            const ProfilePage(),
          ],
        ),
      ),

      /// ✅ THEMED BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: Colors.red,
        unselectedItemColor:
        isDark ? Colors.grey[400] : Colors.grey[600],
        onTap: (i) async {
          setState(() => currentIndex = i);
          if (i == 0) await _loadSaved();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  /// ================= HOME =================
  Widget _homeUI(AsyncValue papersAsync, ThemeData theme, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth * 0.04;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(padding, theme, isDark),
            SizedBox(height: padding * 0.5),

            Expanded(
              child: papersAsync.when(
                data: (data) {
                  if (selectedTab == 1) {
                    return _trendingUI(data, padding, theme, isDark);
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: padding),
                    itemCount: data.length,
                    itemBuilder: (_, i) =>
                        _card(data[i], padding, theme, isDark),
                  );
                },
                loading: () => _shimmer(isDark),
                error: (e, _) => Center(child: Text("Error: $e")),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ================= HEADER =================
  Widget _header(double padding, ThemeData theme, bool isDark) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding * 0.8, padding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/logo.png', height: width * 0.08),
              Row(
                children: [
                  Icon(Icons.notifications_none, size: width * 0.06),
                  SizedBox(width: padding),
                  GestureDetector(
                    onTap: () => setState(() => currentIndex = 1),
                    child: Icon(Icons.search, size: width * 0.06),
                  ),
                ],
              )
            ],
          ),

          SizedBox(height: padding),

          Text(
            "${getGreeting()}, Sarvesh 👋",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: padding * 0.3),

          Text(
            "Discover new research papers",
            style: TextStyle(
              fontSize: width * 0.035,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
          ),

          SizedBox(height: padding),

          /// TABS
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _tab("For You", 0, isDark),
                _tab("Trending", 1, isDark),
                _tab("Latest", 2, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= TRENDING =================
  Widget _trendingUI(List data, double padding, ThemeData theme, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(padding),
          child: Text(
            "Trending Papers",
            style: theme.textTheme.titleLarge,
          ),
        ),

        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: padding),
            children: [
              _trendChip("Today", 0, isDark),
              _trendChip("This Week", 1, isDark),
              _trendChip("This Month", 2, isDark),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) =>
                _trendCard(data[i], i, padding, theme, isDark),
          ),
        ),
      ],
    );
  }

  Widget _trendCard(paper, int index, double padding, ThemeData theme, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaperDetailPage(paper),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: padding, vertical: 6),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(paper.title, maxLines: 2),
      ),
    );
  }

  /// ================= CARD =================
  Widget _card(paper, double padding, ThemeData theme, bool isDark) {
    final isSaved = savedPapers.contains(paper.link);

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
        margin: EdgeInsets.symmetric(horizontal: padding, vertical: 6),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(paper.title, maxLines: 2),

            SizedBox(height: padding),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(paper.published ?? "")),

                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
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
                        "type": "all",
                      });
                    } else {
                      await SavedPapersService.removePaper(paper.link);
                    }
                    await _loadSaved();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _trendChip(String text, int index, bool isDark) {
    final active = selectedTrendingFilter == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTrendingFilter = index),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Colors.red
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, int index, bool isDark) {
    final active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmer(bool isDark) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.all(12),
          height: 100,
          color: Colors.white,
        ),
      ),
    );
  }
}