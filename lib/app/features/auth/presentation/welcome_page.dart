import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "1M+ Research Papers",
      "subtitle":
      "Access arXiv's vast collection across all disciplines.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Read Instantly",
      "subtitle":
      "Get abstracts and insights in seconds.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Save & Share",
      "subtitle":
      "Bookmark and share important papers easily.",
    },
  ];

  void nextPage() {
    if (currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      goToLogin();
    }
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ important
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            /// 🔥 TOP BAR (SKIP)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: goToLogin,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 📱 PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        /// IMAGE
                        Image.asset(
                          onboardingData[index]["image"]!,
                          height: height * 0.28,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: height * 0.05),

                        /// TITLE
                        Text(
                          onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.065,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: height * 0.015),

                        /// SUBTITLE
                        Text(
                          onboardingData[index]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// 🔘 DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                  width: currentPage == index ? width * 0.05 : width * 0.015,
                  height: height * 0.008,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Colors.red
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.025),

            /// 🚀 NEXT BUTTON
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                  ),
                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.04),
          ],
        ),
      ),
    );
  }
}