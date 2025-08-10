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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe8f0fe), Color(0xFFf7f9fb)],
          ),
        ),
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
                      Icon(Icons.category_rounded, size: 32, color: Color(0xFF5b8df6)),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
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
                        ? const Text('No categories found.', style: TextStyle(color: Colors.grey, fontSize: 18))
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 22,
                              mainAxisSpacing: 22,
                              childAspectRatio: 2.8,
                            ),
                            itemCount: categories.length,
                            itemBuilder: (context, idx) {
                              final cat = categories[idx];
                              final isSelected = selectedCategory != null &&
                                  ((selectedCategory!['id'] != null &&
                                          cat['id'] != null &&
                                          selectedCategory!['id'] == cat['id']) ||
                                      (selectedCategory!['name'] != null &&
                                          cat['name'] != null &&
                                          selectedCategory!['name'] == cat['name']));
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => handleCategoryClick(cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.ease,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF5b8df6)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2563eb)
                                          : const Color(0xFFe3e9ff),
                                      width: isSelected ? 2.5 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? const Color(0xFF5b8df6).withOpacity(0.10)
                                            : const Color(0xFF3c3c3c).withOpacity(0.05),
                                        blurRadius: isSelected ? 18 : 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: isSelected
                                            ? Colors.white
                                            : const Color(0xFFe3e9ff),
                                        radius: 22,
                                        child: Icon(
                                          cat['icon'] ?? Icons.directions_car,
                                          color: isSelected
                                              ? const Color(0xFF5b8df6)
                                              : const Color(0xFF2563eb),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          cat['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF1a2236),
                                            letterSpacing: 0.01,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
