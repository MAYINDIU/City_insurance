// lib/screens/personal_accident.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io'; // For SocketException (network)
import 'package:connectivity_plus/connectivity_plus.dart'; // Cross-platform network check

import 'package:cityinsurance/screens/pdf_viewer_page.dart';

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
  final TextEditingController _insuredNamePaController = TextEditingController();
  final TextEditingController _insuredAddressPaController = TextEditingController();
  final TextEditingController _fathersNamePaController = TextEditingController();
  final TextEditingController _nomineeAddressPaController = TextEditingController();
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
  final TextEditingController _nomineeEmailsController = TextEditingController();

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
    Model("Select Class", ""), // Default/Hint item, populated by API
  ];
  Model? _selectedClass;
  String? _classNumber; // Corresponds to 'CODE'
  String? _className; // Corresponds to 'NAME'

  List<Model> _tableList = [
    Model("Select Table", ""), // Default/Hint item, populated by API
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

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // This will temporarily hold API data before navigating
  Map<String, dynamic>? _apiDataForPdf;

  @override
  void initState() {
    super.initState();
    _selectedRelation = _relationList.first; // Initialize selected relation
    // Initialize calculated text fields to "0"
    _ratePaController.text = "0";
    _premiumPaController.text = "0";
    _vatPaController.text = "0";
    _stampPaController.text = "0";
    _totalPaController.text = "0";

    // Fetch dropdown data on initialization
    _fetchClassList();
    _fetchTableList();
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks
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

  // --- Network Check (Recommended for cross-platform) ---
  Future<bool> _isConnected() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.vpn)) {
      return true; // Connected via mobile data, wifi, ethernet, or VPN
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return false; // No internet connection
    }
    return false; // Fallback for other states, assuming no connection
  }

  // --- API Calls ---
  Future<void> _fetchClassList() async {
    setState(() {
      _isLoading = true;
    });
    const urlString = "https://cityinsurancedigital.com.bd/demo/api_apps/omp/classlist.php";
    final url = Uri.parse(urlString);

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
            // Update _classNumber and _className if a default is set
            _classNumber = _selectedClass?.pType;
            _className = _selectedClass?.name;
            _calculateResult(); // Recalculate rate based on initial selection
          });
        } else {
          _showToast("Failed to fetch class data: ${jsonResponse['message']}");
        }
      } else {
        _showToast("Server error fetching classes: ${response.statusCode}");
      }
    } catch (e) {
      _showToast("Network error fetching classes: $e");
      print("Error fetching class list: $e"); // For debugging
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
    const urlString = "https://cityinsurancedigital.com.bd/demo/api_apps/omp/tablelist.php";
    final url = Uri.parse(urlString);

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
            // Update _tableCode and _tableName if a default is set
            _tableCode = _selectedTable?.pType;
            _tableName = _selectedTable?.name;
            _calculateResult(); // Recalculate rate based on initial selection
          });
        } else {
          _showToast("Failed to fetch table data: ${jsonResponse['message']}");
        }
      } else {
        _showToast("Server error fetching tables: ${response.statusCode}");
      }
    } catch (e) {
      _showToast("Network error fetching tables: $e");
      print("Error fetching table list: $e"); // For debugging
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPa() async {
    if (!await _isConnected()) {
      _showToast("No internet connection. Please check your connection.");
      return;
    }

    // Validate all required fields using the form key
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      const apiUrlString = "https://cityinsurancedigital.com.bd/demo/api_apps/personal/insert_personal_datas.php";
      final apiUrl = Uri.parse(apiUrlString);

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

          if (jsonResponse['success'] == true) {
            _apiDataForPdf = jsonResponse['data']; // Assign data here

            _showToast("Personal data saved successfully!");
            _clearFormFields(); // Clear original form fields

            // --- NAVIGATE TO PDF VIEWER PAGE ---
            if (_apiDataForPdf != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerPage(
                    apiData: _apiDataForPdf!, // Pass the data to the new page
                  ),
                ),
              );
            } else {
              _showToast("Error: No data received for PDF generation.");
            }
          } else {
            _showToast(
              "Failed to save personal data: ${jsonResponse['message'] ?? 'Unknown error'}",
            );
          }
        } else {
          _showToast(
            "Server error on personal data save: ${response.statusCode}",
          );
        }
      } catch (e) {
        String errorMsg = "An unexpected error occurred.";
        if (e is http.ClientException && e.message.contains("timed out")) {
          errorMsg = "Request timed out. Please try again.";
        } else if (e is SocketException) {
          errorMsg = "No internet connection. Please check your network.";
        } else if (e is FormatException) {
          errorMsg = "Invalid response from server. Data format error.";
        }
        _showToast(errorMsg);
        print("API Error during submission: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showToast("Please correct the errors in the form.");
    }
  }

  // --- Calculation Logic ---
  void _calculatePremium() {
    final sumValueText = _sumInsuredPaController.text;
    final rateText = _ratePaController.text;

    // Reset all calculated fields if inputs are empty or invalid
    if (sumValueText.isEmpty ||
        rateText.isEmpty ||
        double.tryParse(sumValueText) == null ||
        double.tryParse(sumValueText)! <= 0) {
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

    double sumValue = double.parse(sumValueText);
    double rate = double.parse(rateText);

    setState(() {
      // Calculate Premium: (Sum Insured / 10000) * Rate
      _prum = (sumValue / 10000 * rate).round();
      _premiumPaController.text = NumberFormat('#,##0').format(_prum);

      // Calculate VAT: Premium * 15% (rounded up)
      _vatt = (_prum * 0.15).ceil();
      _vatPaController.text = NumberFormat('#,##0').format(_vatt);

      // Calculate Stamp Duty:
      _stmpp = 0.0;
      if (sumValue >= 25000) {
        _stmpp = 20.0; // Base stamp for 25000
        double additionalAmount = sumValue - 25000;
        // Add 20 for every additional 5000 or part thereof (use ceil for partials)
        int additionalUnits = (additionalAmount / 5000).ceil();
        _stmpp += additionalUnits * 20;
      } else if (sumValue > 0 && sumValue < 25000) {
        // Example: assuming a fixed stamp for smaller sums
        _stmpp = 10.0; // Adjust this as per your business logic
      }
      _stampPaController.text = NumberFormat('#,##0').format(_stmpp.round());

      // Calculate Grand Total
      _grandTotal = (_prum + _vatt + _stmpp).round();
      _totalPaController.text = NumberFormat('#,##0').format(_grandTotal);
    });
  }

  void _calculateResult() {
    setState(() {
      // If no valid class or table is selected, reset rate and other fields
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
      // Determine rate based on selected class and table
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
        // If no matching rate is found, reset rate and calculated fields
        _ratePaController.text = "0";
        _premiumPaController.text = "0";
        _vatPaController.text = "0";
        _stampPaController.text = "0";
        _totalPaController.text = "0";
        _prum = 0;
        _vatt = 0;
        _stmpp = 0;
        _grandTotal = 0;
        _showToast("No rate found for the selected Class/Table combination.");
      }
    });
  }

  // --- Date Picker Helper ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent, // Header background color
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent, // Selected date color
            ),
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
      // Re-initialize class and table to their "Select" options
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
      // No need to clear _apiDataForPdf or _pdfFilePath here anymore
    });
    // This will trigger rate calculation based on reset dropdowns
    _calculateResult();
  }

  // Helper method for building text input fields
  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    bool isRequired = false,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: isRequired ? '$labelText *' : labelText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $labelText';
          }
          return validator?.call(value);
        },
        onChanged: onChanged,
      ),
    );
  }

  // Helper method for building dropdown fields
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
        value: selectedValue,
        decoration: InputDecoration(
          labelText: '$labelText *',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item is Model ? item.name : item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
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
                              // Basic check for common mobile number lengths
                              if (value.length < 6 || value.length > 15) {
                                return 'Enter a valid mobile number (e.g., 10-15 digits)';
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
                              // A simple regex for email validation
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
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
                          _buildDropdownField<Model>(
                            "Relation",
                            _selectedRelation,
                            _relationList,
                            (newValue) {
                              setState(() {
                                _selectedRelation = newValue;
                              });
                            },
                            (value) {
                              if (value == null || value.pType == "") {
                                return 'Please select relation';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            _nomineeAddressPaController,
                            "Nominee Name & Address",
                            isRequired: true,
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
                            (newValue) {
                              setState(() {
                                _selectedClass = newValue;
                                _classNumber = newValue?.pType;
                                _className = newValue?.name;
                                _calculateResult(); // Recalculate based on new class
                              });
                            },
                            (value) {
                              if (value == null || value.pType == "") {
                                return 'Please select class';
                              }
                              return null;
                            },
                          ),
                          _buildDropdownField<Model>(
                            "Table",
                            _selectedTable,
                            _tableList,
                            (newValue) {
                              setState(() {
                                _selectedTable = newValue;
                                _tableCode = newValue?.pType;
                                _tableName = newValue?.name;
                                _calculateResult(); // Recalculate based on new table
                              });
                            },
                            (value) {
                              if (value == null || value.pType == "") {
                                return 'Please select table';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            _sumInsuredPaController,
                            "Sum Insured",
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            onChanged: (value) =>
                                _calculatePremium(), // Recalculate on sum insured change
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Sum Insured';
                              }
                              if (double.tryParse(value) == null ||
                                  double.tryParse(value)! <= 0) {
                                return 'Enter a valid positive amount';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            _ratePaController,
                            "Rate",
                            readOnly: true,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            _premiumPaController,
                            "Premium",
                            readOnly: true,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            _vatPaController,
                            "VAT",
                            readOnly: true,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            _stampPaController,
                            "Stamp",
                            readOnly: true,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            _totalPaController,
                            "Total Payable",
                            readOnly: true,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            TextEditingController(text: _startDatePaString),
                            "Period From",
                            readOnly: true,
                            isRequired: true,
                            onTap: () => _selectDate(context, true),
                            validator: (value) {
                              if (_startDatePaString == null ||
                                  _startDatePaString!.isEmpty) {
                                return 'Please select start date';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            TextEditingController(text: _endDatePaString),
                            "Period To",
                            readOnly: true,
                            isRequired: true,
                            onTap: () => _selectDate(context, false),
                            validator: (value) {
                              if (_endDatePaString == null ||
                                  _endDatePaString!.isEmpty) {
                                return 'Please select end date';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitPa,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        _isLoading ? 'Submitting...' : 'Submit Policy',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _clearFormFields,
                      icon: const Icon(Icons.clear, color: Colors.blueAccent),
                      label: const Text(
                        'Clear Form',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading) // Overlay for loading indicator
            Container(
              color: Colors.black.withOpacity(0.5),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}