import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';

class AgentSignUpThankYouScreen extends StatelessWidget {
  const AgentSignUpThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/sign-up/under-verification.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Thank You',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your agent registration is complete. Our team will review your information and contact you shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Go to Login'),
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
