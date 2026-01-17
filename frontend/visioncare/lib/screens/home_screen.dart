import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _role;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUser(); // initial load
  }

  Future<void> _loadUser() async {
    final role = await AuthService.getUserRole();
    final name = await AuthService.getUserName();

    if (!mounted) return;

    setState(() {
      _role = role;
      _userName = name;
    });
  }

  bool get isLoggedIn => _role != null;
  bool get isPatient => _role == 'PATIENT';
  bool get isDoctor => _role == 'DOCTOR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VisionCare'),
        centerTitle: true,
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService.logout();
                await _loadUser(); // refresh after logout
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HERO SECTION =================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade100,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/visioncareHero.png',
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'VisionCare',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isLoggedIn && _userName != null
                          ? 'Welcome, $_userName'
                          : 'AI-powered cataract screening using eye images',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= FEATURE GRID =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // -------- PATIENT --------
                  if (isPatient)
                    ActionCard(
                      title: 'Cataract Scan',
                      icon: Icons.camera_alt,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.scan);
                      },
                    ),

                  if (isPatient)
                    ActionCard(
                      title: 'Scan History',
                      icon: Icons.history,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.history);
                      },
                    ),

                  // -------- DOCTOR --------
                  if (isDoctor)
                    ActionCard(
                      title: 'Pending Reviews',
                      icon: Icons.pending_actions,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.doctorPending);
                      },
                    ),

                  if (isDoctor)
                    ActionCard(
                      title: 'Reviewed Cases',
                      icon: Icons.fact_check,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.doctorReviewed);
                      },
                    ),

                  // -------- COMMON --------
                  ActionCard(
                    title: 'Profile',
                    icon: Icons.person,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),
                ],
              ),
            ),

            // ================= AUTH BUTTONS =================
            if (!isLoggedIn)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context, AppRoutes.login);
                          await _loadUser(); // reload after login
                        },
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.login,
                          );

                          if (result == true) {
                            await _loadUser();
                          }
                        },
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
