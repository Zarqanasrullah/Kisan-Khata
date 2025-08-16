
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../crops/views/admin/pending_crops_screen.dart';
import '../profile/profile_screen.dart';
import 'login_signup_screen.dart';
import '../crops/views/farmer/my_crops_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) return const LoginSignupScreen();
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final data = roleSnap.data?.data() ?? {};
            final role = (data['role'] as String?) ?? 'farmer';
            final name = (data['name'] as String?) ?? 'User';
            return _RoleScaffold(role: role, name: name, email: user.email ?? '');
          },
        );
      },
    );
  }
}
class FarmerHome extends StatelessWidget {
  const FarmerHome({super.key});
  @override
  Widget build(BuildContext context) {
    return const MyCropsScreen();
  }
}


class _RoleScaffold extends StatefulWidget {
  final String role; final String name; final String email;
  const _RoleScaffold({required this.role, required this.name, required this.email});
  @override State<_RoleScaffold> createState() => _RoleScaffoldState();
}
class _RoleScaffoldState extends State<_RoleScaffold> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == 'admin';
    final pages = [ if (isAdmin) const PendingCropsScreen() else const MyCropsScreen(), ProfileScreen(name: widget.name, email: widget.email, role: widget.role) ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}