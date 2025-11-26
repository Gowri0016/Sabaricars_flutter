import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

/// Reusable heart button that shows filled when the vehicle is wishlisted and
/// toggles the wishlist state for the current user.
class WishlistHeart extends StatefulWidget {
  final String vehicleId;
  final Map<String, dynamic>? vehicle;
  final double size;

  const WishlistHeart({
    super.key,
    required this.vehicleId,
    this.vehicle,
    this.size = 24,
  });

  @override
  State<WishlistHeart> createState() => _WishlistHeartState();
}

class _WishlistHeartState extends State<WishlistHeart> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isFavorite = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final inWishlist = await _firebaseService.isWishlisted(
      userId,
      widget.vehicleId,
    );
    if (mounted) setState(() => isFavorite = inWishlist);
  }

  Future<void> _toggle() async {
    setState(() => loading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        setState(() => loading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add to wishlist')),
      );
      return;
    }
    try {
      if (isFavorite) {
        await _firebaseService.removeFromWishlist(userId, widget.vehicleId);
        if (mounted) setState(() => isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('Removed from wishlist'),
              ],
            ),
            backgroundColor: Color(0xFF28a745),
            duration: Duration(milliseconds: 900),
          ),
        );
      } else {
        await _firebaseService.addToWishlist(
          userId,
          widget.vehicle ?? {'id': widget.vehicleId},
        );
        if (mounted) setState(() => isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('Added to wishlist!'),
              ],
            ),
            backgroundColor: Color(0xFF28a745),
            duration: Duration(milliseconds: 900),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating wishlist')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: loading
          ? SizedBox(
              width: widget.size,
              height: widget.size,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? const Color(0xFFE0245E)
                  : const Color(0xFFDC3545),
              size: widget.size,
            ),
      onPressed: loading ? null : _toggle,
      tooltip: isFavorite ? 'Remove from Wishlist' : 'Add to Wishlist',
    );
  }
}
