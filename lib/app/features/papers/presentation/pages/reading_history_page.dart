import 'package:flutter/material.dart';
import '../../../../core/utils/reading_history_service.dart';

class ReadingHistoryPage extends StatefulWidget {
  const ReadingHistoryPage({super.key});

  @override
  State<ReadingHistoryPage> createState() => _ReadingHistoryPageState();
}

class _ReadingHistoryPageState extends State<ReadingHistoryPage> {
  List history = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await ReadingHistoryService.getHistory();
    setState(() => history = data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;

    final padding = width * 0.04;
    final titleSize = width * 0.04;
    final subSize = width * 0.032;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          "Reading History",
          style: TextStyle(fontSize: width * 0.045),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.iconTheme?.color,
        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: load,
        child: history.isEmpty
            ? ListView(
          children: [
            SizedBox(height: width * 0.4),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: width * 0.15,
                    color: isDark ? Colors.grey[500] : Colors.grey,
                  ),
                  SizedBox(height: padding),
                  Text(
                    "No history yet",
                    style: TextStyle(
                      fontSize: titleSize,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: EdgeInsets.all(padding),
          itemCount: history.length,
          itemBuilder: (_, i) {
            final paper = history[i];
            return _historyCard(
              paper,
              width,
              padding,
              titleSize,
              subSize,
              theme,
              isDark,
            );
          },
        ),
      ),
    );
  }

  /// ================= CARD =================
  Widget _historyCard(
      Map paper,
      double width,
      double padding,
      double titleSize,
      double subSize,
      ThemeData theme,
      bool isDark,
      ) {
    return Container(
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
            paper["title"] ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: padding * 0.4),

          /// DATE
          Text(
            paper["published"] ?? "",
            style: TextStyle(
              fontSize: subSize,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}