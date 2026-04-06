import 'package:flutter/material.dart';
import '../../papers/presentation/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔷 TOP SPACE (RESPONSIVE)
                    SizedBox(height: height * 0.08),

                    /// 🔷 LOGO
                    Image.asset(
                      "assets/images/logo.png",
                      height: height * 0.1,
                      width: height * 0.1,
                    ),

                    SizedBox(height: height * 0.03),

                    /// 🔷 TITLE
                    Text(
                      "Sign In to Your Account",
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    /// 🔷 SUBTITLE
                    Text(
                      "Access your papers and personalized feed",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: width * 0.038,
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    /// 🔷 GOOGLE BUTTON
                    _socialButton(
                      context,
                      icon: Icons.g_mobiledata,
                      text: "Continue with Google",
                      bgColor: Colors.white,
                      textColor: Colors.black,
                      border: true,
                      onTap: () => _goHome(context),
                    ),

                    SizedBox(height: height * 0.02),

                    /// 🔷 FACEBOOK BUTTON
                    _socialButton(
                      context,
                      icon: Icons.facebook,
                      text: "Continue with Facebook",
                      bgColor: const Color(0xff1877F2),
                      textColor: Colors.white,
                      onTap: () => _goHome(context),
                    ),

                    SizedBox(height: height * 0.035),

                    /// 🔷 DIVIDER
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                          child: Text(
                            "OR",
                            style: TextStyle(fontSize: width * 0.035),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    SizedBox(height: height * 0.035),

                    /// 🔷 GUEST BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.07,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.04),
                          ),
                        ),
                        onPressed: () => _goHome(context),
                        child: Text(
                          "Continue as Guest",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: width * 0.04,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// 🔷 FOOTER
                    Center(
                      child: Text(
                        "Scholar's Horizon",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: width * 0.03,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 NAVIGATION
  void _goHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  /// 🔥 SOCIAL BUTTON (RESPONSIVE)
  Widget _socialButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required Color bgColor,
        required Color textColor,
        bool border = false,
        required VoidCallback onTap,
      }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      height: height * 0.07,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.04),
            side: border
                ? const BorderSide(color: Colors.black12)
                : BorderSide.none,
          ),
        ),
        icon: Icon(icon, size: width * 0.06),
        label: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: width * 0.04,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}