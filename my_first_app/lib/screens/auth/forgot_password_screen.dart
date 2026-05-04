import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final prov = context.read<AppProvider>();
    final ok = await prov.sendPasswordReset(_emailCtrl.text.trim());

    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              if (!_sent) ...[
                // Icon
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        size: 46, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Forgot Password?',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        hint: 'student@example.edu',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      GradientButton(
                        label: 'Send Reset Link',
                        onPressed: _loading ? null : _sendReset,
                        isLoading: _loading,
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success state
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusXXL),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          size: 56,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('Email Sent!',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: AppColors.accentGreen)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'We\'ve sent a password reset link to\n${_emailCtrl.text}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your inbox and follow the instructions.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      GradientButton(
                        label: 'Back to Sign In',
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.login),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => setState(() => _sent = false),
                        child: const Text("Didn't receive? Try again"),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Remember your password?",
                        style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sign In'),
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
}
