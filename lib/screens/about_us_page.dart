import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String aboutText =
        "City General Insurance Company Limited is one of the leading Non-life insurance company engaged in general insurance business since 1996. "
        "The company incorporated under the Companies Act 1994 and obtained its certificate of registration from the then Controller of Insurance, "
        "Government of the People’s Republic of Bangladesh. The company is engaged in various types of Non-life insurance business and it has automatic "
        "reinsurance arrangement, i.e. Treaty Agreement for all classes of insurance with Reinsurer. We ensure prompt settlement of all types of claim "
        "with utmost satisfaction of the insured within the shortest possible time. CRISL upgraded the company at AA- with a “Stable Outlook”.";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00796B),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFE0F2F1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(7),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 6,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 60,
                  color: Color(0xFF00796B),
                ),
                const SizedBox(height: 12),
                const Text(
                  "City General Insurance Company Ltd.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D40),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  aboutText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
