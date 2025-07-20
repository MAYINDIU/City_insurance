import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pdf/pdf.dart'; // For PDF generation
import 'package:pdf/widgets.dart' as pw; // For PDF widgets
import 'package:path_provider/path_provider.dart'; // For getting app directories
import 'package:open_file/open_file.dart'; // For opening the generated PDF
import 'dart:io'; // For file operations

// Model class for dropdowns and API responses
class Model {
  final String name;
  final String pType; // Corresponds to 'CODE' or 'Type' in your JSON

  Model(this.name, this.pType);

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(json['NAME'] ?? '', json['CODE'] ?? '');
  }
}

class PersonalAccidentPage extends StatefulWidget {
  const PersonalAccidentPage({super.key});

  @override
  _PersonalAccidentPageState createState() => _PersonalAccidentPageState();
}

class _PersonalAccidentPageState extends State<PersonalAccidentPage> {
  // --- Controllers for TextFields ---
  final TextEditingController _insuredNamePaController =
      TextEditingController();
  final TextEditingController _insuredAddressPaController =
      TextEditingController();
  final TextEditingController _fathersNamePaController =
      TextEditingController();
  final TextEditingController _nomineeAddressPaController =
      TextEditingController();
  final TextEditingController _nidPaController = TextEditingController();
  final TextEditingController _sumInsuredPaController = TextEditingController();
  final TextEditingController _ratePaController = TextEditingController();
  final TextEditingController _premiumPaController = TextEditingController();
  final TextEditingController _vatPaController = TextEditingController();
  final TextEditingController _totalPaController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _stampPaController = TextEditingController();
  final TextEditingController _nomineeNidsController = TextEditingController();
  final TextEditingController _nomineeMblsController = TextEditingController();
  final TextEditingController _nomineeEmailsController =
      TextEditingController();

  // --- Date Variables ---
  DateTime? _startDate;
  DateTime? _endDate;
  String? _startDatePaString;
  String? _endDatePaString;

  // --- Spinner/Dropdown Variables ---
  List<Model> _relationList = [
    Model("Select Relation", ""), // Default/Hint item
    Model("Father", "FATHER"),
    Model("Mother", "MOTHER"),
    Model("Sister", "SISTER"),
    Model("Brother", "BROTHER"),
    Model("Wife", "WIFE"),
    Model("Son", "SON"),
    Model("Daughter", "DAUGHTER"),
  ];
  Model? _selectedRelation;

  List<Model> _classList = [
    Model("Select Class", ""), // Default/Hint item
  ];
  Model? _selectedClass;
  String? _classNumber; // Corresponds to 'CODE'
  String? _className; // Corresponds to 'NAME'

  List<Model> _tableList = [
    Model("Select Table", ""), // Default/Hint item
  ];
  Model? _selectedTable;
  String? _tableCode; // Corresponds to 'CODE'
  String? _tableName; // Corresponds to 'NAME'

  // --- Calculation Variables ---
  double _stmpp = 0.0;
  int _prum = 0; // Premium
  int _vatt = 0; // VAT
  int _grandTotal = 0;

  bool _isLoading = false; // For showing a loading indicator
  String? _pdfFilePath; // To store the path of the generated PDF

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Data received from the API for PDF generation
  Map<String, dynamic>? _apiDataForPdf;

  @override
  void initState() {
    super.initState();
    _selectedRelation = _relationList.first; // Initialize selected relation
    _ratePaController.text = "0"; // Initialize rate text
    _premiumPaController.text = "0";
    _vatPaController.text = "0";
    _stampPaController.text = "0";
    _totalPaController.text = "0";

    _fetchClassList();
    _fetchTableList();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _insuredNamePaController.dispose();
    _insuredAddressPaController.dispose();
    _fathersNamePaController.dispose();
    _nomineeAddressPaController.dispose();
    _nidPaController.dispose();
    _sumInsuredPaController.dispose();
    _ratePaController.dispose();
    _premiumPaController.dispose();
    _vatPaController.dispose();
    _totalPaController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _stampPaController.dispose();
    _nomineeNidsController.dispose();
    _nomineeMblsController.dispose();
    _nomineeEmailsController.dispose();
    super.dispose();
  }

