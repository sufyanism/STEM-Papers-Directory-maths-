import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/saved_paper_service.dart';
import '../../../../core/utils/reading_history_service.dart';
import '../../../../core/theme/theme_provider.dart';

import '../../../auth/presentation/login_page.dart';
import 'saved_paper_page.dart';
import 'reading_history_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int savedCount = 0;
  int readingCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    try {
      final saved = await SavedPapersService.getSavedPapers();
      final history = await ReadingHistoryService.getHistory();

      if (!mounted) return;

      setState(() {
        savedCount = saved.length;
        readingCount = history.length;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final padding = width * 0.04;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                _profileHeader(width, isDark),
                SizedBox(height: padding),

                _statsCard(width, isDark),
                SizedBox(height: padding),

                _menuCard(),
                SizedBox(height: padding),

                _extraOptions(),
                SizedBox(height: padding),

                _settingsCard(),
                SizedBox(height: padding),

                _logoutCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _profileHeader(double width, bool isDark) {
    return Column(
      children: [
        CircleAvatar(
          radius: width * 0.09,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: width * 0.09),
        ),
        SizedBox(height: width * 0.02),

        Text(
          "Sarvesh",
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),

        SizedBox(height: width * 0.01),

        Text(
          "Research Reader",
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: width * 0.032,
          ),
        ),
      ],
    );
  }

  /// ================= STATS =================
  Widget _statsCard(double width, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: width * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(savedCount.toString(), "Saved", width),
          _divider(),
          _statItem(readingCount.toString(), "Reading", width),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, double width) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: width * 0.045,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        SizedBox(height: width * 0.01),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: width * 0.03,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 30, width: 1, color: Colors.grey);
  }

  /// ================= MENU =================
  Widget _menuCard() {
    return _card([
      _menuItem(Icons.bookmark, "Saved Papers", () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedPage()),
        );
        await loadData();
      }),
      _dividerLine(),
      _menuItem(Icons.history, "Reading History", () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReadingHistoryPage()),
        );
        await loadData();
      }),
    ]);
  }

  /// ================= EXTRA =================
  Widget _extraOptions() {
    return _card([
      _menuItem(Icons.share, "Export Saved Papers", () async {
        final data = await SavedPapersService.getSavedPapers();

        if (data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No saved papers")),
          );
          return;
        }

        final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
        Share.share(prettyJson);
      }),
      _dividerLine(),
      _menuItem(Icons.delete_forever, "Clear Saved Papers", () async {
        await SavedPapersService.clearAll();
        await loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved cleared")),
        );
      }),
      _dividerLine(),
      _menuItem(Icons.info_outline, "About App", () {
        showAboutDialog(
          context: context,
          applicationName: "Scholars Horizon",
          applicationVersion: "1.0",
          children: const [
            Text("Minimal research paper reader app built with Flutter."),
          ],
        );
      }),
    ]);
  }

  /// ================= SETTINGS =================
  Widget _settingsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _card([
      SwitchListTile(
        value: isDark,
        title: const Text("Dark Mode"),
        onChanged: (v) {
          ref.read(themeProvider.notifier).toggleTheme(v);
        },
      ),
      _dividerLine(),
      _menuItem(Icons.delete, "Clear Reading History", () async {
        await ReadingHistoryService.clearHistory();
        await loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("History cleared")),
        );
      }),
    ]);
  }

  /// ================= LOGOUT =================
  Widget _logoutCard() {
    return _card([
      _menuItem(Icons.logout, "Logout", () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await SavedPapersService.clearAll();
          await ReadingHistoryService.clearHistory();

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
          );
        }
      }),
    ]);
  }

  /// ================= COMMON =================
  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(IconData icon, String text, VoidCallback onTap) {
    final width = MediaQuery.of(context).size.width;

    return ListTile(
      leading: Icon(
        icon,
        size: width * 0.06,
        color: Theme.of(context).iconTheme.color,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: width * 0.038,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: width * 0.05),
      onTap: onTap,
    );
  }

  Widget _dividerLine() {
    return Divider(height: 1, color: Colors.grey[300]);
  }
}