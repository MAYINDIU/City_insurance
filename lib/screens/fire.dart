import 'dart:convert'; // For encoding/decoding JSON
import 'package:flutter/material.dart'; // For Flutter UI widgets
import 'package:http/http.dart' as http; // For making HTTP requests. Add 'http: ^latest_version' to pubspec.yaml
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use 'pw' for pdf widgets to avoid conflict with flutter widgets
import 'package:path_provider/path_provider.dart'; // For temporary directory
import 'package:open_filex/open_filex.dart'; // For opening the file
import 'package:permission_handler/permission_handler.dart'; // For permissions
import 'dart:io'; // Add this line


class FirecompleteScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const FirecompleteScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Policy Details'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎉 Data Submitted Successfully!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text('Here are the submitted details:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),

              ...data.entries.map((entry) {
                String displayLabel = _formatKeyForDisplay(entry.key);
                return _buildDetailRow(displayLabel, entry.value);
              }).toList(),

              const SizedBox(height: 30),
              Center(
                child: Column( // Use a Column to stack buttons
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _generateAndSavePdf(context), // Call the PDF generation function
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Download PDF', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // A distinct color for PDF
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 15), // Spacing between buttons
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Go Back to Form'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget and format method remain the same as before
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          children: <TextSpan>[
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  String _formatKeyForDisplay(String key) {
    // ... (Your existing _formatKeyForDisplay logic here, as provided previously)
    switch (key) {
      case 'CLNAME': return 'Client Name';
      case 'CLADDRESS': return 'Client Address';
      case 'TRADEOFPROF': return 'Trade/Profession';
      case 'PARTNERNAME': return 'Partner/Bank Name';
      case 'PERIODFROM': return 'Period From';
      case 'PERIODTO': return 'Period To';
      case 'CYCLON': return 'Cyclone Covered';
      case 'RIOT': return 'Riot Covered';
      case 'MALICIUS': return 'Malicious Damage Covered';
      case 'EARTHQUEAKE': return 'Earthquake Covered';
      case 'ELETRICAL': return 'Electrical Covered';
      case 'FLOOD_STOCK': return 'Flood (Stock) Covered';
      case 'EXPLOSION': return 'Explosion Covered';
      case 'AIRCRAFT': return 'Aircraft Damage Covered';
      case 'CYCLONEBM': return 'Cyclone (B/M) Covered';
      case 'IMPACTDAMAGE': return 'Impact Damage Covered';
      case 'LANDSLIDE': return 'Landslide Covered';
      case 'CYCLNOESTOCK': return 'Cyclone (Stock) Covered';
      case 'bursting_of_pipess': return 'Bursting of Pipes Covered';
      case 'TSUNAMI': return 'Tsunami Covered';
      case 'FIRETINGING': return 'Fire & Lightning Covered';
      case 'DESCRIPTION1': return 'Description 1';
      case 'AMOUNT1': return 'Amount 1';
      case 'DESCRIPTION2': return 'Description 2';
      case 'AMOUNT2': return 'Amount 2';
      case 'DESCRIPTION3': return 'Description 3';
      case 'AMOUNT3': return 'Amount 3';
      case 'DESCRIPTION4': return 'Description 4';
      case 'AMOUNT4': return 'Amount 4';
      case 'DESCRIPTION5': return 'Description 5';
      case 'AMOUNT5': return 'Amount 5';
      case 'DESCRIPTION6': return 'Description 6';
      case 'AMOUNT6': return 'Amount 6';
      case 'DESCRIPTION7': return 'Description 7';
      case 'AMOUNT7': return 'Amount 7';
      case 'DESCRIPTION8': return 'Description 8';
      case 'AMOUNT8': return 'Amount 8';
      case 'NAMEOFBUILDING': return 'Name of Building';
      case 'OWNEROFBUILDING': return 'Owner of Building';
      case 'OCUPATIONOFADJ': return 'Occupation of Adjoining Building';
      case 'PLOTNO': return 'Plot/Holding No.';
      case 'STREET': return 'Street';
      case 'TOWN': return 'Town/District';
      case 'NUMBEROFSTORES': return 'Number of Stories';
      case 'CONSTRUCTION': return 'Construction Type';
      case 'OCCUPATOINOFBUILD': return 'Occupation of Building';
      case 'DIAGRAMATTACHED': return 'Diagram Attached';
      case 'NEARESTFIREBRIGADE': return 'Nearest Fire Brigade';
      case 'BANKERNAME': return 'Banker Name';
      case 'CARRIEDBUSS': return 'Business Carried On This Building';
      case 'OTHERPOWER': return 'Power Used in The Building';
      case 'ISLIGHTED': return 'How Building is Lighted';
      case 'ASSISTANCECASE': return 'Assistance in Case of Fire';
      case 'm_status': return 'Submission Status';
      case 'from_apps': return 'Source (App)';
      case 'INTEREST_INSURED': return 'Interest in Insured Property';
      case 'email': return 'Email';
      case 'mobile': return 'Mobile';
      case 'FLD_BM': return 'Flood (Building/Machinery) Covered';
      default:
        String formatted = key.replaceAll('_', ' ').replaceAll('-', ' ');
        return formatted.split(' ').map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '').join(' ');
    }
  }


  // --- New PDF Generation Method ---
  Future<void> _generateAndSavePdf(BuildContext context) async {
    // Request storage permission first (especially for Android)
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied. Cannot save PDF.')),
      );
      return;
    }

    final pdf = pw.Document();

    // Load a font that supports a wider range of characters if needed
    // For simplicity, we'll use a default font provided by pdf package.
    // If you need specific fonts (e.g., for non-Latin characters), you'd load them like this:
    // final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    // final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Fire Insurance Policy Details',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Submitted Details:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              // Use a Table for structured data presentation in PDF
              pw.Table.fromTextArray(
                headers: ['Field', 'Value'],
                data: data.entries.map((entry) {
                  return [_formatKeyForDisplay(entry.key), entry.value?.toString() ?? 'N/A'];
                }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2), // Field column wider
                  1: const pw.FlexColumnWidth(3), // Value column even wider
                },
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateTime.now().toLocal().toIso8601String().split('T')[0]}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Get the application's temporary directory
    final output = await getTemporaryDirectory();
    final fileName = 'fire_policy_details_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');

    // Write the PDF file
    await file.writeAsBytes(await pdf.save());

    // Show a success message and offer to open the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to ${file.path}'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            OpenFilex.open(file.path);
          },
        ),
      ),
    );

    debugPrint('PDF saved at: ${file.path}');
  }
}

