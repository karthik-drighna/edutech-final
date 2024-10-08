import 'dart:io';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflinePaymentScreen extends StatefulWidget {
  final String feesSessionId;
  final String feesTypeId;
  final String feesId;
  final String paymenttype;
  final String transfeesId;

  const OfflinePaymentScreen({
    super.key,
    required this.feesSessionId,
    required this.feesTypeId,
    required this.feesId,
    required this.paymenttype,
    required this.transfeesId,
  });

  @override
  _OfflinePaymentScreenState createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _paymentModeController = TextEditingController();
  final _paymentFromController = TextEditingController();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  File? _selectedFile;
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    _paymentModeController.dispose();
    _paymentFromController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadBitmap(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String apiUrl =
        prefs.getString(Constants.apiUrl) ?? ""; // Replace with your API URL
    String url = apiUrl + Constants.addofflinepaymentUrl;
    String clientService =
        Constants.clientService; // Replace with your Client Service
    String authKey = Constants.authKey; // Replace with your Auth Key
    final String userId =
        prefs.getString(Constants.userId) ?? ""; // Replace with your User ID
    final String accessToken =
        prefs.getString("accessToken") ?? ""; // Replace with your Access Token

    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({
      'Client-Service': clientService,
      'Auth-Key': authKey,
      'User-ID': userId,
      'Authorization': accessToken,
    });

    request.fields['student_session_id'] =
        widget.feesSessionId.toString(); // Replace with your session ID
    request.fields['fee_groups_feetype_id'] =
        widget.feesTypeId.toString(); // Replace with your fee type ID
    request.fields['student_fees_master_id'] =
        widget.feesId.toString(); // Replace with your fees master ID
    request.fields['payment_date'] = _dateController.text;
    request.fields['amount'] = _amountController.text;
    request.fields['reference'] = _referenceController.text;
    request.fields['bank_account_transferred'] = _paymentFromController.text;
    request.fields['payment_type'] =
        widget.paymenttype; // Replace with your payment type
    request.fields['student_transport_fee_id'] =
        widget.transfeesId; // Replace with your transport fee ID

    if (_selectedFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
    } else {
      request.fields['file'] = '';
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      if (jsonData['status'] == '1') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment submitted successfully!')));
      } else {
        String errorMessage = jsonData['error']?['reason'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit payment: $errorMessage')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit payment')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _submitPayment(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await _uploadBitmap(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: "Offline Payment"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Payment',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the payment date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentModeController,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the payment mode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentFromController,
                decoration: const InputDecoration(
                  labelText: 'Payment From',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter where the payment is from';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  _showFilePickerDialog(context);
                },
                child: const Text('Select Image/File'),
              ),
              if (_selectedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      'File Selected: ${_selectedFile!.path.split('/').last}'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitPayment(context),
                child: _isLoading
                    ? const PencilLoaderProgressBar()
                    : const Text('Submit Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose file from"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () {
                  _pickImageFromCamera();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
