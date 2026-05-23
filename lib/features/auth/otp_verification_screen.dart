import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/services/auth_service.dart';
import '../../routes/app_routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.username,
    this.onVerifiedRoute,
  });

  final String username;
  final String? onVerifiedRoute;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 120;
  bool _submitting = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _maskedEmail {
    final username = widget.username.trim();
    final at = username.indexOf('@');
    if (at <= 1) return username;
    final local = username.substring(0, at);
    final domain = username.substring(at);
    if (local.length <= 2)
      return '${local[0]}*${local.length > 1 ? local[1] : ''}$domain';
    return '${local.substring(0, 2)}${'*' * (local.length - 2)}$domain';
  }

  String get _otp => _otpControllers.map((e) => e.text).join();

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
    setState(() {});
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onOtpChanged(int index, String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean != value) {
      _otpControllers[index].text = clean;
      _otpControllers[index].selection = TextSelection.collapsed(
        offset: clean.length,
      );
    }

    if (clean.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (clean.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _authService.verifyOtp(username: widget.username, otp: _otp);
      if (!mounted) return;
      final route = widget.onVerifiedRoute;
      final hasRedirect = route != null && route.trim().isNotEmpty;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasRedirect
                ? 'OTP verified successfully.'
                : 'OTP verified successfully. Please login.',
          ),
        ),
      );
      context.go(hasRedirect ? route : AppRoutes.login);
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail']?.toString() ??
                e.response!.data['message']?.toString())
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail ?? 'Invalid OTP or OTP has expired.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verification failed. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0 || _resending) return;
    setState(() => _resending = true);
    try {
      await _authService.resendOtp(username: widget.username);
      if (!mounted) return;
      for (final c in _otpControllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP has been sent to your email.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/img/logo/logo_black.png',
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Verify with OTP',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'An OTP has been sent to $_maskedEmail',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Time remaining: ${_formatTime(_remainingSeconds)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the OTP? ",
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                      TextButton(
                        onPressed: (_remainingSeconds == 0 && !_resending)
                            ? _resendOtp
                            : null,
                        child: Text(_resending ? 'Sending...' : 'Resend'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
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
