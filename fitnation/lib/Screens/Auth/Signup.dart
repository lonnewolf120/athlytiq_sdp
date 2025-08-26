import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/Screens/Auth/Login.dart'; // Import LoginScreen

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // This will be managed by AuthState in build method

  // initState is no longer needed for ref.listen if moved to build
  // @override
  // void initState() {
  //   super.initState();
  // }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the ToS requirement.'),
        ),
      );
      return;
    }
    // No need to setState(_isLoading = true) here, as the listener will handle it
    await ref
        .read(authProvider.notifier)
        .register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }
  Future<void> _loginWithGoogle() async {
    // Call the signInWithGoogle method from AuthNotifier
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _loginWithFacebook() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Facebook login not yet implemented with custom backend.',
          ),
        ),
      );
    }
  }


  void _signUpWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-up not yet implemented with custom backend.')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Listen to auth state changes for navigation and feedback
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthLoading) {
        // isLoading state is now derived from ref.watch, no need to setState here
      } else {
        // isLoading state is now derived from ref.watch, no need to setState here
        if (next is Unauthenticated && next.message != null) {
          if (mounted) { // Check if mounted
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message!)));
            if (next.message!.contains("Registration successful")) {
              // The SnackBar for "Registration successful" is already shown by AuthNotifier.
              // Just navigate.
              Navigator.pushReplacement( // Navigate to login after successful registration
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          }
        } else if (next is Authenticated) {
          // This case might happen if auto-login occurs after registration,
          // though the current register flow in AuthNotifier doesn't do this.
          // If it did, you'd navigate to home or dashboard.
          // if (mounted) {
          //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())); // Example
          // }
        }
      }
    });

    final authState = ref.watch(authProvider);
    final bool isLoading = authState is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.star_outline_sharp,
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(height: screenHeight * 0.03),

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'Create an account'),
                      TextSpan(
                        text: '✨',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.amber[300],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Welcome! Please enter your details.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                SizedBox(height: screenHeight * 0.04),

                Text(
                  'Name',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your name';
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),

                Text(
                  'Email',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),

                Text(
                  'Password',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    if (value.length < 8)
                      return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                // "Must be at least 8 characters" - This is usually info, not a checkbox for terms.
                // If it's for terms, use a CheckboxListTile. For info, just Text.
                // For this design, it has a checkbox.
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value:
                            _agreedToTerms, // This state could represent acknowledgement or a different term
                        onChanged: (bool? value) {
                          setState(() {
                            _agreedToTerms = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Agree to the Terms of Services',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                _buildGradientButton(
                  text: _isLoading ? 'Signing up...' : 'Sign Up',
                  onPressed: _isLoading ? null : () => _signUpWithEmail(), // Disable if loading
                  width: double.infinity,
                  height: 50,
                ),
                SizedBox(height: screenHeight * 0.03),

                _buildSocialButton(
                  icon: Icons.g_mobiledata_sharp,
                  text: 'Login with Google',
                  onPressed: _isLoading ? null : () => _loginWithGoogle(), // Disable if loading
                  iconColor: Colors.redAccent,
                  width: double.infinity,
                  height: 50,
                ),
                SizedBox(height: screenHeight * 0.02),
                // _buildSocialButton(
                //   icon: Icons.facebook,
                //   text: 'Sign up with Facebook',
                //   onPressed: _isLoading ? null : () {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(content: Text('Facebook sign-up not yet implemented with custom backend.')),
                //     );
                //   }, // Disable if loading
                //   iconColor: Colors.blue,
                //   width: double.infinity,
                //   height: 50,
                // ),
                // SizedBox(height: screenHeight * 0.05),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Log in',
                          style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement( // Use pushReplacement to clear stack
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Re-use button widgets from LoginScreen or make them global helper widgets
  Widget _buildGradientButton({
    required String text,
    VoidCallback? onPressed, // Changed to nullable VoidCallback
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

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    VoidCallback? onPressed, // Changed to nullable VoidCallback
    required Color iconColor,
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: iconColor, size: 28),
        label: Text(
          text,
          style: TextStyle(color: Colors.grey[300], fontSize: 16),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[700]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
