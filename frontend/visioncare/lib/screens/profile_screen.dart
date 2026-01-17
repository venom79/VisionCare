import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _role;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getUserName();
    final role = await AuthService.getUserRole();
    final email = await AuthService.getUserEmail(); 

    if (!mounted) return;

    setState(() {
      _name = name;
      _role = role;
      _email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 20),

            Text(
              _name ?? '—',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Chip(
              label: Text(_role ?? 'UNKNOWN'),
              backgroundColor:
                  _role == 'DOCTOR' ? Colors.blue.shade100 : Colors.green.shade100,
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (!mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
