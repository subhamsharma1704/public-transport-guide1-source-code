import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/transport_route.dart';
import '../../providers/favorites_provider.dart';

class RouteDetailsScreen extends StatelessWidget {
  final TransportRoute route;

  const RouteDetailsScreen({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favProvider.favoriteRoutes.any((r) => r.id == route.id || (r.source == route.source && r.destination == route.destination));

    final LatLng centerPoint = route.polylinePoints.isNotEmpty
        ? route.polylinePoints[route.polylinePoints.length ~/ 2]
        : LatLng((route.sourceLat + route.destLat) / 2, (route.sourceLng + route.destLng) / 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(route.transportMode),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            tooltip: 'Add to Favorites',
            onPressed: () {
              favProvider.toggleFavorite(route);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFav ? 'Removed from favorites' : 'Saved route to favorites!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Interactive OpenStreetMap View
            SizedBox(
              height: 240,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: centerPoint,
                  initialZoom: 11.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.yatrabuddy.app',
                  ),
                  if (route.polylinePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route.polylinePoints,
                          color: theme.colorScheme.primary,
                          strokeWidth: 4.5,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // Origin Marker
                      Marker(
                        point: LatLng(route.sourceLat, route.sourceLng),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: Colors.green, size: 36),
                      ),
                      // Destination Marker
                      Marker(
                        point: LatLng(route.destLat, route.destLng),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Route Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Distance', '${route.distanceKm} km', Icons.straighten_rounded),
                  _buildSummaryItem('Est. Time', '${route.durationMinutes.toInt()} mins', Icons.timer_outlined),
                  _buildSummaryItem('Fare', '₹${route.estimatedFare.toInt()}', Icons.currency_rupee_rounded),
                  _buildSummaryItem('Status', 'Live On-Time', Icons.check_circle_outline, color: Colors.green),
                ],
              ),
            ),

            // 3. Journey Stops Timeline
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Route Stops & Timings',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Frequency: ${route.frequency} • ${route.departureTime}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Origin Stop
                  _buildTimelineTile(
                    title: route.source,
                    subtitle: 'Departure Platform / Boarding point',
                    time: '00:00 (Start)',
                    isStart: true,
                    context: context,
                  ),

                  // Intermediate Stops
                  ...route.intermediateStops.map((stopName) => _buildTimelineTile(
                        title: stopName,
                        subtitle: 'Scheduled Transit Stop',
                        time: '+ ~${(route.durationMinutes / (route.intermediateStops.length + 1)).toInt()} min',
                        context: context,
                      )),

                  // Destination Stop
                  _buildTimelineTile(
                    title: route.destination,
                    subtitle: 'Arrival Terminus',
                    time: '+ ${route.durationMinutes.toInt()} min (End)',
                    isEnd: true,
                    context: context,
                  ),
                ],
              ),
            ),

            // 4. Live Navigation Steps (Turn-by-turn OSRM Steps)
            if (route.steps.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Live Transit Legs & Directions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...route.steps.map((step) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                              child: Icon(Icons.directions, size: 18, color: theme.colorScheme.primary),
                            ),
                            title: Text(step.instruction, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text('${step.distanceKm.toStringAsFixed(1)} km • ${step.durationMins.toStringAsFixed(0)} mins', style: const TextStyle(fontSize: 11)),
                          ),
                        )),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.share_location_rounded),
            label: const Text('Share Route Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied route from ${route.source} to ${route.destination} to clipboard!'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.teal.shade800),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    required String time,
    bool isStart = false,
    bool isEnd = false,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isStart ? Icons.trip_origin : (isEnd ? Icons.location_on : Icons.circle),
              size: isStart || isEnd ? 18 : 12,
              color: isStart ? Colors.green : (isEnd ? Colors.red : Colors.grey),
            ),
            if (!isEnd)
              Container(
                height: 42,
                width: 2,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ],
    );
  }
}
