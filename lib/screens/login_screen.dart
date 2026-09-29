import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../services/api_service.dart';
import 'nearby_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validate fields
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Please enter your email and password',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Call Spring Boot login API
      await ApiService.login(
        email,
        password,
      );

      if (!mounted) return;

      // Login successful -> open Nearby screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NearbyScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              28,
              36,
              28,
              24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // Brand mark
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Welcome back',
                    style: AppTextStyles.display,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Sign in to discover people around you.',
                    style: AppTextStyles.bodySecondary,
                  ),

                  const SizedBox(height: 38),

                  // Email label
                  const Text(
                    'Email',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 8),

                  // Email field
                  TextField(
                    controller: emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    textInputAction:
                    TextInputAction.next,
                    decoration:
                    const InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        size: 21,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password label
                  const Text(
                    'Password',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 8),

                  // Password field
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    textInputAction:
                    TextInputAction.done,
                    onSubmitted: (_) => login(),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 21,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                            !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons
                              .visibility_outlined
                              : Icons
                              .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Add forgot-password flow later.
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                        AppColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Forgot password?',
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                      isLoading ? null : login,
                      child: isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Continue',
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        child: Text(
                          'NEW TO CENTROID?',
                          style:
                          AppTextStyles.caption
                              .copyWith(
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Create account
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        // Register screen will be added later.
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.border,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Create account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Privacy note
                  const Center(
                    child: Text(
                      'Your location stays under your control.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}