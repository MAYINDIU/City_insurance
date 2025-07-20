import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00796B);
    const Color textColor = Color(0xFF040404);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFE0F2F1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/icons/icon.png', // Use your image path
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Contact Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3949AB),
                    ),
                  ),
                ),
                const Divider(thickness: 1.2, color: Colors.grey),
                const SizedBox(height: 12),

                _buildInfoRow(
                  Icons.location_on,
                  "Address",
                  "Head Office, Baitul Hossain Building (4th Floor),\n27 Dilkusha C/A, Dhaka-1000, Bangladesh.",
                  textColor,
                ),
                _buildInfoRow(
                  Icons.phone,
                  "Telephone",
                  "9557735-8, 9557751, 9577635, 7111543",
                  textColor,
                ),
                _buildInfoRow(
                  Icons.email_outlined,
                  "E-mail",
                  "info@cityinsurance.com.bd",
                  textColor,
                ),
                _buildInfoRow(
                  Icons.language,
                  "Web",
                  "www.cityinsurance.com.bd",
                  textColor,
                ),
                _buildInfoRow(
                  Icons.support_agent,
                  "Hotline",
                  "+88 01711695906",
                  textColor,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
