import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../common/services/api_client.dart';
import 'package:dio/dio.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  void _showWarningDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showWarningDialog('Validation Error', 'Please enter username and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiClient().post('/auth/login/', data: {
        'username': _usernameController.text,
        'password': _passwordController.text,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        final role = data?['role'] ?? data?['user']?['role'];
        if (role != 'AGENT') {
          await ApiClient().tokenStorage.clearCookies(); // Clear any saved cookies just in case
          if (mounted) {
            setState(() => _isLoading = false);
            _showWarningDialog('Access Denied', 'You must be an Agent to log in here.');
          }
          return;
        }

        await ApiClient().saveCookiesFromResponse(response);
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errMsg = 'Invalid username or password.';
        if (e.response?.statusCode == 401) {
          errMsg = 'No active account found with the given credentials.';
        }
        if (e.response?.data != null) {
          try {
            final data = e.response!.data;
            if (data is Map && data['detail'] != null) {
              errMsg = data['detail'].toString();
            } else if (data is Map && data['errors'] != null) {
              if (data['errors']['detail'] is List) {
                errMsg = (data['errors']['detail'] as List).join(', ');
              } else if (data['errors']['detail'] != null) {
                errMsg = data['errors']['detail'].toString();
              } else {
                errMsg = data['errors'].toString();
              }
            }
          } catch (_) {}
        }
        _showWarningDialog('Login Failed', errMsg);
      }
    } catch (e) {
      if (mounted) {
        _showWarningDialog('Error', 'An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandNavy = Color(0xFF0F172A);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFEEF4FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: IntrinsicHeight(
                      child: Flex(
                        direction: isDesktop ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isDesktop)
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F0F172A),
                                      blurRadius: 30,
                                      offset: Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset('assets/img/sign-in/login.jpg', fit: BoxFit.cover),
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Color(0x660F172A), Color(0xAA0F172A)],
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        left: 30,
                                        right: 30,
                                        bottom: 30,
                                        child: Text(
                                          'Manage your visa and travel workflow with confidence.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x140F172A),
                                    blurRadius: 30,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: _buildLoginCard(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Image.asset(
            'assets/img/logo/logo_black.png',
            width: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.language, size: 56, color: _brandBlue),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome back',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: _brandNavy),
        ),
        const SizedBox(height: 6),
        const Text(
          'Login to continue to your Bideshgami dashboard.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        _buildInputField(controller: _usernameController, hintText: 'Username or phone', autofocus: true, icon: Icons.person_outline),
        const SizedBox(height: 14),
        _buildPasswordField(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Login', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push(AppRoutes.agentSignUp),
            style: OutlinedButton.styleFrom(
              foregroundColor: _brandBlue,
              side: const BorderSide(color: _brandBlue),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Become a Partner', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('New here? ', style: TextStyle(color: Color(0xFF64748B))),
              TextButton(
                onPressed: () => context.push(AppRoutes.agentSignUp),
                child: const Text('Create an account', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brandBlue, width: 1.5)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_showPassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
        hintText: 'Password',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brandBlue, width: 1.5)),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF475569)),
        ),
      ),
    );
  }
}
