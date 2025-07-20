import 'package:cityinsurance/screens/about_us_page.dart';
import 'package:cityinsurance/screens/contact_us_page.dart';
import 'package:cityinsurance/screens/fire.dart';
import 'package:cityinsurance/screens/personal_accident.dart';
import 'package:flutter/material.dart';
import 'package:cityinsurance/screens/webview_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Widget _buildCard(
    BuildContext context,
    String title,
    String imagePath, {
    VoidCallback? onTap,
  }) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 100,
                width: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12, // Updated to 11px
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(
    String label,
    VoidCallback onPressed, {
    Color backgroundColor = const Color(0xFF00796B),
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11, // Updated to 11px
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00796B);

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 6,
        title: const Text(
          "CITY INSURANCE ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13, // Updated to 11px
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              image: DecorationImage(
                image: AssetImage('assets/icons/banner.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 1,
                      children: [
                        _buildCard(
                          context,
                          "Overseas Mediclaim Policy",
                          "assets/icons/ompp.png",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WebViewPage(
                                  title: "Overseas Mediclaim Policy",
                                  url:
                                      "https://citydigital.csl-erp.com/Ompquote",
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          context,
                          "MOTOR INSURANCE",
                          "assets/icons/motorinsurace.png",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WebViewPage(
                                  title: "Motor Quote",
                                  url:
                                      "https://citydigital.csl-erp.com/Motorquote",
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          context,
                          "FIRE PROPOSAL",
                          "assets/icons/fire.jpg",
                            onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FireInsuranceFormScreen(),
                                  ),
                                );
                              }
                        ),
                        _buildCard(
                          context,
                          "MARINE DECLARATION",
                          "assets/icons/marine.jpeg",
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PersonalAccidentPage(),
                                  ),
                                );
                              },
                              child: _buildCard(
                                context,
                                "PERSONAL ACCIDENT",
                                "assets/icons/pa.png",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTextButton("About Us", () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AboutUsPage(),
                                  ),
                                );
                              }, backgroundColor: Colors.blue),
                              const SizedBox(height: 16),
                              _buildTextButton("Contact Us", () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ContactUsPage(),
                                  ),
                                );
                              }, backgroundColor: Colors.blue),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: SizedBox(
                height: 40,
                width: 160,
                child: Image.asset(
                  'assets/icons/icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
