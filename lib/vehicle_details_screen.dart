import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_navbar.dart';
import 'app_drawer.dart';
import 'firebase_service.dart';
import 'wishlist_heart.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int activeImage = 0;
  final PageController _pageController = PageController();
  bool isFavorite = false;
  bool wishlistLoading = false;
  String? successMsg;

  @override
  void initState() {
    super.initState();
    _checkInitialWishlistState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialWishlistState() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final isInWishlist = await _firebaseService.isWishlisted(
        userId,
        widget.vehicle['id'] ?? widget.vehicle['name'] ?? '',
      );
      if (mounted) {
        setState(() {
          isFavorite = isInWishlist;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final images = (vehicle['images'] as List?)?.cast<String>() ?? [];
    final hasImages = images.isNotEmpty;
    final featured = vehicle['featured'] == true;
    final name =
        vehicle['name'] ??
        (vehicle['make'] ?? '') + ' ' + (vehicle['model'] ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Vehicle Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      drawer: AppDrawer(
        onNavSelected: (index) {
          Navigator.of(context).pop();
        },
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 0,
        onTap: (index) {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 68),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery Section
                  if (hasImages)
                    _buildImageGallery(images, name)
                  else
                    _buildImagePlaceholder(),

                  const SizedBox(height: 20),

                  // Vehicle Header Card
                  _buildVehicleHeaderCard(vehicle, name, featured),

                  const SizedBox(height: 16),

                  // Key Specifications
                  _buildKeySpecifications(vehicle),

                  const SizedBox(height: 20),

                  // Condition Report
                  if (vehicle['inspection'] != null &&
                      vehicle['inspection'] is Map)
                    _buildConditionSection(vehicle['inspection'] as Map),

                  // Refurbishment Details
                  if (vehicle['refurbishment'] != null &&
                      vehicle['refurbishment'] is Map)
                    _buildRefurbSection(vehicle['refurbishment'] as Map),

                  // Finance Options
                  if (vehicle['financial'] != null &&
                      vehicle['financial'] is Map)
                    _buildFinanceSection(vehicle['financial'] as Map),

                  // Video Section
                  if (vehicle['visuals'] != null &&
                      vehicle['visuals']['video'] != null)
                    _buildVideoSection(vehicle['visuals']['video']),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Sticky Contact Actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.phone,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Call Seller',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28a745),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _launchPhone(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.message,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'WhatsApp',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _launchWhatsApp(name),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> images, String name) {
    return Column(
      children: [
        // Main Image with PageView
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (idx) => setState(() => activeImage = idx),
                    itemBuilder: (ctx, idx) {
                      return Image.network(
                        images[idx],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (c, e, st) => _buildImagePlaceholder(),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Overlay Actions
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.share,
                    color: const Color(0xFF007bff),
                    onTap: () => _handleShare(context, name),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: const Color(0xFF007bff),
                    onTap: () {},
                    child: WishlistHeart(
                      vehicleId: widget.vehicle['id']?.toString() ?? '',
                      vehicle: widget.vehicle,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Dots Indicator
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: activeImage == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activeImage == i
                      ? const Color(0xFF2563eb)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Thumbnails
        if (images.length > 1)
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      idx,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: idx == activeImage
                            ? const Color(0xFF2563eb)
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        images[idx],
                        width: 100,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            _buildImagePlaceholder(small: true),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          child ??
          IconButton(
            icon: Icon(icon, color: color, size: 20),
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
    );
  }

  Widget _buildVehicleHeaderCard(Map vehicle, String name, bool featured) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${vehicle['year'] ?? ''} • ${vehicle['variant'] ?? ''} • ${vehicle['owners'] ?? ''} owner(s)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (featured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Featured',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Price Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatPrice(vehicle['price']),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0a7cff),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'On-Road Price',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Specs
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (vehicle['variant'] != null)
                _buildIconText(Icons.settings, vehicle['variant']),
              if (vehicle['year'] != null)
                _buildIconText(Icons.calendar_today, vehicle['year']),
              if (vehicle['fuelType'] != null)
                _buildIconText(Icons.local_gas_station, vehicle['fuelType']),
              if (vehicle['transmission'] != null)
                _buildIconText(Icons.swap_horiz, vehicle['transmission']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeySpecifications(Map vehicle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Specifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSpecCard(
              Icons.trending_up,
              'Odometer',
              vehicle['odometer']?.toString(),
              suffix: ' km',
            ),
            _buildSpecCard(
              Icons.person,
              'Owners',
              vehicle['owners']?.toString(),
            ),
            _buildSpecCard(Icons.map, 'Registration', vehicle['registration']),
            _buildSpecCard(
              Icons.shield,
              'Insurance',
              vehicle['insuranceValidity'],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecCard(
    IconData icon,
    String label,
    String? value, {
    String? suffix,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Container(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE9ECEF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF007bff), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                Text(
                  value + (suffix ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSection(Map inspection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Vehicle Condition Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: inspection.entries
              .map((e) => _buildConditionItem(e.key, e.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildConditionItem(String key, dynamic value) {
    final valStr = value.toString();
    Color dotColor;
    switch (valStr.toLowerCase()) {
      case 'good':
        dotColor = const Color(0xFF28a745);
        break;
      case 'fair':
        dotColor = const Color(0xFFFFC107);
        break;
      case 'poor':
        dotColor = const Color(0xFFDC3545);
        break;
      default:
        dotColor = const Color(0xFF007bff);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formatLabel(key),
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          ),
          Text(
            valStr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefurbSection(Map refurbishment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Refurbishment Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        ...refurbishment.entries.map((e) => _buildRefurbItem(e.key, e.value)),
      ],
    );
  }

  Widget _buildRefurbItem(String key, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatLabel(key),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          if (value is List)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: value
                    .map(
                      (v) => Text(
                        '• $v',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                value.toString(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinanceSection(Map financial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Finance Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: financial.entries
              .map((e) => _buildFinanceCard(e.key, e.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFinanceCard(String key, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatLabel(key),
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4),
          value is bool
              ? Text(
                  value ? 'Available' : 'Not Available',
                  style: TextStyle(
                    color: value
                        ? const Color(0xFF28a745)
                        : const Color(0xFFDC3545),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                )
              : Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Video Walkthrough',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: url.isNotEmpty
                ? (url.contains('youtube.com') || url.contains('youtu.be'))
                      ? _buildYoutubePlayer(url)
                      : _buildWebVideo(url)
                : _buildVideoPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildYoutubePlayer(String url) {
    final videoId = _extractYouTubeId(url);
    if (videoId == null) {
      return _buildVideoPlaceholder();
    }
    final thumbUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(thumbUrl, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }

  Widget _buildWebVideo(String url) {
    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, size: 48, color: Color(0xFF007bff)),
              SizedBox(height: 8),
              Text(
                'Tap to play video',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 48, color: Color(0xFF999999)),
            SizedBox(height: 8),
            Text(
              'No video available',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({bool small = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              color: Colors.grey.shade400,
              size: small ? 32 : 48,
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: small ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String? text) {
    if (text == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF007bff)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Price on request';
    try {
      if (price is int) {
        return '₹${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';
      } else if (price is String) {
        return '₹$price';
      }
    } catch (_) {}
    return '₹$price';
  }

  String _formatLabel(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
        .replaceFirstMapped(RegExp(r'^.'), (m) => m[0]!.toUpperCase());
  }

  String? _extractYouTubeId(String url) {
    final regExp = RegExp(r'(?:v=|be/)([\w-]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Future<void> _handleShare(BuildContext context, String name) async {
    final vehicle = widget.vehicle;
    final String baseUrl = 'https://sabaricars.com/vehicle';
    final String vehicleId = vehicle['id']?.toString() ?? '';
    final String shareUrl = vehicleId.isNotEmpty
        ? '$baseUrl/$vehicleId'
        : baseUrl;
    final String text =
        'Check out this vehicle on Sabari Cars: $name\n$shareUrl';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.share, size: 32, color: Color(0xFF2563eb)),
                const SizedBox(height: 12),
                const Text(
                  'Share Vehicle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563eb),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text('Share via...'),
                    onPressed: () {
                      Share.share(text);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563eb),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Color(0xFF2563eb)),
                    ),
                    icon: const Icon(Icons.link),
                    label: const Text('Copy Link'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareUrl));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Link copied to clipboard'),
                          backgroundColor: const Color(0xFF28a745),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  shareUrl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchPhone() async {
    final phone = '+919876543210';
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String name) async {
    final phone = '919876543210';
    final msg = Uri.encodeComponent(
      "I'm interested in your listing for the $name",
    );
    final url = 'https://wa.me/$phone?text=$msg';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
