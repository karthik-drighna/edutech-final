import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class StudentOnlineCoursePayment extends StatefulWidget {
  final String amount;
  final String name;
  final String description;

  const StudentOnlineCoursePayment({
    super.key,
    required this.amount,
    required this.name,
    required this.description,
  });

  @override
  _StudentOnlineCoursePaymentState createState() =>
      _StudentOnlineCoursePaymentState();
}

class _StudentOnlineCoursePaymentState
    extends State<StudentOnlineCoursePayment> {
  late Razorpay _razorpay;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear all listeners
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_J60bqBOi1z1aF5',
      'amount': num.parse(widget.amount) * 100, // amount needs to be in paise
      'name': widget.name,
      'description': widget.description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': _contactController.text,
        'email': _emailController.text
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showDialog(
        "Success", "Payment was successful. Payment ID: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showDialog("Error", "Payment failed. Error: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showDialog(
        "External Wallet", "External wallet selected: ${response.walletName}");
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Online Course Payments',
      ),

      //  AppBar(
      //   title: Text('Online Course Payments'),
      //   backgroundColor: Colors.blue[800],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contact Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _openCheckout();
                  }
                },
                child: const Text('Proceed to Pay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
