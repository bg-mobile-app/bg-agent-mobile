import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../common/services/agency_access.dart';
import '../../common/services/api_client.dart';
import '../../common/services/api_exception.dart';
import '../../common/services/expiry_reminder_dialog_service.dart';
import '../../routes/app_routes.dart';
import '../../common/theme/app_palette.dart';

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
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAlreadyLoggedIn();
  }

  Future<void> _checkAlreadyLoggedIn() async {
    final cookies = await ApiClient().tokenStorage.getCookies();
    if (cookies != null && cookies.isNotEmpty) {
      if (mounted) {
        context.go(AppRoutes.home);
      }
      return;
    }
    if (mounted) {
      setState(() => _isCheckingAuth = false);
    }
  }

  void _showWarningDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showWarningDialog(
        'Validation Error',
        'Please enter username and password',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ApiClient();

      final response = await apiClient.post(
        '/auth/login/',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (!AgencyAccess.isCustomerAccount(data)) {
          await apiClient.tokenStorage.clearCookies();
          if (mounted) {
            setState(() => _isLoading = false);
            _showWarningDialog(
              'Access Denied',
              AgencyAccess.customerAccessDeniedMessage,
            );
          }
          return;
        }

        await apiClient.saveCookiesFromResponse(response);
        final savedCookies = await apiClient.tokenStorage.getCookies();
        debugPrint('Login completed. Saved auth cookies: $savedCookies');
        await ExpiryReminderDialogService().markPendingForLogin();
        // Set system navigation color for logged-in users
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            systemNavigationBarColor: AppPalette.brandBlue,
            systemNavigationBarDividerColor: AppPalette.brandBlue,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        );
        if (mounted) {
          context.go(AppRoutes.home);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errMsg = e.message ?? 'An error occurred during login.';
        if (e.response?.data != null) {
          try {
            final data = e.response!.data;
            if (data is Map) {
              if (data['detail'] != null) {
                errMsg = data['detail'].toString();
              } else if (data['message'] != null) {
                errMsg = data['message'].toString();
              } else if (data['errors'] != null) {
                if (data['errors'] is Map && data['errors']['detail'] != null) {
                  final errDetail = data['errors']['detail'];
                  errMsg = errDetail is List ? errDetail.join(', ') : errDetail.toString();
                } else {
                  errMsg = data['errors'].toString();
                }
              }
            } else if (data is String && data.isNotEmpty) {
              errMsg = data;
            }
          } catch (_) {}
        }
        _showWarningDialog('Login Failed', errMsg);
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showWarningDialog('Login Failed', _loginErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        _showWarningDialog(
          'Error',
          'An unexpected error occurred: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _loginErrorMessage(ApiException exception) {
    final data = exception.data;
    if (data is Map) {
      final detail = data['detail'] ?? data['message'];
      if (detail != null) return detail.toString();

      final errors = data['errors'];
      if (errors is Map) {
        final errorDetail = errors['detail'];
        if (errorDetail is List) return errorDetail.join(', ');
        if (errorDetail != null) return errorDetail.toString();
      }
      if (errors != null) return errors.toString();
    }
    return exception.message.isNotEmpty
        ? exception.message
        : 'An error occurred during login.';
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
    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: IntrinsicHeight(
                          child: Flex(
                            direction: isDesktop
                                ? Axis.horizontal
                                : Axis.vertical,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isDesktop)
                                Flexible(
                                  fit: FlexFit.loose,
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
                                          Image.asset(
                                            'assets/img/sign-in/login.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0x660F172A),
                                                  Color(0xAA0F172A),
                                                ],
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
                              Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/img/logo/logo_black.png',
              width: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.language, size: 56, color: _brandBlue),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: _brandNavy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Login to continue to your Bideshgami dashboard.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _usernameController,
            hintText: 'Username or phone',
            autofocus: true,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _buildPasswordField(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),

          const SizedBox(height: 10),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'New here? ',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.agentSignUp),
                  child: const Text(
                    'Create an account',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandBlue, width: 1.5),
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandBlue, width: 1.5),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Icon(
            _showPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
