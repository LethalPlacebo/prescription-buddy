import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import 'dashboard_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _keepSignedIn = true;
  bool _acceptedTerms = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  bool _googleSupported = true;
  late final Future<void> _googleInitFuture;

  @override
  void initState() {
    super.initState();
    _googleInitFuture = _initializeGoogleSignIn();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (!_isLogin && !_acceptedTerms) {
      _showMessage('Please accept the privacy terms to continue.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await credential.user?.updateDisplayName(
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
              .trim(),
        );
        await credential.user?.reload();
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const DashboardShell(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(_friendlyErrorMessage(error));
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleSubmitting = true);

    try {
      await _googleInitFuture;
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const DashboardShell(),
        ),
      );
    } on GoogleSignInException catch (error) {
      final cancelled = error.code.toString().toLowerCase().contains('cancel');
      if (!cancelled) {
        _showMessage(
          'Google sign-in could not be completed. Please verify Google sign-in is enabled in Firebase and try again.',
        );
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(_friendlyErrorMessage(error));
    } catch (_) {
      _showMessage('Google sign-in could not be completed right now.');
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } on UnimplementedError {
      if (mounted) {
        setState(() => _googleSupported = false);
      } else {
        _googleSupported = false;
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Use a password with at least 6 characters.';
      case 'operation-not-allowed':
        return 'Enable Email/Password and Google sign-in in Firebase Authentication.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using another sign-in method.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=900&q=80',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE8F4EF), Color(0xFFF8E8CA)],
                          ),
                        ),
                        child: const Icon(
                          Icons.local_pharmacy_rounded,
                          size: 42,
                          color: AppTheme.emerald,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isLogin
                      ? 'Sign in to your Prescription Buddy account.'
                      : 'Create your Prescription Buddy account.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Securely sync prescriptions, reminders, savings, and refill tracking across devices.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SegmentButton(
                            label: 'Log in',
                            active: _isLogin,
                            onTap: () => setState(() => _isLogin = true),
                          ),
                        ),
                        Expanded(
                          child: _SegmentButton(
                            label: 'Create account',
                            active: !_isLogin,
                            onTap: () => setState(() => _isLogin = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isLogin) ...[
                    _InputField(
                      controller: _firstNameController,
                      label: 'First name',
                      hintText: 'Enter your first name',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final firstName = value?.trim() ?? '';
                        if (firstName.isEmpty) {
                          return 'Enter your first name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _lastNameController,
                      label: 'Last name',
                      hintText: 'Enter your last name',
                      icon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final lastName = value?.trim() ?? '';
                        if (lastName.isEmpty) {
                          return 'Enter your last name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  _InputField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: _isLogin
                        ? 'sophia@prescriptionbuddy.com'
                        : 'yourname@email.com',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'Enter your email.';
                      }
                      if (!email.contains('@')) {
                        return 'Enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _InputField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    icon: Icons.lock_rounded,
                    obscureText: _obscurePassword,
                    textInputAction:
                        _isLogin ? TextInputAction.done : TextInputAction.next,
                    trailing: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.muted,
                      ),
                    ),
                    validator: (value) {
                      final password = value ?? '';
                      if (password.isEmpty) {
                        return 'Enter your password.';
                      }
                      if (!_isLogin && password.length < 6) {
                        return 'Use at least 6 characters.';
                      }
                      return null;
                    },
                    onSubmitted: (_) {
                      if (_isLogin) {
                        _submit();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_isLogin) {
                              _keepSignedIn = !_keepSignedIn;
                            } else {
                              _acceptedTerms = !_acceptedTerms;
                            }
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: (_isLogin ? _keepSignedIn : _acceptedTerms)
                                ? AppTheme.emerald
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.emerald.withValues(alpha: 0.3),
                            ),
                          ),
                          child: (_isLogin ? _keepSignedIn : _acceptedTerms)
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isLogin
                            ? 'Keep me signed in'
                            : 'I agree to the privacy terms',
                      ),
                      const Spacer(),
                      Text(
                        _isLogin ? 'Forgot password?' : 'Need help?',
                        style: const TextStyle(
                          color: AppTheme.emerald,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: _isSubmitting
                        ? (_isLogin ? 'Signing in...' : 'Creating account...')
                        : (_isLogin
                            ? 'Continue to Dashboard'
                            : 'Create account'),
                    onPressed:
                        _isSubmitting || _isGoogleSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0x2F94A3B8))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                    color: AppTheme.muted,
                                  ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0x2F94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SocialButton(
                    label: _isGoogleSubmitting
                        ? 'Connecting Google...'
                        : 'Continue with Google',
                    icon: Icons.public_rounded,
                    onTap: _isSubmitting ||
                            _isGoogleSubmitting ||
                            !_googleSupported
                        ? null
                        : _signInWithGoogle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF111827) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppTheme.muted,
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hintText;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.muted),
              hintText: hintText,
              hintStyle: const TextStyle(color: AppTheme.muted),
              suffixIcon: trailing,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: onTap == null ? 0.62 : 0.88),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: onTap == null
                    ? AppTheme.muted.withValues(alpha: 0.7)
                    : AppTheme.ink,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: onTap == null
                      ? AppTheme.muted.withValues(alpha: 0.7)
                      : AppTheme.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
