import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLogin = true;
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  String role = 'farmer';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [cs.primaryContainer, cs.primary.withOpacity(0.12)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)))),
        Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.agriculture, color: cs.primary, size: 28),
                    const SizedBox(width: 8),
                    Text('Kisan Khata',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                  ]),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(segments: const [
                    ButtonSegment(value: true, label: Text('Login')),
                    ButtonSegment(value: false, label: Text('Sign up'))
                  ], selected: {
                    isLogin
                  }, onSelectionChanged: (s) => setState(() => isLogin = s.first)),
                  const SizedBox(height: 16),
                  if (!isLogin) ...[
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
                    const SizedBox(height: 12),
                  ],

                  TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 12),
                  if (!isLogin) _RoleSelector(onChanged: (v) => setState(() => role = v)),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: Icon(isLogin ? Icons.login : Icons.app_registration),
                        label: Text(loading
                            ? 'Please wait...'
                            : isLogin
                                ? 'Login'
                                : 'Create account'),
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() => loading = true);
                                try {
                                  if (isLogin) {
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                                        email: email.text.trim(), password: pass.text.trim());
                                  } else {
                                    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: email.text.trim(), password: pass.text.trim());
                                    await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
                                      'name': name.text.trim(),
                                      'email': email.text.trim(),
                                      'role': role,
                                      'createdAt': DateTime.now(),
                                    });
                                  }
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
                                } finally {
                                  if (mounted) setState(() => loading = false);
                                }
                              },
                      )),
                ]),
              )),
        )),
      ]),
    );
  }
}

class _RoleSelector extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _RoleSelector({required this.onChanged});

  @override
  State<_RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<_RoleSelector> {
  String value = 'farmer';

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Select Role'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        ChoiceChip(
            selected: value == 'farmer',
            label: const Text('Farmer'),
            onSelected: (_) {
              setState(() => value = 'farmer');
              widget.onChanged('farmer');
            }),
        ChoiceChip(
            selected: value == 'admin',
            label: const Text('Admin'),
            onSelected: (_) {
              setState(() => value = 'admin');
              widget.onChanged('admin');
            }),
      ]),
    ]);
  }
}
