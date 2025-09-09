import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/Screens/Auth/ForgotPassword.dart';
import 'package:fitnation/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:fitnation/providers/auth_provider.dart'; // Import AuthProvider

class LoginScreen extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState(); // Change state type
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Change state type
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // bool _isLoading = false; // This will be managed by AuthState

  // initState is no longer needed for ref.listen if moved to build
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    // Call the login method from AuthNotifier
    await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
  }

  // Social login methods will need to be implemented with your custom backend if supported
  // For now, they will just show a message.
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

  // Modify helper widgets to accept theme or context
  Widget _buildGradientButton({
    required String text,
    required VoidCallback? onPressed,
    required double width,
    required double height,
    required BuildContext contextForTheme, // Added
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
          textStyle: theme.textTheme.bodyLarge, // Use theme button text style
        ),
        child: Text(text), // Text color should come from textStyle
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    required Color iconColor, // Keep specific brand color for icon
    required BuildContext contextForTheme, // Added
    required double width,
    required double height,
  }) {
    final theme = Theme.of(contextForTheme);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: iconColor, size: 28),
        label: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color:
                isDarkMode
                    ? AppColors.darkSocialButtonOutline
                    : AppColors.lightSocialButtonOutline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context); // Get the current theme

    // Listen to auth state changes for navigation and feedback
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is Authenticated) {
        if (mounted) {
          // Check if the widget is still in the tree
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          // Navigate to HomeScreen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MyApp(),
            ), // Navigate to HomeScreen
            (Route<dynamic> route) => false,
          );
        }
      } else if (next is Unauthenticated) {
        if (mounted && next.message != null && next.message!.isNotEmpty) {
          // Check if mounted
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.message!)));
        }
      }
    });

    // Watch the auth state to update UI (e.g., show loading indicator)
    final authState = ref.watch(authProvider);
    final bool isLoading = authState is AuthLoading;

    return Scaffold(
      // backgroundColor: theme.scaffoldBackgroundColor, // Already handled by MaterialApp
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
                // Icon(
                //   Icons.star_outline_sharp,
                //   size: 50,
                //   color: theme.colorScheme.onBackground, // Use theme color
                // ),
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
                    // style: theme.textTheme.displayLarge, // Use theme text style
                    // Or define a specific style that uses theme colors
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground, // Use theme color
                      height: 1.3,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'Log in to your account'),
                      TextSpan(
                        text: '✨',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.amber[300],
                        ), // Keep specific sparkle color
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Welcome back! Please enter your details.',
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
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ), // For input text color
                  decoration: InputDecoration(
                    // Theme already styles this largely
                    hintText: 'Enter your email',
                    // hintStyle: theme.inputDecorationTheme.hintStyle, // Handled by theme
                    prefixIcon: Icon(
                      Icons
                          .email_outlined /*, color: theme.inputDecorationTheme.prefixIconColor*/,
                    ), // Handled
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

                Text(
                  'Password',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        // color: theme.inputDecorationTheme.suffixIconColor, // Handled by theme
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            // Theme handles checkbox styling
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember for 30 days',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                TextButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                  child: Text(
                    'Forgot password',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                _buildGradientButton(
                  // This widget needs to be theme-aware or accept theme colors
                  text: isLoading ? 'Logging in...' : 'Log In',
                  onPressed:
                      isLoading
                          ? null
                          : _loginWithEmail, // Call _loginWithEmail

                  width: double.infinity,
                  height: 50,
                  contextForTheme: context, // Pass context or theme
                ),
                SizedBox(height: screenHeight * 0.03),

                _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  text: 'Log in with Google',
                  onPressed:
                      isLoading
                          ? null
                          : _loginWithGoogle, // Call _loginWithGoogle
                  iconColor: AppColors.googleRed, // Keep specific brand color
                  contextForTheme: context,
                  width: double.infinity,
                  height: 50,
                ),
                // const SizedBox(height: 16),
                // _buildSocialButton(
                //   icon: Icons.facebook,
                //   text: 'Log in with Facebook',
                //   onPressed:
                //       isLoading
                //           ? null
                //           : _loginWithFacebook, // Call _loginWithFacebook
                //   //  _isLoading ? null : _loginWithGoogle,
                //   iconColor:
                //       AppColors.facebookBlue, // Keep specific brand color
                //   contextForTheme: context,
                //   width: double.infinity,
                //   height: 50,
                // ),
                // ... similar for Facebook button ...
                SizedBox(height: screenHeight * 0.05),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                    context,
                                    '/create_account',
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
}
