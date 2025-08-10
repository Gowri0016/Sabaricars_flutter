import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vehicle_card.dart';
import 'vehicle_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final String searchQuery;
  const HomeScreen({super.key, this.searchQuery = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> vehicles = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      fetchVehicles();
    }
  }

  Future<void> fetchVehicles() async {
    setState(() => loading = true);
    final querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('vehicles')
        .get();
    var items = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
    if (widget.searchQuery.isNotEmpty) {
      final q = widget.searchQuery.toLowerCase();
      items = items.where((v) {
        final name = (v['name'] ?? '').toString().toLowerCase();
        final model = (v['model'] ?? '').toString().toLowerCase();
        return name.contains(q) || model.contains(q);
      }).toList();
    }
    setState(() {
      vehicles = items;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Available Vehicles',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (vehicles.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: widget.searchQuery.isNotEmpty
                      ? Text('No vehicles found for "${widget.searchQuery}".')
                      : const Text('No vehicles found.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vehicles.length,
                itemBuilder: (context, idx) {
                  final vehicle = vehicles[idx];
                  return VehicleCard(
                    vehicle: vehicle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VehicleDetailsScreen(vehicle: vehicle),
                        ),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Can't find what you're looking for?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to Contact Us or Request Vehicle
                      Navigator.pushNamed(context, '/request');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0a7cff),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Contact Our Specialists'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
