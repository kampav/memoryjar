import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../shared/widgets/glass_container.dart';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _confirmedAge = false;

  bool get _canContinue => _acceptedTerms && _acceptedPrivacy && _confirmedAge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [AppColors.background, AppColors.backgroundSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 400.ms).scale(delay: 200.ms),
                    const SizedBox(height: 20),
                    Text(
                      'Privacy & Terms',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                    const SizedBox(height: 8),
                    Text(
                      'Please review and accept to continue',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Key Points Card
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Key Points',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildKeyPoint(
                              '🔒',
                              'Your memories are encrypted and stored securely',
                              isDark,
                            ),
                            _buildKeyPoint(
                              '👤',
                              'You control who can see your content',
                              isDark,
                            ),
                            _buildKeyPoint(
                              '📤',
                              'You can export or delete your data anytime',
                              isDark,
                            ),
                            _buildKeyPoint(
                              '🇬🇧',
                              'Compliant with UK GDPR & Data Protection Act 2018',
                              isDark,
                            ),
                            _buildKeyPoint(
                              '🧒',
                              'Age-appropriate design for child safety',
                              isDark,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                      const SizedBox(height: 20),

                      // Checkboxes
                      _buildCheckboxTile(
                        title: 'Terms of Service',
                        subtitle: 'I have read and agree to the Terms of Service',
                        value: _acceptedTerms,
                        onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                        onTap: () => _showTermsSheet(context),
                        isDark: isDark,
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                      const SizedBox(height: 12),

                      _buildCheckboxTile(
                        title: 'Privacy Policy',
                        subtitle: 'I have read and agree to the Privacy Policy (UK GDPR)',
                        value: _acceptedPrivacy,
                        onChanged: (v) => setState(() => _acceptedPrivacy = v ?? false),
                        onTap: () => _showPrivacySheet(context),
                        isDark: isDark,
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),

                      const SizedBox(height: 12),

                      _buildCheckboxTile(
                        title: 'Age Confirmation',
                        subtitle: 'I confirm I am at least 13 years old (or have parental consent)',
                        value: _confirmedAge,
                        onChanged: (v) => setState(() => _confirmedAge = v ?? false),
                        isDark: isDark,
                      ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),

                      const SizedBox(height: 24),

                      // Regulatory Compliance Footer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : AppColors.primary).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isDark ? Colors.white : AppColors.primary).withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Regulatory Compliance',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'UK GDPR • Data Protection Act 2018 • Age Appropriate Design Code • ICO Registered',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white54 : AppColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 900.ms),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _canContinue
                ? () => context.go('/onboarding/profile')
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Accept & Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: _canContinue ? Colors.white : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyPoint(String emoji, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsSheet(BuildContext context) {
    _showLegalSheet(
      context,
      'Terms of Service',
      _termsOfServiceContent,
    );
  }

  void _showPrivacySheet(BuildContext context) {
    _showLegalSheet(
      context,
      'Privacy Policy',
      _privacyPolicyContent,
    );
  }

  void _showLegalSheet(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _termsOfServiceContent = '''
MEMORY JAR - TERMS OF SERVICE
Last Updated: December 2025

1. ACCEPTANCE OF TERMS

By accessing or using the Memory Jar application ("Service"), you agree to be bound by these Terms of Service. If you are under 18 years of age, you must have your parent or guardian's permission to use this Service.

2. SERVICE DESCRIPTION

Memory Jar is a digital platform that allows users to capture, store, and share personal memories with family members and friends. The Service includes features for creating text, photo, and voice memories, AI-powered reflections, and collaborative sharing.

3. USER ACCOUNTS

3.1 Registration: You must provide accurate and complete information when creating an account.
3.2 Security: You are responsible for maintaining the security of your account credentials.
3.3 Age Requirements: You must be at least 13 years old to use this Service. Users under 18 require parental consent.

4. USER CONTENT

4.1 Ownership: You retain ownership of all content you submit to the Service.
4.2 License: By submitting content, you grant Memory Jar a limited license to store, process, and display your content to authorised users.
4.3 Responsibility: You are solely responsible for your content and must ensure it does not violate any laws or third-party rights.

5. ACCEPTABLE USE

You agree NOT to:
• Upload illegal, harmful, or offensive content
• Impersonate others or provide false information
• Attempt to access other users' accounts without authorisation
• Use the Service for commercial purposes without permission
• Interfere with or disrupt the Service's operation
• Upload content depicting minors inappropriately

6. INTELLECTUAL PROPERTY

The Service, including its design, features, and code (excluding user content), is owned by Memory Jar Ltd and protected by intellectual property laws.

7. THIRD-PARTY SERVICES

The Service may integrate with third-party services (e.g., Google Sign-In, Apple Sign-In). Your use of these services is subject to their respective terms.

8. DISCLAIMER OF WARRANTIES

THE SERVICE IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED.

9. LIMITATION OF LIABILITY

TO THE MAXIMUM EXTENT PERMITTED BY UK LAW, MEMORY JAR LTD SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES.

10. INDEMNIFICATION

You agree to indemnify and hold harmless Memory Jar Ltd from any claims arising from your use of the Service or violation of these Terms.

11. MODIFICATIONS

We reserve the right to modify these Terms at any time. Continued use after changes constitutes acceptance.

12. TERMINATION

We may terminate or suspend your account for violations of these Terms. You may delete your account at any time through the app settings.

13. GOVERNING LAW

These Terms are governed by the laws of England and Wales. Disputes shall be subject to the exclusive jurisdiction of the courts of England and Wales.

14. CONTACT

For questions about these Terms:
Email: legal@memoryjar.app
Address: Memory Jar Ltd, London, United Kingdom

15. SEVERABILITY

If any provision of these Terms is found unenforceable, the remaining provisions shall continue in effect.
''';

  static const String _privacyPolicyContent = '''
MEMORY JAR - PRIVACY POLICY
Last Updated: December 2025

This Privacy Policy explains how Memory Jar Ltd ("we", "us", "our") collects, uses, and protects your personal data in compliance with the UK General Data Protection Regulation (UK GDPR) and the Data Protection Act 2018.

1. DATA CONTROLLER

Memory Jar Ltd is the data controller responsible for your personal data.
ICO Registration Number: [Pending Registration]
Contact: privacy@memoryjar.app

2. INFORMATION WE COLLECT

2.1 Information You Provide:
• Account information (name, email, profile photo)
• Memories (text, photos, voice recordings)
• Family/group information
• Communication preferences

2.2 Automatically Collected:
• Device information (type, OS, app version)
• Usage data (features used, interaction patterns)
• Log data (IP address, access times)

2.3 From Third Parties:
• Authentication data from Google/Apple Sign-In

3. LEGAL BASIS FOR PROCESSING (UK GDPR Article 6)

We process your data under these legal bases:
• Contract: To provide the Service you requested
• Legitimate Interest: To improve our Service and ensure security
• Consent: For optional features like AI reflections
• Legal Obligation: To comply with UK laws

4. HOW WE USE YOUR DATA

• Provide and maintain the Service
• Enable memory sharing with authorised users
• Generate AI-powered reflections (with consent)
• Send important notifications
• Improve and personalise the Service
• Ensure security and prevent fraud

5. DATA SHARING

We may share data with:
• Service Providers: Cloud hosting (Firebase/Google Cloud), analytics
• Other Users: Only content you explicitly share
• Legal Requirements: When required by UK law

We NEVER sell your personal data.

6. INTERNATIONAL TRANSFERS

Your data may be transferred outside the UK. We ensure adequate protection through:
• Standard Contractual Clauses (SCCs)
• UK International Data Transfer Agreement (IDTA)

7. DATA RETENTION

• Active accounts: Data retained while account is active
• Deleted memories: Permanently removed within 30 days
• Account deletion: All data deleted within 30 days, backup purge within 90 days

8. YOUR RIGHTS (UK GDPR)

You have the right to:
• Access: Request a copy of your data (Subject Access Request)
• Rectification: Correct inaccurate data
• Erasure: Request deletion ("right to be forgotten")
• Restriction: Limit how we use your data
• Portability: Receive your data in a portable format
• Object: Object to certain processing
• Withdraw Consent: Withdraw consent at any time

To exercise these rights, contact privacy@memoryjar.app. We will respond within 30 days.

9. DATA SECURITY

We implement appropriate security measures:
• AES-256 encryption at rest
• TLS 1.3 encryption in transit
• Regular security audits
• Access controls and authentication
• Data stored in UK/EU data centres

In case of a data breach, we will notify the ICO within 72 hours and affected users without undue delay.

10. CHILDREN'S PRIVACY

We comply with the Age Appropriate Design Code (Children's Code).
• Minimum age: 13 years
• Enhanced privacy for users under 18
• Parental consent required for under-18s
• No behavioural advertising to children
• High privacy settings by default for minors

11. AUTOMATED DECISION-MAKING

Our AI reflection feature uses automated processing to generate memory summaries. This is:
• Optional and consent-based
• Not used for profiling
• Subject to human review upon request

12. COOKIES AND TRACKING

We use only essential cookies for Service functionality. No advertising or tracking cookies are used.

13. CHANGES TO THIS POLICY

We will notify you of significant changes via email or in-app notification.

14. COMPLAINTS

If you have concerns about our data practices, you may:
1. Contact us: privacy@memoryjar.app
2. Lodge a complaint with the Information Commissioner's Office (ICO):
   Website: ico.org.uk
   Phone: 0303 123 1113

15. CONTACT US

Memory Jar Ltd
Email: privacy@memoryjar.app
Data Protection Officer: dpo@memoryjar.app

For Subject Access Requests: sar@memoryjar.app
''';
}