  // --- Network Check (Simplified for Dart) ---
  Future<bool> _isConnected() async {
    // In a real Flutter app, use connectivity_plus package for robust check
    // import 'package:connectivity_plus/connectivity_plus.dart';
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // return connectivityResult != ConnectivityResult.none;
    return true; // Assume connected for this example
  }

  // --- API Calls ---
  Future<void> _fetchClassList() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(
      "https://cityinsurancedigital.com.bd/demo/api_apps/omp/classlist.php",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            _classList = (jsonResponse['data'] as List)
                .map((item) => Model.fromJson(item))
                .toList();
            // Add a default "Select Class" option at the beginning
            _classList.insert(0, Model("Select Class", ""));
            _selectedClass = _classList.first;
            if (_selectedClass != null) {
              _classNumber = _selectedClass!.pType;
              _className = _selectedClass!.name;
              _calculateResult(); // Call to update rate
            }
          });
        } else {
          _showToast("Failed to fetch class data: ${jsonResponse['message']}");
        }
      } else {
        _showToast("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showToast("Network error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTableList() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(
      "https://cityinsurancedigital.com.bd/demo/api_apps/omp/tablelist.php",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            _tableList = (jsonResponse['data'] as List)
                .map((item) => Model.fromJson(item))
                .toList();
            // Add a default "Select Table" option at the beginning
            _tableList.insert(0, Model("Select Table", ""));
            _selectedTable = _tableList.first;
            if (_selectedTable != null) {
              _tableCode = _selectedTable!.pType;
              _tableName = _selectedTable!.name;
              _calculateResult(); // Call to update rate
            }
          });
        } else {
          _showToast("Failed to fetch table data: ${jsonResponse['message']}");
        }
      } else {
        _showToast("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showToast("Network error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPa() async {
    if (!await _isConnected()) {
      _showToast("No internet connection.");
      return;
    }

    // Validate all required fields using the form key
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // --- API Call: insert_personal_datas.php ---
      final apiUrl = Uri.parse(
        "https://cityinsurancedigital.com.bd/demo/api_apps/personal/insert_personal_datas.php",
      );

      // Prepare POST parameters as a Map for x-www-form-urlencoded
      final Map<String, String> params = {
        "name": _insuredNamePaController.text,
        "address": _insuredAddressPaController.text,
        "amount": _sumInsuredPaController.text,
        "vat": _vatt.toString(),
        "grand_total": _grandTotal.toString(),
        "rate": _ratePaController.text,
        "mobile": _mobileController.text,
        "email": _emailController.text,
        "fathers_name": _fathersNamePaController.text,
        "relation": _selectedRelation?.name ?? "",
        "nominee": _nomineeAddressPaController.text,
        "nid": _nidPaController.text,
        "period_from": _startDatePaString ?? "",
        "period_to": _endDatePaString ?? "",
        "premium": _prum.toString(),
        "Class": _className ?? "",
        "Tables": _tableName ?? "",
        "nominee_nid": _nomineeNidsController.text,
        "nominee_mbl": _nomineeMblsController.text,
        "nominee_email": _nomineeEmailsController.text,
        "stamp": _stmpp.toString(),
      };

      try {
        final response = await http.post(apiUrl, body: params);

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success']) {
            _apiDataForPdf = jsonResponse['data']; // Store data for PDF
            // Clear form fields after successful submission
            _clearFormFields();
            // Generate PDF report
            _generatePdfReport(); // This will handle showing the alert and button
          } else {
            _showToast(
              "Failed to save personal data: ${jsonResponse['message']}",
            );
          }
        } else {
          _showToast(
            "Server error on personal data save: ${response.statusCode}",
          );
        }
      } catch (e) {
        String errorMsg = "Error occurred";
        if (e is http.ClientException && e.message.contains("timed out")) {
          errorMsg = "Request timeout";
        } else if (e is FormatException) {
          errorMsg = "Invalid response from server";
        }
        _showToast(errorMsg);
        print("API Error: $e"); // Log the error for debugging
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showToast("Please fill in all required fields correctly.");
    }
  }

  // --- Calculation Logic ---
  void _calculatePremium() {
    final sumValueText = _sumInsuredPaController.text;
    final rateText = _ratePaController.text;

    if (sumValueText.isEmpty || rateText.isEmpty) {
      _showToast("Please enter Sum Insured and ensure Rate is set.");
      return;
    }

    double sumValue = double.tryParse(sumValueText) ?? 0.0;
    double rate = double.tryParse(rateText) ?? 0.0;

    if (sumValue <= 0) {
      _showToast("Sum Insured must be greater than zero");
      return;
    }
    if (rate <= 0) {
      _showToast(
        "Rate must be greater than zero. Please select Class and Table.",
      );
      return;
    }

    setState(() {
      _prum = (sumValue / 10000 * rate).round();
      _premiumPaController.text = NumberFormat('#,##0').format(_prum);

      _vatt = (_prum * 0.15).ceil();
      _vatPaController.text = NumberFormat('#,##0').format(_vatt);

      _stmpp = 0.0;
      if (sumValue >= 25000) {
        _stmpp = 20.0;
        double additionalAmount = sumValue - 25000;
        int additionalUnits = (additionalAmount / 5000).floor();
        _stmpp += additionalUnits * 20;
      }
      _stampPaController.text = NumberFormat('#,##0').format(_stmpp.round());

      _grandTotal = (_prum + _vatt + _stmpp).round();
      _totalPaController.text = NumberFormat('#,##0').format(_grandTotal);
    });
  }

  void _calculateResult() {
    setState(() {
      if (_selectedClass == null ||
          _selectedTable == null ||
          _selectedClass?.pType == "" ||
          _selectedTable?.pType == "") {
        _ratePaController.text = "0";
        _premiumPaController.text = "0";
        _vatPaController.text = "0";
        _stampPaController.text = "0";
        _totalPaController.text = "0";
        _prum = 0;
        _vatt = 0;
        _stmpp = 0;
        _grandTotal = 0;
        return;
      }

      String? newRate;
      if (_classNumber == "Class-1") {
        if (_tableCode == "A") {
          newRate = "30";
        } else if (_tableCode == "B") {
          newRate = "12.5";
        } else if (_tableCode == "C") {
          newRate = "8.5";
        }
      } else if (_classNumber == "Class-2") {
        if (_tableCode == "A") {
          newRate = "40";
        } else if (_tableCode == "B") {
          newRate = "16";
        } else if (_tableCode == "C") {
          newRate = "11";
        }
      } else if (_classNumber == "Class-3") {
        if (_tableCode == "A") {
          newRate = "50";
        } else if (_tableCode == "B") {
          newRate = "21";
        } else if (_tableCode == "C") {
          newRate = "15";
        }
      }

      if (newRate != null) {
        _ratePaController.text = newRate;
        _calculatePremium(); // Recalculate premium after rate changes
      } else {
        _ratePaController.text = "0";
        _showToast("Invalid Class/Table selection for rate.");
      }
    });
  }

  // --- Date Picker Helper ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // A more reasonable first date
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent, // Header background color
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
            ), // Selected date color
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        if (isStartDate) {
          _startDate = picked;
          _startDatePaString = formattedDate;
        } else {
          _endDate = picked;
          _endDatePaString = formattedDate;
        }
      });
    }
  }

  // --- Toast Message Helper ---
  void _showToast(String message) {
    if (mounted) {
      // Ensure widget is still mounted before showing SnackBar
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

  // --- Clear Form Fields ---
  void _clearFormFields() {
    _insuredNamePaController.clear();
    _insuredAddressPaController.clear();
    _fathersNamePaController.clear();
    _nomineeAddressPaController.clear();
    _nidPaController.clear();
    _sumInsuredPaController.clear();
    _mobileController.clear();
    _emailController.clear();
    _nomineeNidsController.clear();
    _nomineeMblsController.clear();
    _nomineeEmailsController.clear();

    setState(() {
      _startDate = null;
      _endDate = null;
      _startDatePaString = null;
      _endDatePaString = null;
      _selectedRelation = _relationList.first;
      _selectedClass = _classList.isNotEmpty ? _classList.first : null;
      _selectedTable = _tableList.isNotEmpty ? _tableList.first : null;
      _classNumber = _selectedClass?.pType;
      _tableCode = _selectedTable?.pType;
      _stmpp = 0.0;
      _prum = 0;
      _vatt = 0;
      _grandTotal = 0;
      // Reset text controllers for calculated fields
      _ratePaController.text = "0";
      _premiumPaController.text = "0";
      _vatPaController.text = "0";
      _stampPaController.text = "0";
      _totalPaController.text = "0";
      _pdfFilePath = null; // Clear PDF path when form is cleared
    });
    // This will trigger rate calculation based on reset dropdowns
    _calculateResult();
  }

  // --- PDF Generation Logic ---
  Future<void> _generatePdfReport() async {
    if (_apiDataForPdf == null) {
      _showToast("No data available to generate report.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final pdf = pw.Document();

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
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
                style: pw.Theme.of(context).defaultTextStyle.copyWith(
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
              _buildPdfDetailRow('Policy ID:', _apiDataForPdf!['id'] ?? 'N/A'),
              _buildPdfDetailRow(
                'Insured Name:',
                _apiDataForPdf!['name'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Insured Address:',
                _apiDataForPdf!['address'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Sum Insured:',
                _apiDataForPdf!['amount'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Premium:',
                _apiDataForPdf!['premium'] ?? 'N/A',
              ),
              _buildPdfDetailRow('VAT:', _apiDataForPdf!['vat'] ?? 'N/A'),
              _buildPdfDetailRow('Stamp:', _apiDataForPdf!['stamp'] ?? 'N/A'),
              _buildPdfDetailRow(
                'Total Payable:',
                _apiDataForPdf!['grand_total'] ?? 'N/A',
              ),
              _buildPdfDetailRow('Rate:', _apiDataForPdf!['rate'] ?? 'N/A'),
              _buildPdfDetailRow(
                'Period From:',
                _apiDataForPdf!['period_from'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Period To:',
                _apiDataForPdf!['period_to'] ?? 'N/A',
              ),
              _buildPdfDetailRow('Class:', _apiDataForPdf!['Class'] ?? 'N/A'),
              _buildPdfDetailRow('Table:', _apiDataForPdf!['Tables'] ?? 'N/A'),

              pw.SizedBox(height: 20),
              pw.Text(
                'Contact Information',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfDetailRow('Mobile:', _apiDataForPdf!['mobile'] ?? 'N/A'),
              _buildPdfDetailRow('Email:', _apiDataForPdf!['email'] ?? 'N/A'),
              _buildPdfDetailRow(
                'Father\'s Name:',
                _apiDataForPdf!['fathers_name'] ?? 'N/A',
              ),
              _buildPdfDetailRow('NID:', _apiDataForPdf!['nid'] ?? 'N/A'),

              pw.SizedBox(height: 20),
              pw.Text(
                'Nominee Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfDetailRow(
                'Nominee Name & Address:',
                _apiDataForPdf!['nominee'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Nominee Relation:',
                _apiDataForPdf!['relation'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Nominee NID:',
                _apiDataForPdf!['nominee_nid'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Nominee Mobile:',
                _apiDataForPdf!['nominee_mbl'] ?? 'N/A',
              ),
              _buildPdfDetailRow(
                'Nominee Email:',
                _apiDataForPdf!['nominee_email'] ?? 'N/A',
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/personal_accident_report.pdf');
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _pdfFilePath = file.path; // Store the PDF path
      });

      // Show alert dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('PDF Generated!'),
              content: const Text(
                'The PDF report has been successfully saved.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _openPdf(); // Open the PDF
                  },
                  child: const Text('View PDF'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      _showToast("Error generating PDF: $e");
      print("PDF Generation Error: $e"); // Log the error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to open the PDF
  void _openPdf() {
    if (_pdfFilePath != null) {
      OpenFile.open(_pdfFilePath);
    } else {
      _showToast("PDF file path is not available.");
    }
  }

  // Helper widget for building rows in the PDF
  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Personal Accident",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Set back button color
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Insured Details Card ---
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Insured Details",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          _buildTextField(
                            _insuredNamePaController,
                            "Insured Name",
                            isRequired: true,
                          ),
                          _buildTextField(
                            _insuredAddressPaController,
                            "Insured Address",
                            isRequired: true,
                          ),
                          _buildTextField(
                            _fathersNamePaController,
                            "Father's Name",
                          ),
                          _buildTextField(
                            _mobileController,
                            "Mobile Number",
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              if (value.length < 10 || value.length > 15) {
                                return 'Enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            _emailController,
                            "Email Address",
                            keyboardType: TextInputType.emailAddress,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email address';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            _nidPaController,
                            "National ID (NID)",
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Nominee Details Card ---
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nominee Details",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          _buildTextField(
                            _nomineeAddressPaController,
                            "Nominee Beneficiary Name & Address",
                          ),
                          _buildTextField(
                            _nomineeNidsController,
                            "Nominee NID",
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            _nomineeMblsController,
                            "Nominee Mobile",
                            keyboardType: TextInputType.phone,
                          ),
                          _buildTextField(
                            _nomineeEmailsController,
                            "Nominee Email",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildDropdownField<Model>(
                            "Relation",
                            _selectedRelation,
                            _relationList,
                            (Model? newValue) {
                              setState(() {
                                _selectedRelation = newValue;
                              });
                            },
                            (value) => value == _relationList.first
                                ? 'Please select a relation'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Policy Details Card ---
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Policy Details",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          _buildDropdownField<Model>(
                            "Class",
                            _selectedClass,
                            _classList,
                            (Model? newValue) {
                              setState(() {
                                _selectedClass = newValue;
                                _classNumber = newValue?.pType;
                                _className = newValue?.name;
                                _calculateResult(); // Recalculate rate and premium
                              });
                            },
                            (value) => value == null || value.pType.isEmpty
                                ? 'Please select a class'
                                : null,
                          ),
                          _buildDropdownField<Model>(
                            "Table",
                            _selectedTable,
                            _tableList,
                            (Model? newValue) {
                              setState(() {
                                _selectedTable = newValue;
                                _tableCode = newValue?.pType;
                                _tableName = newValue?.name;
                                _calculateResult(); // Recalculate rate and premium
                              });
                            },
                            (value) => value == null || value.pType.isEmpty
                                ? 'Please select a table'
                                : null,
                          ),
                          _buildDateField(
                            "Start Date",
                            _startDatePaString,
                            () => _selectDate(context, true),
                            isRequired: true,
                          ),
                          _buildDateField(
                            "End Date",
                            _endDatePaString,
                            () => _selectDate(context, false),
                            isRequired: true,
                          ),
                          _buildTextField(
                            _sumInsuredPaController,
                            "Sum Insured",
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter sum insured';
                              }
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return 'Enter a valid positive number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _calculatePremium(); // Recalculate on sum insured change
                            },
                          ),
                          _buildReadOnlyTextField(_ratePaController, "Rate"),
                          _buildReadOnlyTextField(
                            _premiumPaController,
                            "Premium",
                          ),
                          _buildReadOnlyTextField(_vatPaController, "VAT"),
                          _buildReadOnlyTextField(_stampPaController, "Stamp"),
                          _buildReadOnlyTextField(_totalPaController, "Total"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, // Make button fill width
                    child: ElevatedButton.icon(
                      onPressed: _calculatePremium,
                      icon: const Icon(Icons.calculate),
                      label: const Text("CALCULATE"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitPa,
                      icon: const Icon(Icons.send),
                      label: const Text("SUBMIT"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Conditionally show the PDF download button
                  if (_pdfFilePath != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _openPdf, // Calls the function to open the PDF
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("VIEW PDF"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24), // Add some bottom padding
                ],
              ),
            ),
          ),
          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),
        ],
      ),
    );
  }

  // --- Reusable Widget Builders for Cleaner Code ---

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 12.0,
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $labelText';
                }
                return validator?.call(
                  value,
                ); // Call additional validator if provided
              }
            : validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildReadOnlyTextField(
    TextEditingController controller,
    String labelText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          filled: true,
          fillColor:
              Colors.grey[100], // Light gray background for read-only fields
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>(
    String labelText,
    T? selectedValue,
    List<T> items,
    ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 12.0,
          ),
        ),
        value: selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text((item as Model).name), // Assuming items are Model type
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField(
    String labelText,
    String? dateString,
    VoidCallback onTap, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(text: dateString),
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 12.0,
          ),
        ),
        onTap: onTap,
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select $labelText';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
