import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'routes/route_search_screen.dart';
import 'stops/nearby_stops_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';

class HomeNavContainer extends StatefulWidget {
  const HomeNavContainer({super.key});

  @override
  State<HomeNavContainer> createState() => _HomeNavContainerState();
}

class _HomeNavContainerState extends State<HomeNavContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RouteSearchScreen(),
    NearbyStopsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route_rounded),
            label: 'Routes',
          ),
          NavigationDestination(
            icon: Icon(Icons.pin_drop_outlined),
            selectedIcon: Icon(Icons.pin_drop_rounded),
            label: 'Stops',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
