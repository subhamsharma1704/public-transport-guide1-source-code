import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = StorageService.loadProfile();
  }

  void _saveProfile() async {
    await StorageService.saveProfile(_profile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile preferences saved!')),
      );
    }
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _profile.name);
    final phoneCtrl = TextEditingController(text: _profile.phone);
    final cityCtrl = TextEditingController(text: _profile.homeCity);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Personal Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Emergency / Contact Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(labelText: 'Home City / Transit Zone'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _profile = _profile.copyWith(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  homeCity: cityCtrl.text.trim(),
                );
              });
              _saveProfile();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTeamCreditsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.groups_rounded, color: Colors.teal),
            SizedBox(width: 8),
            Text('Project Contributors'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Public Transport Guide (Yatra Buddy)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _ContributorTile(name: 'Siddhant Panchauri', role: 'Team Lead & Flutter Architecture'),
              _ContributorTile(name: 'Siddharth Singh', role: 'Route Guide & Integration'),
              _ContributorTile(name: 'Somendra Singh', role: 'Transit Data & Backend Support'),
              _ContributorTile(name: 'Som Gupta', role: 'UI Components & Navigation'),
              _ContributorTile(name: 'Subham Sharma', role: 'UI Development & Documentation'),
              Divider(height: 24),
              Text(
                'Version 1.0.0 (Live OpenStreetMap & OSRM Engine)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile & Preferences'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: theme.colorScheme.primaryContainer.withOpacity(0.35),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _profile.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _profile.email,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Details'),
                  ),
                ],
              ),
            ),

            // Transit Preferences Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Travel & Concession Preferences',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Student Pass Concession'),
                          subtitle: const Text('Apply 50% discount on public bus & metro fares'),
                          value: _profile.hasStudentPass,
                          onChanged: (val) {
                            setState(() => _profile = _profile.copyWith(hasStudentPass: val));
                            _saveProfile();
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Senior Citizen Concession'),
                          subtitle: const Text('Apply senior traveler concession rules'),
                          value: _profile.hasSeniorConcession,
                          onChanged: (val) {
                            setState(() => _profile = _profile.copyWith(hasSeniorConcession: val));
                            _saveProfile();
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Primary City / Hub'),
                          subtitle: Text(_profile.homeCity),
                          trailing: const Icon(Icons.location_city, size: 20),
                          onTap: _showEditProfileDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'App Settings & Appearance',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Dark Mode Theme'),
                          subtitle: const Text('Switch between Light and Dark interface'),
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Live Transit Notifications'),
                          subtitle: const Text('Get alerts for delays and weather changes'),
                          value: _profile.enableNotifications,
                          onChanged: (val) {
                            setState(() => _profile = _profile.copyWith(enableNotifications: val));
                            _saveProfile();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Safety & Support',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone_in_talk, color: Colors.redAccent),
                          title: const Text('National Transport Helpline (112)'),
                          subtitle: const Text('Emergency public transport distress helpline'),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dialing 112 for emergency assistance...')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline, color: Colors.teal),
                          title: const Text('Project Synopsis & Team Credits'),
                          subtitle: const Text('View team members and project contribution'),
                          onTap: _showTeamCreditsDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout Session'),
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributorTile extends StatelessWidget {
  final String name;
  final String role;

  const _ContributorTile({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(role, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
