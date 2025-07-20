// lib/screens/pdf_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart'; // Crucial for getting the directory
import 'package:open_file/open_file.dart'; // Crucial for opening the PDF
import 'dart:io';

class PdfViewerPage extends StatefulWidget {
  final Map<String, dynamic> apiData;

  const PdfViewerPage({Key? key, required this.apiData}) : super(key: key);

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _pdfFilePath;
  bool _isLoadingPdf = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generatePdfReport(); // Start PDF generation immediately
  }

  Future<void> _generatePdfReport() async {
    setState(() {
      _isLoadingPdf = true;
      _errorMessage = '';
    });

    try {
      final pdf = pw.Document();

      final data = widget.apiData;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          // No custom font theme applied here, defaults will be used.
          header: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.center,
              margin: const pw.EdgeInsets.only(bottom: 10.0),
              padding: const pw.EdgeInsets.only(bottom: 5.0),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
                ),
              ),
              child: pw.Text(
                'Personal Accident Policy Report',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.SizedBox(height: 20),
              pw.Text(
                'Policy Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfDetailRow('Policy ID:', data['id']?.toString() ?? 'N/A'),
              _buildPdfDetailRow('Insured Name:', data['name'] ?? 'N/A'),
              _buildPdfDetailRow('Insured Address:', data['address'] ?? 'N/A'),
              _buildPdfDetailRow('Sum Insured:', data['amount']?.toString() ?? 'N/A'),
              _buildPdfDetailRow('Premium:', data['premium']?.toString() ?? 'N/A'),
              _buildPdfDetailRow('VAT:', data['vat']?.toString() ?? 'N/A'),
              _buildPdfDetailRow('Stamp:', data['stamp']?.toString() ?? 'N/A'),
              _buildPdfDetailRow('Total Payable:', data['grand_total']?.toString() ?? 'N/A'),
              _buildPdfDetailRow('Rate:', data['rate']?.toString() ?? 'N/A'),
              _buildPdfDetailRow('Period From:', data['period_from'] ?? 'N/A'),
              _buildPdfDetailRow('Period To:', data['period_to'] ?? 'N/A'),
              _buildPdfDetailRow('Class:', data['Class'] ?? 'N/A'),
              _buildPdfDetailRow('Table:', data['Tables'] ?? 'N/A'),

              pw.SizedBox(height: 20),
              pw.Text(
                'Contact Information',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfDetailRow('Mobile:', data['mobile'] ?? 'N/A'),
              _buildPdfDetailRow('Email:', data['email'] ?? 'N/A'),
              _buildPdfDetailRow('Father\'s Name:', data['fathers_name'] ?? 'N/A'),
              _buildPdfDetailRow('NID:', data['nid'] ?? 'N/A'),

              pw.SizedBox(height: 20),
              pw.Text(
                'Nominee Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfDetailRow('Nominee Name & Address:', data['nominee'] ?? 'N/A'),
              _buildPdfDetailRow('Nominee Relation:', data['relation'] ?? 'N/A'),
              _buildPdfDetailRow('Nominee NID:', data['nominee_nid'] ?? 'N/A'),
              _buildPdfDetailRow('Nominee Mobile:', data['nominee_mbl'] ?? 'N/A'),
              _buildPdfDetailRow('Nominee Email:', data['nominee_email'] ?? 'N/A'),
            ];
          },
        ),
      );

      // Get the temporary directory path provided by the OS
      final output = await getTemporaryDirectory();
      // Create a unique file name for the PDF
      final fileName = 'personal_accident_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      // Write the PDF bytes to the file
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _pdfFilePath = file.path;
        _isLoadingPdf = false;
      });
      // IMPORTANT CHANGE: Remove _openPdf() call here
      // The user will now click the "View PDF" button to open it.
      _showSnackbar('PDF has been successfully generated.');

    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating PDF: $e';
        _isLoadingPdf = false;
      });
      print("PDF Generation Error: $e"); // Log the specific error for debugging
      _showSnackbar('Error generating PDF.');
    }
  }

  void _openPdf() {
    if (_pdfFilePath != null) {
      // OpenFile.open will typically prompt the user to choose an app
      // to view the PDF, effectively acting as a "download and view" trigger.
      OpenFile.open(_pdfFilePath);
    } else {
      _showSnackbar("PDF file path is not available. Please try regenerating.");
    }
  }

  // Helper widget for building rows in the PDF content
  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150, // Fixed width for the label to align content
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          // pw.Expanded ensures the value text takes remaining space and wraps if needed
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PDF Report",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isLoadingPdf
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        'Generating PDF...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  )
                : _errorMessage.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 50),
                          const SizedBox(height: 20),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _generatePdfReport,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 80),
                          const SizedBox(height: 20),
                          Text(
                            'PDF Generated Successfully!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _openPdf, // This button now initiates the "download/view"
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('View PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Go back to the previous page
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Go Back'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}