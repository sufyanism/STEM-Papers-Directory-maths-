import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholars_horizon/app/core/theme/theme_provider.dart';
import 'package:scholars_horizon/app/features/papers/presentation/pages/papers_page.dart';

class CsCategoryPage extends ConsumerWidget {
  const CsCategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    /// ✅ ONLY DATA CHANGED → PHYSICS
    /// ✅ MATHEMATICS CATEGORIES
    final categories = [
      {
        "title": "General Mathematics",
        "code": "math.GM",
        "arxiv": "math.GM",
        "icon": Icons.calculate,
        "color": Colors.indigo
      },
      {
        "title": "Algebra",
        "code": "math.AG",
        "arxiv": "math.AG",
        "icon": Icons.functions,
        "color": Colors.blue
      },
      {
        "title": "Number Theory",
        "code": "math.NT",
        "arxiv": "math.NT",
        "icon": Icons.confirmation_number,
        "color": Colors.deepPurple
      },
      {
        "title": "Geometry",
        "code": "math.DG",
        "arxiv": "math.DG",
        "icon": Icons.change_history,
        "color": Colors.green
      },
      {
        "title": "Combinatorics",
        "code": "math.CO",
        "arxiv": "math.CO",
        "icon": Icons.grid_on,
        "color": Colors.orange
      },
      {
        "title": "Probability",
        "code": "math.PR",
        "arxiv": "math.PR",
        "icon": Icons.bar_chart,
        "color": Colors.red
      },
      {
        "title": "Statistics",
        "code": "stat.TH",
        "arxiv": "stat.TH",
        "icon": Icons.show_chart,
        "color": Colors.teal
      },
      {
        "title": "Dynamical Systems",
        "code": "math.DS",
        "arxiv": "math.DS",
        "icon": Icons.loop,
        "color": Colors.pink
      },
      {
        "title": "Logic",
        "code": "math.LO",
        "arxiv": "math.LO",
        "icon": Icons.psychology,
        "color": Colors.brown
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text("Browse Mathematics", // ✅ updated text
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: width * 0.045,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(width * 0.04),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(height: height * 0.015),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _categoryTile(
            context,
            width: width,
            height: height,
            title: item["title"] as String,
            code: item["code"] as String,
            arxivCode: item["arxiv"] as String,
            icon: item["icon"] as IconData,
            color: item["color"] as Color,
            theme: theme,
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _categoryTile(
      BuildContext context, {
        required double width,
        required double height,
        required String title,
        required String code,
        required String arxivCode,
        required IconData icon,
        required Color color,
        required ThemeData theme,
        required bool isDark,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(width * 0.04),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PapersPage(
              title: title,
              category: arxivCode,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.018,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(width * 0.04),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.025),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
              child: Icon(icon, color: color, size: width * 0.055),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: "$title ",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: width * 0.04,
                  ),
                  children: [
                    TextSpan(
                      text: "($code)",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: width * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              size: width * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}