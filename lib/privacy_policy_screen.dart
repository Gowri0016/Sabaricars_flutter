import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5b8df6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Privacy Policy'),
                const SizedBox(height: 16),
                _buildText(
                  'Last Updated: November 18, 2025\n\n'
                  'Sabari Cars ("we", "us", "our" or "Company") operates the Sabari Cars mobile application (the "Service").\n\n'
                  'This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('1. Information Collection and Use'),
                const SizedBox(height: 12),
                _buildText(
                  'We collect several different types of information for various purposes to provide and improve our Service to you.',
                ),
                const SizedBox(height: 16),
                _buildSubsectionTitle('Types of Data Collected:'),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  'Personal Data: Email address, name, phone number, profile information',
                ),
                _buildBulletPoint(
                  'Usage Data: IP address, browser type, pages visited, time and date of visits',
                ),
                _buildBulletPoint(
                  'Location Data: With your permission, we may collect your location information',
                ),
                _buildBulletPoint(
                  'Vehicle Data: Information about vehicles you list, purchase, or inquire about',
                ),
                _buildBulletPoint(
                  'Payment Information: Processed through secure third-party payment gateways',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('2. Use of Data'),
                const SizedBox(height: 12),
                _buildText(
                  'Sabari Cars uses the collected data for various purposes:',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('To provide and maintain the Service'),
                _buildBulletPoint('To notify you about changes to our Service'),
                _buildBulletPoint(
                  'To allow you to participate in interactive features of our Service',
                ),
                _buildBulletPoint('To provide customer care and support'),
                _buildBulletPoint(
                  'To gather analysis or valuable information so that we can improve our Service',
                ),
                _buildBulletPoint('To monitor the usage of our Service'),
                _buildBulletPoint(
                  'To detect, prevent and address technical issues and fraudulent activity',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('3. Security of Data'),
                const SizedBox(height: 12),
                _buildText(
                  'The security of your data is important to us, but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('4. Third-Party Services'),
                const SizedBox(height: 12),
                _buildText(
                  'Our Service may contain links to third-party sites that are not operated by us. This Privacy Policy does not apply to third-party websites, and we are not responsible for their privacy practices. We advise you to review the privacy policy of every site you visit.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('5. Firebase Services'),
                const SizedBox(height: 12),
                _buildText('Our Service uses Google Firebase for:'),
                const SizedBox(height: 8),
                _buildBulletPoint('Authentication and user management'),
                _buildBulletPoint('Cloud Firestore database services'),
                _buildBulletPoint('Cloud Storage for file uploads'),
                const SizedBox(height: 8),
                _buildText(
                  'Firebase may collect usage information and analytics. Please review Google\'s privacy policy at https://policies.google.com/privacy',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('6. Google Sign-In'),
                const SizedBox(height: 12),
                _buildText(
                  'When you use Google Sign-In to authenticate with our Service, Google will collect and process your information according to Google\'s privacy policies. We only receive the information necessary to verify your identity and create your account.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('7. Children\'s Privacy'),
                const SizedBox(height: 12),
                _buildText(
                  'Our Service is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from children under 13, we will take steps to delete such information and terminate the child\'s account.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('8. Changes to This Privacy Policy'),
                const SizedBox(height: 12),
                _buildText(
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date at the top of this Privacy Policy.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('9. Contact Us'),
                const SizedBox(height: 12),
                _buildText(
                  'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  'Email: privacy@sabaricars.com\n'
                  'Website: www.sabaricars.com\n\n'
                  'By using Sabari Cars, you agree to our Privacy Policy.',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1a2236),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a2236),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
