import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _upiController = TextEditingController();
  bool _isProcessing = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _cvvController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(String method) async {
    final booking = context.read<BookingProvider>();
    final auth = context.read<AuthProvider>();

    // BUG-13: Card payment succeeds with invalid card number
    // BUG-14: Payment succeeds without CVV
    if (method == 'credit_card') {
      final cardNumber = _cardNumberController.text;
      if (cardNumber.isEmpty) {
        Fluttertoast.showToast(msg: 'Enter card number', backgroundColor: Colors.red);
        return;
      }
    }

    setState(() => _isProcessing = true);

    // BUG-15: Success screen appears before API confirmation
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _showSuccess = true;
      _isProcessing = false;
    });

    try {
      await auth.apiService.processPayment(
        amount: booking.totalAmount,
        method: method,
        cardNumber: _cardNumberController.text,
        cvv: _cvvController.text,
        upiId: _upiController.text,
      );

      if (auth.user != null) {
        await booking.createBooking(auth.user!.id);
      }
    } catch (e) {
      // Success already shown - BUG-15
      debugPrint('[PAYMENT] API error after success shown: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    if (_showSuccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 80, color: Colors.green.shade600),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ₹${booking.totalAmount.toInt()}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  booking.clearSeats();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2)),
                    (route) => false,
                  );
                },
                child: const Text('View Booking History'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.secondaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.credit_card), text: 'Credit Card'),
            Tab(icon: Icon(Icons.account_balance), text: 'UPI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              'Amount to Pay: ₹${booking.totalAmount.toInt()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardForm(),
                _buildUpiForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '4111 1111 1111 1111',
              prefixIcon: Icon(Icons.credit_card),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cvvController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'CVV (Optional)',
              hintText: '123',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processPayment('credit_card'),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay with Card'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _upiController,
            decoration: const InputDecoration(
              labelText: 'UPI ID',
              hintText: 'user@upi',
              prefixIcon: Icon(Icons.account_balance),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processPayment('upi'),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay with UPI'),
            ),
          ),
        ],
      ),
    );
  }
}
