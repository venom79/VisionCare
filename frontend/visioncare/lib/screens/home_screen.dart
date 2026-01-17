import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/followup_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _role;
  String? _userName;

  List<dynamic> _followups = [];
  bool _loadingFollowups = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // 🔑 ALWAYS reload auth state
  Future<void> _loadUser() async {
    final role = await AuthService.getUserRole();
    final name = await AuthService.getUserName();

    if (!mounted) return;

    setState(() {
      _role = role;
      _userName = name;
    });

    if (role == 'PATIENT') {
      _loadFollowups();
    } else {
      _followups = [];
    }
  }

  Future<void> _loadFollowups() async {
    setState(() => _loadingFollowups = true);

    try {
      final data = await FollowupService.getPendingFollowups();
      if (!mounted) return;
      setState(() => _followups = data);
    } catch (_) {
      // optional UX
    } finally {
      if (mounted) setState(() => _loadingFollowups = false);
    }
  }

  bool get isLoggedIn => _role != null;
  bool get isPatient => _role == 'PATIENT';
  bool get isDoctor => _role == 'DOCTOR';

  // ================= REMINDER =================
  Widget _buildReminderCard(BuildContext context) {
    if (_followups.isEmpty) return const SizedBox.shrink();

    final item = _followups.first;
    final dueDate = DateTime.parse(item['due_date']);
    final formatted =
        '${dueDate.day}/${dueDate.month}/${dueDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.orange.shade50,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.orange.shade200),
        ),
        child: ListTile(
          leading:
              const Icon(Icons.notifications_active, color: Colors.orange),
          title: const Text(
            'Next Eye Scan Due',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${item['message']}\nDue on: $formatted'),
          trailing: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.scan);
            },
            child: const Text('Scan'),
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 26),
            const SizedBox(width: 8),
            const Text(
              'VisionCare',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        // 🔥 THIS PART IS NOW CORRECT
        actions: [
          if (!isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                  );
                  if (result == true) {
                    await _loadUser(); // ✅ RELOAD
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.register,
                  );
                  if (result == true) {
                    await _loadUser(); // ✅ RELOAD
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],

          if (isLoggedIn)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade300,
                  child: Text(
                    _userName != null && _userName!.isNotEmpty
                        ? _userName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HERO =================
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/visioncareHero.png',
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'VisionCare',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isLoggedIn
                        ? 'Welcome, $_userName'
                        : 'AI-powered cataract screening using eye images',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            if (isPatient && !_loadingFollowups)
              _buildReminderCard(context),

            // ================= FEATURES =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // -------- FIRST CARD --------
                  Expanded(
                    child: ActionCard(
                      compact: true,
                      title: isDoctor ? 'Pending' : 'Scan',
                      icon: isDoctor ? Icons.pending_actions : Icons.camera_alt,
                      onTap: () {
                        if (!isLoggedIn) {
                          Navigator.pushNamed(context, AppRoutes.login);
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          isDoctor ? AppRoutes.doctorPending : AppRoutes.scan,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // -------- SECOND CARD --------
                  Expanded(
                    child: ActionCard(
                      compact: true,
                      title: isDoctor ? 'Reviewed' : 'History',
                      icon: isDoctor ? Icons.fact_check : Icons.history,
                      onTap: () {
                        if (!isLoggedIn) {
                          Navigator.pushNamed(context, AppRoutes.login);
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          isDoctor ? AppRoutes.doctorReviewed : AppRoutes.history,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // -------- THIRD CARD --------
                  Expanded(
                    child: ActionCard(
                      compact: true,
                      title: isDoctor ? 'Overview' : 'Progress',
                      icon: isDoctor ? Icons.analytics : Icons.trending_up,
                      onTap: () {
                        if (!isLoggedIn) {
                          Navigator.pushNamed(context, AppRoutes.login);
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          isDoctor
                              ? AppRoutes.doctorMetrics   // 👈 NEW
                              : AppRoutes.progress,
                        );
                      },
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