/// The main screen containing the fire insurance application form.
class FireInsuranceFormScreen extends StatefulWidget {
  const FireInsuranceFormScreen({Key? key}) : super(key: key);

  @override
  State<FireInsuranceFormScreen> createState() => _FireInsuranceFormScreenState();
}

class _FireInsuranceFormScreenState extends State<FireInsuranceFormScreen> {
  // --- Text Controllers for Input Fields ---
  final TextEditingController _nameOfProposerController = TextEditingController();
  final TextEditingController _addressOfProposerController = TextEditingController();
  final TextEditingController _bankAddressController = TextEditingController();
  final TextEditingController _tradeOfProfessionController = TextEditingController();
  final TextEditingController _description1Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _description2Controller = TextEditingController();
  final TextEditingController _description3Controller = TextEditingController();
  final TextEditingController _description4Controller = TextEditingController();
  final TextEditingController _description5Controller = TextEditingController();
  final TextEditingController _description6Controller = TextEditingController();
  final TextEditingController _description7Controller = TextEditingController();
  final TextEditingController _description8Controller = TextEditingController();
  final TextEditingController _amount1Controller = TextEditingController();
  final TextEditingController _amount2Controller = TextEditingController();
  final TextEditingController _amount3Controller = TextEditingController();
  final TextEditingController _amount4Controller = TextEditingController();
  final TextEditingController _amount5Controller = TextEditingController();
  final TextEditingController _amount6Controller = TextEditingController();
  final TextEditingController _amount7Controller = TextEditingController();
  final TextEditingController _amount8Controller = TextEditingController();
  final TextEditingController _nameOfBuildingController = TextEditingController();
  final TextEditingController _ownerOfBuildingController = TextEditingController();
  final TextEditingController _occupationAdjoiningBuildingController = TextEditingController();
  final TextEditingController _flotHoldingNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _townDistrictController = TextEditingController();
  final TextEditingController _numberOfStoreController = TextEditingController();
  final TextEditingController _occupationOfBuildingController = TextEditingController();
  final TextEditingController _diagramController = TextEditingController(); // Assuming text input like "Attached"
  final TextEditingController _fireBridgeController = TextEditingController();
  final TextEditingController _nameBankController = TextEditingController();
  final TextEditingController _carriedOnThisBusinessController = TextEditingController();
  final TextEditingController _powerUsedInTheBuildingController = TextEditingController();
  final TextEditingController _buildingLightedController = TextEditingController();
  final TextEditingController _whatAssistanceController = TextEditingController();
  final TextEditingController _interestInsuredController = TextEditingController();

