import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isSignUp) {
        context.read<AuthBloc>().add(
              SignUpWithEmailRequested(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                displayName: _emailController.text.split('@')[0],
              ),
            );
      } else {
        context.read<AuthBloc>().add(
              SignInWithEmailRequested(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            );
      }
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(SignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo and App Name
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    LucideIcons.wallet,
                    size: 40,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appTagline,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: LucideIcons.mail,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: _obscurePassword,
                        prefixIcon: LucideIcons.lock,
                        suffixIcon: _obscurePassword
                            ? LucideIcons.eye
                            : LucideIcons.eyeOff,
                        onSuffixIconTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (_isSignUp && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        onPressed: _isLoading ? null : _submit,
                        isLoading: _isLoading,
                        text: _isSignUp ? 'Create Account' : 'Sign In',
                      ),
                      const SizedBox(height: 16),
                      // Google Sign In
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: const Icon(LucideIcons.chrome),
                        label: Text(
                          'Continue with Google',
                          style: theme.textTheme.labelLarge,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Toggle Sign In/Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp
                                ? 'Already have an account?'
                                : 'Don\'t have an account?',
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _isSignUp = !_isSignUp);
                            },
                            child: Text(
                              _isSignUp ? 'Sign In' : 'Sign Up',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_isSignUp) ...[
                        TextButton(
                          onPressed: () {
                            // Show forgot password dialog
                            _showForgotPasswordDialog();
                          },
                          child: Text(
                            'Forgot Password?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
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

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: CustomTextField(
            controller: emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: LucideIcons.mail,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                context.read<AuthBloc>().add(
                  ResetPasswordRequested(email: emailController.text.trim()),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
