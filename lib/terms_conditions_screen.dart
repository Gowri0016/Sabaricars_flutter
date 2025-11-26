import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
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
                _buildSectionTitle('Terms and Conditions'),
                const SizedBox(height: 16),
                _buildText(
                  'Last Updated: November 18, 2025\n\n'
                  'These Terms and Conditions ("Agreement") constitute a legally binding agreement between you and Sabari Cars ("Company", "we", "us", "our"), governing your use of the Sabari Cars mobile application and related services (the "Service").\n\n'
                  'By accessing and using this Service, you accept and agree to be bound by the terms and provision of this agreement.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('1. Use License'),
                const SizedBox(height: 12),
                _buildText(
                  'Permission is granted to temporarily download one copy of the materials (information or software) on the Sabari Cars Service for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Modifying or copying the materials'),
                _buildBulletPoint(
                  'Using the materials for any commercial purpose or for any public display',
                ),
                _buildBulletPoint(
                  'Attempting to reverse compile, disassemble, or reverse engineer any software contained on the Service',
                ),
                _buildBulletPoint(
                  'Removing any copyright or other proprietary notations from the materials',
                ),
                _buildBulletPoint(
                  'Transferring the materials to another person or "mirroring" the materials on any other server',
                ),
                _buildBulletPoint(
                  'Violating any applicable laws or regulations',
                ),
                _buildBulletPoint(
                  'Engaging in any conduct that restricts or inhibits anyone\'s use or enjoyment of the Service',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('2. Disclaimer'),
                const SizedBox(height: 12),
                _buildText(
                  'The materials on the Sabari Cars Service are provided on an \'as is\' basis. Sabari Cars makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('3. Limitations'),
                const SizedBox(height: 12),
                _buildText(
                  'In no event shall Sabari Cars or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on the Sabari Cars Service, even if Sabari Cars or an authorized representative has been notified orally or in writing of the possibility of such damage.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('4. Accuracy of Materials'),
                const SizedBox(height: 12),
                _buildText(
                  'The materials appearing on the Sabari Cars Service could include technical, typographical, or photographic errors. Sabari Cars does not warrant that any of the materials on the Service are accurate, complete, or current. Sabari Cars may make changes to the materials contained on the Service at any time without notice.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('5. Links'),
                const SizedBox(height: 12),
                _buildText(
                  'Sabari Cars has not reviewed all of the sites linked to the Service and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Sabari Cars of the site. Use of any such linked website is at the user\'s own risk.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('6. Modifications'),
                const SizedBox(height: 12),
                _buildText(
                  'Sabari Cars may revise these terms of service for the Service at any time without notice. By using this Service, you are agreeing to be bound by the then current version of these terms of service.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('7. Governing Law'),
                const SizedBox(height: 12),
                _buildText(
                  'These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction in which Sabari Cars operates, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('8. User Accounts'),
                const SizedBox(height: 12),
                _buildText(
                  'When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms. You are responsible for safeguarding the password that you use to access the Service and for all activities that occur under your account. You agree to accept responsibility for all activities that occur under your account.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('9. User Content'),
                const SizedBox(height: 12),
                _buildText(
                  'You retain all rights to any content you submit, post, or display on or through the Service. By submitting content, you grant Sabari Cars a worldwide, non-exclusive, royalty-free license to use, copy, reproduce, process, adapt, modify, publish, transmit, display, and distribute such content in any media or medium and for any purpose.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('10. Prohibited Conduct'),
                const SizedBox(height: 12),
                _buildText(
                  'You agree not to engage in any of the following prohibited activities:',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  'Harassing or causing distress or inconvenience to any person',
                ),
                _buildBulletPoint('Obscene or abusive language or materials'),
                _buildBulletPoint(
                  'Disrupting the normal flow of dialogue within the Service',
                ),
                _buildBulletPoint(
                  'Any unlawful activity or content that violates any law',
                ),
                _buildBulletPoint('Impersonating any person or entity'),
                _buildBulletPoint('Fraud, deception, or misrepresentation'),
                _buildBulletPoint(
                  'Listing vehicles or information you don\'t have the right to list',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('11. Vehicle Listings'),
                const SizedBox(height: 12),
                _buildText(
                  'Users who list vehicles on our Service warrant that:\n'
                  '• They own or have the authority to list the vehicle\n'
                  '• All information provided is accurate and truthful\n'
                  '• The vehicle is in the condition described\n'
                  '• All necessary legal documentation is in place\n'
                  '• The listing does not violate any laws or regulations',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('12. Transactions'),
                const SizedBox(height: 12),
                _buildText(
                  'Sabari Cars is a platform for connecting buyers and sellers. We are not responsible for:\n'
                  '• The quality of vehicles or services\n'
                  '• Disputes between buyers and sellers\n'
                  '• Fraud or misrepresentation\n'
                  '• Payment processing issues\n\n'
                  'Users agree to conduct transactions responsibly and legally.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('13. Limitation of Liability'),
                const SizedBox(height: 12),
                _buildText(
                  'In no event shall Sabari Cars be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('14. Termination'),
                const SizedBox(height: 12),
                _buildText(
                  'We may terminate or suspend your account and access to the Service immediately, without prior notice or liability, for any reason whatsoever, including if you breach the Terms.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('15. Contact Information'),
                const SizedBox(height: 12),
                _buildText(
                  'If you have any questions about these Terms and Conditions, please contact us at:\n\n'
                  'Email: support@sabaricars.com\n'
                  'Website: www.sabaricars.com\n\n'
                  'By using Sabari Cars, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
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
