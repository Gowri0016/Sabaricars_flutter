import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'bottom_navbar.dart';
import 'app_drawer.dart';
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int activeImage = 0;
  bool isFavorite = false;
  bool wishlistLoading = false;
  String? successMsg;

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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onSubmitted: (value) {
              // Optionally, you can handle search here or via callback
            },
          ),
        ),
        centerTitle: true,
      ),
      drawer: AppDrawer(
        onNavSelected: (index) {
          Navigator.of(context).pop();
          // Optionally, you can provide a callback to MainWrapper to change tab
        },
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex:
            0, // Set Home as selected for details, or pass previous tab
        onTap: (index) {
          Navigator.of(context).pop();
          // Optionally, you can provide a callback to MainWrapper to change tab
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 68),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Action Bar
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.share, color: Color(0xFF007bff)),
                        onPressed: () => _handleShare(context, name),
                        tooltip: 'Share',
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Color(0xFFE0245E)
                              : Color(0xFFDC3545),
                        ),
                        onPressed: wishlistLoading
                            ? null
                            : _handleToggleFavorite,
                        tooltip: isFavorite
                            ? 'Remove from Wishlist'
                            : 'Add to Wishlist',
                      ),
                    ],
                  ),
                  if (successMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: successMsg != null ? 1 : 0,
                          duration: const Duration(milliseconds: 350),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              successMsg!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Gallery Section
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: hasImages
                            ? Image.network(
                                images[activeImage],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (ctx, err, stack) =>
                                    _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ),
                    ),
                  ),
                  if (hasImages && images.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            return GestureDetector(
                              onTap: () => setState(() => activeImage = idx),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: idx == activeImage
                                        ? Color(0xFF007bff)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    images[idx],
                                    width: 80,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        _imagePlaceholder(small: true),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  // Title & Subtitle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (featured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF5722),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      if (vehicle['variant'] != null)
                        _iconText(Icons.settings, vehicle['variant']),
                      if (vehicle['year'] != null)
                        _iconText(Icons.calendar_today, vehicle['year']),
                      if (vehicle['fuelType'] != null)
                        _iconText(Icons.local_gas_station, vehicle['fuelType']),
                      if (vehicle['transmission'] != null)
                        _iconText(Icons.swap_horiz, vehicle['transmission']),
                    ],
                  ),
                  // Price
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 18),
                    padding: const EdgeInsets.all(16),
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
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'On-Road Price',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Key Specs
                  const SizedBox(height: 8),
                  const Text(
                    'Key Specifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _specsGrid(vehicle),
                  // Condition Report
                  if (vehicle['inspection'] != null &&
                      vehicle['inspection'] is Map)
                    _conditionSection(vehicle['inspection'] as Map),
                  // Refurbishment
                  if (vehicle['refurbishment'] != null &&
                      vehicle['refurbishment'] is Map)
                    _refurbSection(vehicle['refurbishment'] as Map),
                  // Finance
                  if (vehicle['financial'] != null &&
                      vehicle['financial'] is Map)
                    _financeSection(vehicle['financial'] as Map),
                  // Video
                  if (vehicle['visuals'] != null &&
                      vehicle['visuals']['video'] != null)
                    _videoSection(vehicle['visuals']['video']),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Call Seller'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF28a745),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _launchPhone(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
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

  Widget _iconText(IconData icon, String? text) {
    if (text == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Color(0xFF007bff)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '-';
    try {
      if (price is int) {
        return '₹${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => ",${m[1]}")}';
      } else if (price is String) {
        return '₹$price';
      }
    } catch (_) {}
    return '₹$price';
  }

  Widget _specsGrid(Map vehicle) {
    final List<Widget> cards = [
      _specCard(
        Icons.trending_up,
        'Odometer',
        vehicle['odometer']?.toString(),
        suffix: ' km',
      ),
      _specCard(Icons.person, 'Owners', vehicle['owners']?.toString()),
      _specCard(Icons.map, 'Registration', vehicle['registration']),
      _specCard(Icons.shield, 'Insurance', vehicle['insuranceValidity']),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: cards,
      ),
    );
  }

  Widget _specCard(
    IconData icon,
    String label,
    String? value, {
    String? suffix,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE9ECEF),
              shape: BoxShape.circle,
            ),
            width: 36,
            height: 36,
            child: Icon(icon, color: Color(0xFF007bff), size: 20),
          ),
          const SizedBox(width: 8),
          Flexible(
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionSection(Map inspection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF007bff)),
            SizedBox(width: 8),
            Text(
              'Vehicle Condition Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            ...inspection.entries.map((e) => _conditionItem(e.key, e.value)),
          ],
        ),
      ],
    );
  }

  Widget _conditionItem(String key, dynamic value) {
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
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              key
                  .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                  .replaceFirstMapped(
                    RegExp(r'^.'),
                    (m) => m[0]!.toUpperCase(),
                  ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            valStr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _refurbSection(Map refurbishment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: const [
            Icon(Icons.trending_up, color: Color(0xFF007bff)),
            SizedBox(width: 8),
            Text(
              'Refurbishment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...refurbishment.entries.map((e) => _refurbItem(e.key, e.value)),
      ],
    );
  }

  Widget _refurbItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key
                .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                .replaceFirstMapped(RegExp(r'^.'), (m) => m[0]!.toUpperCase()),
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          if (value is List)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...value.map(
                    (v) => Text('- $v', style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            )
          else
            Text(value.toString(), style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _financeSection(Map financial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: const [
            Icon(Icons.attach_money, color: Color(0xFF007bff)),
            SizedBox(width: 8),
            Text(
              'Finance Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            ...financial.entries.map((e) => _financeCard(e.key, e.value)),
          ],
        ),
      ],
    );
  }

  Widget _financeCard(String key, dynamic value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key
                .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                .replaceFirstMapped(RegExp(r'^.'), (m) => m[0]!.toUpperCase()),
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4),
          (value is bool)
              ? Text(
                  value ? '✓ Available' : '✗ Not Available',
                  style: TextStyle(
                    color: value ? Color(0xFF28a745) : Color(0xFFDC3545),
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _videoSection(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: const [
            Icon(Icons.ondemand_video, color: Color(0xFF007bff)),
            SizedBox(width: 8),
            Text(
              'Video Walkthrough',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: url.isNotEmpty
                ? (url.contains('youtube.com') || url.contains('youtu.be'))
                      ? _youtubePlayer(url)
                      : _webVideo(url)
                : const Center(child: Text('No Video')),
          ),
        ),
      ],
    );
  }

  Widget _youtubePlayer(String url) {
    // For simplicity, just show a clickable thumbnail
    final videoId = _extractYouTubeId(url);
    if (videoId == null) {
      return Center(child: Text('Invalid YouTube URL'));
    }
    final thumbUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(thumbUrl, fit: BoxFit.cover),
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
          ),
        ],
      ),
    );
  }

  Widget _webVideo(String url) {
    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        color: Colors.black12,
        child: const Center(child: Icon(Icons.play_circle_fill, size: 64)),
      ),
    );
  }

  String? _extractYouTubeId(String url) {
    final regExp = RegExp(r'(?:v=|be/)([\w-]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Widget _imagePlaceholder({bool small = false}) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              color: Colors.grey,
              size: small ? 32 : 48,
            ),
            const SizedBox(height: 4),
            Text(
              'No Images',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: small ? 11 : 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleShare(BuildContext context, String name) async {
    final vehicle = widget.vehicle;
    final String baseUrl = 'https://sabaricars.com/vehicle';
    final String vehicleId = vehicle['id']?.toString() ?? '';
    final String shareUrl = vehicleId.isNotEmpty ? '$baseUrl/$vehicleId' : baseUrl;
    final String text = 'Check out this vehicle on Sabari Cars: $name\n$shareUrl';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, color: Color(0xFF2563eb), size: 28),
                    const SizedBox(width: 10),
                    Text('Share Vehicle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF222222))),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563eb),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.apps),
                  label: const Text('Share via...'),
                  onPressed: () {
                    Share.share(text);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F6FA),
                    foregroundColor: const Color(0xFF2563eb),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.link),
                  label: const Text('Copy Link'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: shareUrl));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check, color: Color(0xFF2563eb)),
                            SizedBox(width: 8),
                            Text('Link copied to clipboard!'),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  shareUrl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleToggleFavorite() async {
    setState(() => wishlistLoading = true);
    final userId =
        await _getUserId(); // Implement this to get the current user ID
    if (userId == null) {
      setState(() {
        wishlistLoading = false;
        successMsg = 'Please log in to use wishlist.';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => successMsg = null);
      });
      return;
    }
    final vehicle = widget.vehicle;
    try {
      print('userId: $userId, vehicleId: ${vehicle['id']}');
      if (isFavorite) {
        await _firebaseService.removeFromWishlist(userId, vehicle['id']);
        print('Removed vehicle from wishlist');
        setState(() {
          isFavorite = false;
          successMsg = 'Removed from wishlist';
        });
      } else {
        await _firebaseService.addToWishlist(userId, vehicle);
        print('Added vehicle to wishlist');
        setState(() {
          isFavorite = true;
          successMsg = 'Added to wishlist!';
        });
      }
    } catch (e) {
      setState(() {
        successMsg = 'Error updating wishlist.';
      });
    } finally {
      setState(() => wishlistLoading = false);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => successMsg = null);
      });
    }
  }

  Future<String?> _getUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
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
