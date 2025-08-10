import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class VehicleCard extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback? onTap;
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isFavorite = false;
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
    final text = 'Check out this vehicle on Sabari Cars: $name';
    // You can use Share.share from share_plus package for real sharing
    final snackBar = SnackBar(content: Text('Share: $text'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _handleToggleFavorite() async {
    setState(() => wishlistLoading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
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
    try {
      if (isFavorite) {
        await _firebaseService.removeFromWishlist(userId, widget.vehicle['id']);
        setState(() {
          isFavorite = false;
          successMsg = 'Removed from wishlist';
        });
      } else {
        await _firebaseService.addToWishlist(userId, widget.vehicle);
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Share and Wishlist buttons
            Stack(
              children: [
                Container(height: 48), // Reserve space for buttons
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
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
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Success message
            if (successMsg != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            // Image wrapper
            Container(
              width: double.infinity,
              height:
                  MediaQuery.of(context).size.width *
                  9 /
                  16, // 16:9 aspect ratio
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text(
                                'No Image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No Image',
                        style: TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vehicle['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        widget.vehicle['price'] != null
                            ? '₹${widget.vehicle['price']}'
                            : '',
                        style: const TextStyle(
                          color: Color(0xFF0a7cff),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (widget.vehicle['year'] != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            '${widget.vehicle['year']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      if (widget.vehicle['fuelType'] != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            '${widget.vehicle['fuelType']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.vehicle['category'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
