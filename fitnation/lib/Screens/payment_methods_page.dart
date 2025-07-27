import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatefulWidget {
  final double totalAmount;
  final double subtotal;
  final double deliveryFee;
  final double discount;

  const PaymentMethodsPage({
    super.key,
    required this.totalAmount,
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String _selectedPaymentMethod = 'card';
  bool _isCardSelected = true;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'bkash',
      name: 'bKash',
      icon: '🔵',
      color: Color(0xFFE2136E),
    ),
    PaymentMethod(
      id: 'nagad',
      name: 'Nagad',
      icon: '🟠',
      color: Color(0xFFEC5242),
    ),
    PaymentMethod(
      id: 'rocket',
      name: 'Rocket',
      icon: '🚀',
      color: Color(0xFF8A2BE2),
    ),
    PaymentMethod(
      id: 'upay',
      name: 'Upay',
      icon: '💳',
      color: Color(0xFF00A651),
    ),
    PaymentMethod(
      id: 'card',
      name: 'Credit/Debit Card',
      icon: '💳',
      color: Color(0xFF1976D2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double calculatedSubtotal = widget.subtotal > 0 ? widget.subtotal : widget.totalAmount - widget.deliveryFee + widget.discount;
    double calculatedDeliveryFee = widget.deliveryFee > 0 ? widget.deliveryFee : 50.0;
    double calculatedDiscount = widget.discount > 0 ? widget.discount : calculatedSubtotal * 0.10;
    double finalTotal = calculatedSubtotal + calculatedDeliveryFee - calculatedDiscount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isCardSelected) _buildCreditCardSection(),
            
            if (!_isCardSelected) _buildAddNewCardSection(),

            const SizedBox(height: 24),

            Text(
              'Select Other Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            ..._paymentMethods.map((method) => _buildPaymentOption(method)),

            const SizedBox(height: 32),

            _buildOrderSummary(calculatedSubtotal, calculatedDeliveryFee, calculatedDiscount, finalTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add New Card',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          Positioned(
            right: 0,
            child: Container(
              width: 200,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C1C1C), Color(0xFF2D2D2D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mastercard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.contactless,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 20,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEB001B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Positioned(
                                    left: 8,
                                    child: Container(
                                      width: 16,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF79E1B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Platinum',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '৳ ${widget.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '**** **** 2003',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCardSection() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add,
            size: 32,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'Add New Card',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    bool isSelected = _selectedPaymentMethod == method.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: method.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              method.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          method.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Radio<String>(
          value: method.id,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
              _isCardSelected = value == 'card';
            });
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.id;
            _isCardSelected = method.id == 'card';
          });
        },
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double deliveryFee, double discount, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', subtotal),
          const SizedBox(height: 12),
          _buildSummaryRow('Delivery', deliveryFee),
          const SizedBox(height: 12),
          _buildSummaryRow('Discount (10%)', -discount, isDiscount: true),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '৳ ${total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _processPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pay ৳ ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          '৳${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDiscount 
                ? Colors.green 
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _processPayment() {
    String paymentMethodName = _paymentMethods
        .firstWhere((method) => method.id == _selectedPaymentMethod)
        .name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Payment Confirmation',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Processing payment via $paymentMethodName...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment successful via $paymentMethodName!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
