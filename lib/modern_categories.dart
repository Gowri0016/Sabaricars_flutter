import 'package:flutter/material.dart';

import 'firebase_service.dart';

import 'vehicle_details_screen.dart';
import 'category_vehicles_screen.dart';

class ModernCategories extends StatefulWidget {
  const ModernCategories({super.key});

  @override
  State<ModernCategories> createState() => _ModernCategoriesState();
}

class _ModernCategoriesState extends State<ModernCategories> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> categories = [];
  Map<String, dynamic>? selectedCategory;
  List<Map<String, dynamic>> vehicles = [];
  bool loadingCategories = true;
  bool loadingVehicles = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      loadingCategories = true;
    });
    // Assuming _firebaseService.getCategories() returns Future<List<Map<String, dynamic>>>
    final cats = await _firebaseService.getCategories();
    setState(() {
      categories = cats;
      loadingCategories = false;
    });
  }

  Future<void> fetchVehiclesByCategory(
    String categoryId,
    String categoryName,
  ) async {
    setState(() {
      loadingVehicles = true;
    });
    // Try both id and name for compatibility
    final items = await _firebaseService.getVehiclesByCategory(categoryId);
    if (items.isEmpty) {
      final itemsByName = await _firebaseService.getVehiclesByCategory(
        categoryName,
      );
      setState(() {
        vehicles = itemsByName;
        loadingVehicles = false;
      });
    } else {
      setState(() {
        vehicles = items;
        loadingVehicles = false;
      });
    }
  }

  void handleCategoryClick(Map<String, dynamic> cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryVehiclesScreen(category: cat),
      ),
    );
  }

  void handleVehicleTap(Map<String, dynamic> vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 36,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12),
                      const Text(
                        'Browse by Category',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a2236),
                          letterSpacing: 0.02,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Find your perfect vehicle by selecting a category below.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  loadingCategories
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: CircularProgressIndicator(
                            color: Color(0xFF5b8df6),
                          ),
                        )
                      : categories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No categories found.',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        )
                      : Column(
                          children: [
                            for (final cat in categories)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => handleCategoryClick(cat),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFe3e9ff),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(8),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    child: Center(
                                      child: Text(
                                        cat['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1a2236),
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
