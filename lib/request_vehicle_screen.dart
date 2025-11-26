import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestVehicleScreen extends StatelessWidget {
  const RequestVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? name, phone, vehicleType, details;
    return Scaffold(
      appBar: AppBar(title: const Text('Request a Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Let us know what vehicle you are looking for!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your name' : null,
                onSaved: (v) => name = v,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your phone number' : null,
                onSaved: (v) => phone = v,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type/Model',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter vehicle type/model' : null,
                onSaved: (v) => vehicleType = v,
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (v) => details = v,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You must be logged in to submit a request.',
                          ),
                        ),
                      );
                      return;
                    }
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('requests')
                          .add({
                            'name': name,
                            'phone': phone,
                            'vehicleType': vehicleType,
                            'details': details,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request submitted successfully!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to submit request: $e')),
                      );
                    }
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
