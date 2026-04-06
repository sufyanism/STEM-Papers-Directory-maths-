import 'package:flutter/material.dart';
import 'welcome_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF2F4F7);

    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            children: [

              /// 🔷 CENTER CONTENT
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    /// LOGO
                    Image.asset(
                      "assets/images/logo.png",
                      height: height * 0.08,
                    ),

                    SizedBox(height: height * 0.02),

                    /// SMALL TITLE
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: height * 0.008),

                    /// MAIN TITLE
                    Text(
                      "Research Paper App",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: height * 0.015),

                    /// SUBTITLE
                    Text(
                      "Discover, read, and organize\nscientific research from arXiv",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: width * 0.035,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    /// IMAGE
                    Image.asset(
                      "assets/images/mountain.png",
                      width: width * 0.9,
                      height: height * 0.25,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              /// 🔴 BUTTON (BOTTOM)
              SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE53935),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(width * 0.04),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WelcomePage(),
                      ),
                    );
                  },
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.04,
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}