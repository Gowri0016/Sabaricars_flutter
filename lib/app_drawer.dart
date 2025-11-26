import 'package:flutter/material.dart';

typedef DrawerNavCallback = void Function(int index);

class AppDrawer extends StatelessWidget {
  final DrawerNavCallback onNavSelected;
  const AppDrawer({super.key, required this.onNavSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(
              'Sabari Cars',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              onNavSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Categories'),
            onTap: () {
              Navigator.pop(context);
              onNavSelected(1);
            },
          ),

          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Wishlist'),
            onTap: () {
              Navigator.pop(context);
              onNavSelected(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              onNavSelected(4);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contact');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add_box_outlined,
              color: Colors.deepPurple,
            ),
            title: const Text('Request a Vehicle'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/request');
            },
          ),
          ListTile(
            leading: const Icon(Icons.sell, color: Colors.deepPurple),
            title: const Text('Sell Your Vehicle'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sell');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/privacy-policy');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/terms-conditions');
            },
          ),
        ],
      ),
    );
  }
}
