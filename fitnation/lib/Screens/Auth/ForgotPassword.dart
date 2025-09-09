import 'package:fitnation/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .sendPasswordResetEmail(_emailController.text.trim());
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback? onPressed,
    required double width,
    required double height,
    required BuildContext contextForTheme,
  }) {
    final theme = Theme.of(contextForTheme);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [AppColors.darkGradientStart, AppColors.darkGradientEnd]
                  : [AppColors.lightGradientStart, AppColors.lightGradientEnd],
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
          textStyle: theme.textTheme.bodyLarge,
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is PasswordResetSent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next.message ?? 'Password reset link sent to your email!',
              ),
            ),
          );
          Navigator.of(context).pop(); // Go back to login screen
        }
      } else if (next is AuthError) {
        if (mounted && next.message != null && next.message!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.message!)));
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
                Row(
                  children: [
                    Image.asset('assets/logos/logo.png', width: 50, height: 50),
                    const SizedBox(width: 12),
                    const Text(
                      'Pulse',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                      height: 1.3,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'Forgot your password?'),
                      TextSpan(
                        text: '🤔',
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
                  'Enter your email to receive a password reset link.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                Text(
                  'Email',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),

                _buildGradientButton(
                  text: isLoading ? 'Sending...' : 'Send Reset Link',
                  onPressed: isLoading ? null : _sendResetLink,
                  width: double.infinity,
                  height: 50,
                  contextForTheme: context,
                ),
                SizedBox(height: screenHeight * 0.03),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to Login screen
                    },
                    child: Text(
                      'Back to Login',
                      style: TextStyle(color: theme.colorScheme.primary),
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
}
