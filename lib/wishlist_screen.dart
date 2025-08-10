import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in to view your wishlist.'));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wishlists')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No vehicles in your wishlist.',
                style: TextStyle(fontSize: 18, color: Color(0xFF232323)),
              ),
            );
          }
          final wishlists = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            itemCount: wishlists.length,
            itemBuilder: (context, index) {
              final vehicle = wishlists[index].data() as Map<String, dynamic>;
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/vehicle-details',
                    arguments: vehicle,
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              vehicle['images'] != null &&
                                  (vehicle['images'] as List).isNotEmpty
                              ? Image.network(
                                  vehicle['images'][0],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: const Color(0xFFE0E7FF),
                                  child: const Icon(
                                    Icons.directions_car,
                                    size: 38,
                                    color: Color(0xFFB0B0B0),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle['name'] ?? 'Vehicle',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF232323),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                vehicle['model'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              if (vehicle['price'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '₹${vehicle['price']}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF007BFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 28,
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('wishlists')
                                .doc(vehicle['id'])
                                .delete();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