  // --- Boolean Variables for Checkboxes/Coverages ---
  bool _isCyclonCovered = false;
  bool _isRiotCovered = false;
  bool _isMaliciousCovered = false;
  bool _isEarthquakeCovered = false;
  bool _isElectricalCovered = false;
  bool _isFloodStockCovered = false;
  bool _isExplosionCovered = false;
  bool _isAircraftCovered = false;
  bool _isCycloneBNCovered = false; // Cyclone Building/Machinery
  bool _isImpactDamageCovered = false;
  bool _isLandslideCovered = false;
  bool _isCycloneStockCovered = false;
  bool _isBurstingOfPipesCovered = false;
  bool _isTsunamiCovered = false;
  bool _isFireTingingCovered = false; // Assuming 'Fire & Lightning' from Java
  bool _isFloodBMCovered = false; // Flood Building/Machinery

  // --- Date Variables for Period From/To ---
  DateTime? _periodFromDate;
  DateTime? _periodToDate;

  // --- Dropdown for Construction Type ---
  String? _constructionData;
  final List<String> _constructionOptions = ['Brick', 'Concrete', 'Wood', 'Steel', 'Other'];

  // --- GlobalKey for Form Validation ---
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // It's crucial to dispose of all TextEditingControllers to prevent memory leaks.
    _nameOfProposerController.dispose();
    _addressOfProposerController.dispose();
    _bankAddressController.dispose();
    _tradeOfProfessionController.dispose();
    _description1Controller.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _description2Controller.dispose();
    _description3Controller.dispose();
    _description4Controller.dispose();
    _description5Controller.dispose();
    _description6Controller.dispose();
    _description7Controller.dispose();
    _description8Controller.dispose();
    _amount1Controller.dispose();
    _amount2Controller.dispose();
    _amount3Controller.dispose();
    _amount4Controller.dispose();
    _amount5Controller.dispose();
    _amount6Controller.dispose();
    _amount7Controller.dispose();
    _amount8Controller.dispose();
    _nameOfBuildingController.dispose();
    _ownerOfBuildingController.dispose();
    _occupationAdjoiningBuildingController.dispose();
    _flotHoldingNoController.dispose();
    _streetController.dispose();
    _townDistrictController.dispose();
    _numberOfStoreController.dispose();
    _occupationOfBuildingController.dispose();
    _diagramController.dispose();
    _fireBridgeController.dispose();
    _nameBankController.dispose();
    _carriedOnThisBusinessController.dispose();
    _powerUsedInTheBuildingController.dispose();
    _buildingLightedController.dispose();
    _whatAssistanceController.dispose();
    _interestInsuredController.dispose();
    super.dispose();
  }

  /// Helper function to show a date picker and update the selected date.
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      helpText: isFromDate ? 'Select Start Date' : 'Select End Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _periodFromDate = picked;
        } else {
          _periodToDate = picked;
        }
      });
    }
  }

  /// The main function to collect data and send it to the API.
  Future<void> _submitFireData() async {
    // Validate all form fields before proceeding
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please fill in all required fields correctly.", Colors.red);
      return;
    }

    // --- 1. Get dynamic data from the form fields ---
    final String clname = _nameOfProposerController.text.trim();
    final String claddress = _addressOfProposerController.text.trim();
    final String bankAddress = _bankAddressController.text.trim();
    final String tradeProfession = _tradeOfProfessionController.text.trim();
    final String desc1 = _description1Controller.text.trim();
    final String emails = _emailController.text.trim();
    final String mobiles = _mobileController.text.trim();
    final String desc2 = _description2Controller.text.trim();
    final String desc3 = _description3Controller.text.trim();
    final String desc4 = _description4Controller.text.trim();
    final String desc5 = _description5Controller.text.trim();
    final String desc6 = _description6Controller.text.trim();
    final String desc7 = _description7Controller.text.trim();
    final String desc8 = _description8Controller.text.trim();
    final String amt1 = _amount1Controller.text.trim();
    final String amt2 = _amount2Controller.text.trim();
    final String amt3 = _amount3Controller.text.trim();
    final String amt4 = _amount4Controller.text.trim();
    final String amt5 = _amount5Controller.text.trim();
    final String amt6 = _amount6Controller.text.trim();
    final String amt7 = _amount7Controller.text.trim();
    final String amt8 = _amount8Controller.text.trim();
    final String nameBuilding = _nameOfBuildingController.text.trim();
    final String ownerBuilding = _ownerOfBuildingController.text.trim();
    final String occupationAdj = _occupationAdjoiningBuildingController.text.trim();
    final String flotHolding = _flotHoldingNoController.text.trim();
    final String streett = _streetController.text.trim();
    final String townDistrict = _townDistrictController.text.trim();
    final String nmbrStore = _numberOfStoreController.text.trim();
    final String constructionn = _constructionData ?? ''; // Use selected value from dropdown
    final String occupationBuilding = _occupationOfBuildingController.text.trim();
    final String dgrm = _diagramController.text.trim();
    final String bridge = _fireBridgeController.text.trim();
    final String nameBank = _nameBankController.text.trim();
    final String carried = _carriedOnThisBusinessController.text.trim();
    final String power = _powerUsedInTheBuildingController.text.trim();
    final String bLighted = _buildingLightedController.text.trim();
    final String assistance = _whatAssistanceController.text.trim();
    final String interestIn = _interestInsuredController.text.trim();

    // Convert boolean flags to "Yes" or "" as per API expectation
    final String cyclon = _isCyclonCovered ? "Yes" : "";
    final String riot = _isRiotCovered ? "Yes" : "";
    final String malicious = _isMaliciousCovered ? "Yes" : "";
    final String earthquake = _isEarthquakeCovered ? "Yes" : "";
    final String electrical = _isElectricalCovered ? "Yes" : "";
    final String floodStock = _isFloodStockCovered ? "Yes" : "";
    final String explosion = _isExplosionCovered ? "Yes" : "";
    final String aircraft = _isAircraftCovered ? "Yes" : "";
    final String cycloneBM = _isCycloneBNCovered ? "Yes" : "";
    final String impactDamage = _isImpactDamageCovered ? "Yes" : "";
    final String landslide = _isLandslideCovered ? "Yes" : "";
    final String cycloneStock = _isCycloneStockCovered ? "Yes" : "";
    final String burstingOfPipes = _isBurstingOfPipesCovered ? "Yes" : "";
    final String tsunami = _isTsunamiCovered ? "Yes" : "";
    final String fireTinging = _isFireTingingCovered ? "Yes" : "";
    final String floodBM = _isFloodBMCovered ? "Yes" : "";

    // Format dates to YYYY-MM-DD for the API
    final String periodFrom = _periodFromDate != null
        ? "${_periodFromDate!.year}-${_periodFromDate!.month.toString().padLeft(2, '0')}-${_periodFromDate!.day.toString().padLeft(2, '0')}"
        : "";
    final String periodTo = _periodToDate != null
        ? "${_periodToDate!.year}-${_periodToDate!.month.toString().padLeft(2, '0')}-${_periodToDate!.day.toString().padLeft(2, '0')}"
        : "";

    // --- 2. Show a loading indicator (Progress Dialog) ---
    showDialog(
      context: context,
      barrierDismissible: false, // User must wait for dialog to be dismissed
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
    );

    // --- 3. API Endpoint URL ---
    const String url = "https://cityinsurancedigital.com.bd/demo/api_apps/fire/fire_insert.php";

    try {
      // --- 4. Prepare the POST request body as a Map<String, String> ---
      final response = await http.post(
        Uri.parse(url),
        body: {
          "CLNAME": clname,
          "CLADDRESS": claddress,
          "PARTNERNAME": bankAddress,
          "TRADEOFPROF": tradeProfession,
          "PERIODFROM": periodFrom,
          "PERIODTO": periodTo,
          "CYCLON": cyclon,
          "RIOT": riot,
          "MALICIUS": malicious,
          "EARTHQUEAKE": earthquake,
          "ELETRICAL": electrical,
          "FLOOD_STOCK": floodStock,
          "EXPLOSION": explosion,
          "AIRCRAFT": aircraft,
          "CYCLONEBM": cycloneBM,
          "IMPACTDAMAGE": impactDamage,
          "LANDSLIDE": landslide,
          "CYCLNOESTOCK": cycloneStock,
          "bursting_of_pipess": burstingOfPipes, // Note the double 's' based on your Java code
          "TSUNAMI": tsunami,
          "FIRETINGING": fireTinging,
          "DESCRIPTION1": desc1,
          "AMOUNT1": amt1,
          "DESCRIPTION2": desc2,
          "DESCRIPTION3": desc3,
          "AMOUNT2": amt2,
          "AMOUNT3": amt3,
          "AMOUNT4": amt4,
          "DESCRIPTION4": desc4,
          "DESCRIPTION5": desc5,
          "DESCRIPTION6": desc6,
          "DESCRIPTION7": desc7,
          "AMOUNT5": amt5,
          "AMOUNT6": amt6,
          "AMOUNT7": amt7,
          "NAMEOFBUILDING": nameBuilding,
          "OWNEROFBUILDING": ownerBuilding,
          "OCUPATIONOFADJ": occupationAdj,
          "PLOTNO": flotHolding,
          "STREET": streett,
          "TOWN": townDistrict,
          "NUMBEROFSTORES": nmbrStore,
          "CONSTRUCTION": constructionn,
          "OCCUPATOINOFBUILD": occupationBuilding,
          "DIAGRAMATTACHED": "Yes", // Hardcoded as per your Java example
          "NEARESTFIREBRIGADE": bridge,
          "BANKERNAME": nameBank,
          "CARRIEDBUSS": carried,
          "OTHERPOWER": power,
          "ISLIGHTED": bLighted,
          "ASSISTANCECASE": assistance,
          "m_status": "Active", // Hardcoded as per your Java example
          "from_apps": "apps", // Hardcoded as per your Java example
          "INTEREST_INSURED": interestIn,
          "email": emails,
          "mobile": mobiles,
          "FLD_BM": floodBM,
        },
      );

      // --- 5. Dismiss the loading indicator ---
      Navigator.of(context).pop();

      // --- 6. Handle the API Response ---
      if (response.statusCode == 200) {
        // Successfully received a response from the server
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final String status = jsonResponse["status"];

        if (status == "success") {
          // Data successfully saved on the server
          _showSnackBar("Application Submitted Successfully! ✅", Colors.green);
          final Map<String, dynamic> responseData = jsonResponse["data"];
          // Navigate to the success screen, passing the received data
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FirecompleteScreen(data: responseData),
            ),
          );
        } else {
          // Server returned a 'fail' status
          final String message = jsonResponse["message"] ?? "Failed to save data.";
          _showSnackBar("Submission Failed: $message ❌", Colors.red);
          debugPrint("API Error Message: $message");
        }
      } else {
        // Server returned an HTTP error code (e.g., 404, 500)
        _showSnackBar("Server Error: ${response.statusCode} ⚠️", Colors.orange);
        debugPrint("HTTP Error: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      // --- 7. Handle network or other unexpected errors ---
      Navigator.of(context).pop(); // Dismiss loading indicator on error
      _showSnackBar("Network Error: Could not connect to server. 🌐", Colors.red);
      debugPrint("Caught Error: $e");
    }
  }

  /// Helper function to show a SnackBar message.
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Insurance Application'),
        backgroundColor: Colors.redAccent,
        elevation: 4,
      ),
      body: Form(
        key: _formKey, // Associate the GlobalKey with the Form
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Proposer Details Section ---
                _buildSectionHeader('Proposer Details 🧑‍💼'),
                _buildTextField(_nameOfProposerController, 'Name of Proposer', required: true),
                _buildTextField(_addressOfProposerController, 'Address of Proposer', required: true),
                _buildTextField(_bankAddressController, 'Bank Address', required: true),
                _buildTextField(_tradeOfProfessionController, 'Trade/Profession', required: true),
                _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                }),
                _buildTextField(_mobileController, 'Mobile', keyboardType: TextInputType.phone),
                const SizedBox(height: 20),

                // --- Period of Insurance Section ---
                _buildSectionHeader('Period of Insurance 🗓️'),
                _buildDatePickerField('Period From', _periodFromDate, () => _selectDate(context, true), required: true),
                _buildDatePickerField('Period To', _periodToDate, () => _selectDate(context, false), required: true),
                const SizedBox(height: 20),

                // --- Coverages Section ---
                _buildSectionHeader('Select Coverages 🔥'),
                _buildCheckboxListTile('Fire & Lightning', _isFireTingingCovered, (val) => setState(() => _isFireTingingCovered = val!)),
                _buildCheckboxListTile('Cyclone (Stock)', _isCycloneStockCovered, (val) => setState(() => _isCycloneStockCovered = val!)),
                _buildCheckboxListTile('Cyclone (Building/Machinery)', _isCycloneBNCovered, (val) => setState(() => _isCycloneBNCovered = val!)),
                _buildCheckboxListTile('Riot, Strike, Malicious Damage', _isRiotCovered, (val) => setState(() => _isRiotCovered = val!)),
                _buildCheckboxListTile('Malicious Damage', _isMaliciousCovered, (val) => setState(() => _isMaliciousCovered = val!)),
                _buildCheckboxListTile('Earthquake', _isEarthquakeCovered, (val) => setState(() => _isEarthquakeCovered = val!)),
                _buildCheckboxListTile('Electrical Damage', _isElectricalCovered, (val) => setState(() => _isElectricalCovered = val!)),
                _buildCheckboxListTile('Flood (Stock)', _isFloodStockCovered, (val) => setState(() => _isFloodStockCovered = val!)),
                _buildCheckboxListTile('Flood (Building/Machinery)', _isFloodBMCovered, (val) => setState(() => _isFloodBMCovered = val!)),
                _buildCheckboxListTile('Explosion', _isExplosionCovered, (val) => setState(() => _isExplosionCovered = val!)),
                _buildCheckboxListTile('Aircraft Damage', _isAircraftCovered, (val) => setState(() => _isAircraftCovered = val!)),
                _buildCheckboxListTile('Impact Damage', _isImpactDamageCovered, (val) => setState(() => _isImpactDamageCovered = val!)),
                _buildCheckboxListTile('Landslide/Subsidence', _isLandslideCovered, (val) => setState(() => _isLandslideCovered = val!)),
                _buildCheckboxListTile('Bursting of Pipes', _isBurstingOfPipesCovered, (val) => setState(() => _isBurstingOfPipesCovered = val!)),
                _buildCheckboxListTile('Tsunami', _isTsunamiCovered, (val) => setState(() => _isTsunamiCovered = val!)),
                const SizedBox(height: 20),

                // --- Insured Items/Amounts Section ---
                _buildSectionHeader('Insured Items & Amounts 💰'),
                _buildDescriptionAmountRow(_description1Controller, _amount1Controller, 'Item 1 (e.g., Building)'),
                _buildDescriptionAmountRow(_description2Controller, _amount2Controller, 'Item 2 (e.g., Machinery)'),
                _buildDescriptionAmountRow(_description3Controller, _amount3Controller, 'Item 3 (e.g., Stock)'),
                _buildDescriptionAmountRow(_description4Controller, _amount4Controller, 'Item 4'),
                _buildDescriptionAmountRow(_description5Controller, _amount5Controller, 'Item 5'),
                _buildDescriptionAmountRow(_description6Controller, _amount6Controller, 'Item 6'),
                _buildDescriptionAmountRow(_description7Controller, _amount7Controller, 'Item 7'),
                _buildDescriptionAmountRow(_description8Controller, _amount8Controller, 'Item 8'),
                _buildTextField(_interestInsuredController, 'Interest in Insured Property'),
                const SizedBox(height: 20),

                // --- Building Details Section ---
                _buildSectionHeader('Building Details 🏢'),
                _buildTextField(_nameOfBuildingController, 'Name of Building'),
                _buildTextField(_ownerOfBuildingController, 'Owner of Building'),
                _buildTextField(_occupationAdjoiningBuildingController, 'Occupation of Adjoining Building'),
                _buildTextField(_flotHoldingNoController, 'Plot/Holding No.'),
                _buildTextField(_streetController, 'Street'),
                _buildTextField(_townDistrictController, 'Town/District'),
                _buildTextField(_numberOfStoreController, 'Number of Stories', keyboardType: TextInputType.number),
                _buildDropdownField('Type of Construction', _constructionOptions, _constructionData, (String? newValue) {
                  setState(() {
                    _constructionData = newValue;
                  });
                }),
                _buildTextField(_occupationOfBuildingController, 'Occupation of Building'),
                _buildTextField(_diagramController, 'Diagram Attached (e.g., Yes/No/N/A)'),
                _buildTextField(_fireBridgeController, 'Nearest Fire Brigade'),
                const SizedBox(height: 20),

                // --- Business & Other Information Section ---
                _buildSectionHeader('Business & Other Info ℹ️'),
                _buildTextField(_nameBankController, 'Name of Banker'),
                _buildTextField(_carriedOnThisBusinessController, 'Business Carried On This Building'),
                _buildTextField(_powerUsedInTheBuildingController, 'Power Used in The Building'),
                _buildTextField(_buildingLightedController, 'How Building is Lighted'),
                _buildTextField(_whatAssistanceController, 'What Assistance in Case of Fire'),
                const SizedBox(height: 30),

                // --- Submit Button ---
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _submitFireData,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Submit Fire Application', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo, // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets for UI Elements ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const Divider(thickness: 2, color: Colors.deepPurpleAccent),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, bool required = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        validator: validator ?? (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField(String label, DateTime? selectedDate, VoidCallback onPressed, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onPressed,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            errorText: required && selectedDate == null ? 'Date is required' : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                selectedDate == null
                    ? 'Select Date'
                    : "${selectedDate.toLocal()}".split(' ')[0], // Format to YYYY-MM-DD
                style: TextStyle(color: selectedDate == null ? Colors.grey[700] : Colors.black),
              ),
              const Icon(Icons.calendar_today, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxListTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontSize: 15)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.redAccent,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true, // Makes the tile a bit smaller
      ),
    );
  }

  Widget _buildDescriptionAmountRow(TextEditingController descController, TextEditingController amtController, String itemLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildTextField(descController, '$itemLabel Description'),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _buildTextField(amtController, '$itemLabel Amount', keyboardType: TextInputType.number, validator: (value) {
              if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                return 'Enter a valid number';
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text('Select $label'),
            isExpanded: true,
            onChanged: onChanged,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// --- Main application entry point for Flutter ---
// You would typically have this in your lib/main.dart file.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire Insurance App',
      theme: ThemeData(
        primarySwatch: Colors.red, // Primary color for the app
        appBarTheme: const AppBarTheme(
          color: Colors.redAccent, // Consistent AppBar color
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const FireInsuranceFormScreen(), // Set your form screen as the home
      debugShowCheckedModeBanner: false, // Set to false in production
    );
  }
}