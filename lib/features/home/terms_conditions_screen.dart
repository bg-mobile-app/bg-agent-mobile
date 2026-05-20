import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPageScaffold(
      currentHref: '/dashboard/terms-and-conditions',
      child: _TermsConditionsContent(),
    );
  }
}

class _TermsConditionsContent extends StatelessWidget {
  const _TermsConditionsContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms & Conditions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Please review the terms below. This page is informational and contains static content only.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              SizedBox(height: 12),
              _TermsAccordion(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsAccordion extends StatelessWidget {
  const _TermsAccordion();

  static const _sections = <({String title, String content})>[
    (
      title: 'Product Information',
      content:
          'Our flagship product is designed to simplify agency operations with a modern, reliable, and secure platform. '
          'It combines booking workflows, user management, and communication tools in one place. '
          'Core features include structured dashboard modules, status tracking, and notification support to keep teams aligned.',
    ),
    (
      title: 'Usage Guidelines',
      content:
          'Use the platform responsibly and ensure all data entered is accurate and up to date. '
          'Do not share account credentials, and always follow your organization\'s internal policy when managing customer records. '
          'For best performance, regularly review booking statuses and verify actions before final submission.',
    ),
    (
      title: 'Return Policy',
      content:
          'Return and refund requests must meet the applicable conditions defined by your service agreement. '
          'To start a return process, submit the required details and supporting documents through the proper workflow. '
          'Approved requests are processed in sequence, and refund timelines may vary depending on review and payment channels.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      expandedHeaderPadding: EdgeInsets.zero,
      children: _sections
          .map(
            (section) => ExpansionPanelRadio(
              value: section.title,
              headerBuilder: (context, isExpanded) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  section.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  section.content,
                  style: const TextStyle(height: 1.5, color: Colors.black87),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
