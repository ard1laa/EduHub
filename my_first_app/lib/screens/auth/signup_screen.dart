import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms & Conditions')),
      );
      return;
    }

    final prov = context.read<AppProvider>();
    final ok = await prov.signUp(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else if (prov.authError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.authError!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isLoading = prov.authState == AuthState.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
              vertical: AppDimensions.paddingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Create Account',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text('Join EduHub and start your learning journey',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),

                // Form
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXL),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'John Doe',
                        prefixIcon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Name is required';
                          if (v.trim().length < 2) return 'Name too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        hint: 'john@student.edu',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        hint: 'Min. 6 characters',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _confirmPassCtrl,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirm your password';
                          if (v != _passCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password strength indicator
                      _PasswordStrengthBar(password: _passCtrl.text),
                      const SizedBox(height: 16),

                      // Terms
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (v) =>
                                setState(() => _agreeToTerms = v ?? false),
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      GradientButton(
                        label: 'Create Account',
                        onPressed: isLoading ? null : _signUp,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?",
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
      ),
    );
  }
}

class _PasswordStrengthBar extends StatefulWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  @override
  State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<_PasswordStrengthBar> {
  int _getStrength(String p) {
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 6) score++;
    if (p.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(p)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength(widget.password);
    final labels = ['', 'Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'];
    final colors = [
      Colors.transparent,
      AppColors.accentRed,
      AppColors.accentOrange,
      AppColors.warning,
      AppColors.accentGreen,
      AppColors.accentGreen,
    ];

    if (widget.password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            5,
            (i) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i < strength ? colors[strength] : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          strength > 0 ? 'Password strength: ${labels[strength]}' : '',
          style: TextStyle(
            fontSize: 11,
            color: strength > 0 ? colors[strength] : AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
