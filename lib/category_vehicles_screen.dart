import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'vehicle_card.dart';
import 'vehicle_details_screen.dart';

class CategoryVehiclesScreen extends StatefulWidget {
  final Map<String, dynamic> category;
  const CategoryVehiclesScreen({super.key, required this.category});

  @override
  State<CategoryVehiclesScreen> createState() => _CategoryVehiclesScreenState();
}

class _CategoryVehiclesScreenState extends State<CategoryVehiclesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> vehicles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    final items = await _firebaseService.getVehiclesByCategory(
      widget.category['name'],
    );
    setState(() {
      vehicles = items;
      loading = false;
    });
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
      appBar: AppBar(title: Text('${widget.category['name']} Vehicles')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
          ? const Center(child: Text('No vehicles found in this category.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length,
              itemBuilder: (context, idx) {
                final vehicle = vehicles[idx];
                return VehicleCard(
                  vehicle: vehicle,
                  onTap: () => handleVehicleTap(vehicle),
                );
              },
            ),
    );
  }
}
