import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < _controllers.length - 1) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.star_outline_sharp,
                size: 50,
                color: Colors.white,
              ),
              SizedBox(height: screenHeight * 0.05),

              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  children: <TextSpan>[
                    const TextSpan(text: 'Check your email'),
                    TextSpan(
                      text: '✨',
                      style: TextStyle(fontSize: 28, color: Colors.amber[300]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'We sent a verification link to ${widget.email}',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              SizedBox(height: screenHeight * 0.06),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return _buildOtpBox(
                    context: context,
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    isFirst: index == 0,
                    isLast: index == 3,
                  );
                }),
              ),
              SizedBox(height: screenHeight * 0.05),

              _buildGradientButton(
                text: 'Verify Email',
                onPressed: () {
                  final otp = getOtp();
                  if (otp.length == 4) {
                    print('OTP Entered: $otp');
                    // Process OTP verification
                    // On success:
                    // Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter all 4 digits.'),
                      ),
                    );
                  }
                },
                width: double.infinity,
                height: 50,
              ),
              SizedBox(height: screenHeight * 0.04),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Didn\'t receive the email? ',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Click to resend',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                // Resend email action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Resending verification email...',
                                    ),
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(), // Pushes the "Back to log in" to the bottom

              Center(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.purpleAccent,
                  ),
                  label: const Text(
                    'Back to log in',
                    style: TextStyle(color: Colors.purpleAccent),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus ? Colors.purpleAccent : Colors.grey[700]!,
        ),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLength: 1,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            counterText: '', // Hide the counter
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.length == 1 && !isLast) {
              FocusScope.of(context).nextFocus();
            } else if (value.isEmpty && !isFirst) {
              FocusScope.of(context).previousFocus();
            }
          },
        ),
      ),
    );
  }

  // Re-use button widget
  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.redAccent, Colors.purpleAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
