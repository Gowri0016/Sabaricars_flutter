import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getVehiclesByCategory(
    String categoryName,
  ) async {
    // Fetch all vehicles directly from the vehicles subcollection under the selected category
    final snapshot = await _db
        .collection('vehicleDetails')
        .doc(categoryName)
        .collection('vehicles')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>?> getVehicleDetails(String vehicleId) async {
    final doc = await _db.collection('vehicles').doc(vehicleId).get();
    return doc.data();
  }

  // Wishlist Firestore logic
  Future<void> addToWishlist(String userId, Map<String, dynamic> vehicle) async {
    final vehicleId = vehicle['id'] ?? vehicle['name'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    print('addToWishlist: userId=$userId, vehicleId=$vehicleId');
    await _db.collection('users').doc(userId).collection('wishlists').doc(vehicleId).set({
      ...vehicle,
      'wishlistedAt': DateTime.now(),
      'id': vehicleId,
    });
  }

  Future<void> removeFromWishlist(String userId, String vehicleId) async {
    await _db.collection('users').doc(userId).collection('wishlists').doc(vehicleId).delete();
  }

  Future<bool> isWishlisted(String userId, String vehicleId) async {
    final doc = await _db.collection('users').doc(userId).collection('wishlists').doc(vehicleId).get();
    return doc.exists;
  }
}

