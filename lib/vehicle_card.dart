import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'firebase_service.dart';
import 'wishlist_heart.dart';

class VehicleCard extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback? onTap;
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  final FirebaseService _firebaseService = FirebaseService();
  // local wishlist state is handled by `WishlistHeart` widget now
  bool isFavorite =
      false; // kept for backward compatibility in case used elsewhere
  bool wishlistLoading = false;
  String? successMsg;

  @override
  void initState() {
    super.initState();
    _checkInitialWishlistState();
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
                    Text(
                      'Share Vehicle',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF222222),
                      ),
                    ),
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        );
      },
    );
  }

  // Wishlist toggling handled by `WishlistHeart` widget.

  @override
  Widget build(BuildContext context) {
    final images = widget.vehicle['images'] as List<dynamic>?;
    final String? imageUrl = (images != null && images.isNotEmpty)
        ? images[0] as String
        : null;
    final name = widget.vehicle['name'] ?? '';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icons are overlaid on the image below (no reserved top spacing)
            // Note: success messages for wishlist are handled inside WishlistHeart
            // Image wrapper with gradient and price badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 9 / 16,
                    color: const Color(0xFFF4F4F4),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Center(
                            child: Text(
                              'No Image',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                  ),
                  // overlay icons (share & wishlist) placed directly on top of the image
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Color(0xFF007bff),
                            ),
                            onPressed: () => _handleShare(context, name),
                            tooltip: 'Share',
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: WishlistHeart(
                            vehicleId:
                                widget.vehicle['id']?.toString() ??
                                widget.vehicle['name']?.toString() ??
                                '',
                            vehicle: widget.vehicle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Price badge
                  // Eye-catching price badge (gradient pill)
                  if (widget.vehicle['price'] != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              const Color(0xFF0a7cff),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPrice(widget.vehicle['price']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'On-Road',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: widget.vehicle['name'] ?? 'Vehicle',
                    header: true,
                    child: Text(
                      widget.vehicle['name'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF222222),
                          ) ??
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF222222),
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Prominent Year & Fuel pills
                  Row(
                    children: [
                      if (widget.vehicle['year'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Color(0xFF0a7cff),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.vehicle['year']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 10),
                      if (widget.vehicle['fuelType'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_gas_station,
                                size: 14,
                                color: Color(0xFF0a7cff),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.vehicle['fuelType']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),

                      // Attractive View button
                      ElevatedButton.icon(
                        onPressed: widget.onTap,
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Price on request';
    try {
      if (price is int) {
        return '₹${price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';
      } else if (price is String) {
        final cleaned = price.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleaned.isEmpty) return '₹$price';
        final numVal = int.tryParse(cleaned);
        if (numVal != null) {
          return '₹${numVal.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';
        }
        return '₹$price';
      }
    } catch (_) {}
    return price.toString();
  }
}
