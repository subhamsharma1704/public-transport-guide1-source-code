import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/transit_provider.dart';
import '../../services/transit_api_service.dart';
import '../../widgets/stop_tile.dart';

class NearbyStopsScreen extends StatefulWidget {
  const NearbyStopsScreen({super.key});

  @override
  State<NearbyStopsScreen> createState() => _NearbyStopsScreenState();
}

class _NearbyStopsScreenState extends State<NearbyStopsScreen> {
  String _selectedFilter = 'All'; // All, Bus, Metro / Train

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transit = Provider.of<TransitProvider>(context);

    final filteredStops = _selectedFilter == 'All'
        ? transit.nearbyStops
        : transit.nearbyStops.where((s) => s.type.toLowerCase().contains(_selectedFilter.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stops & Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              transit.fetchNearbyStops(transit.sourceLat, transit.sourceLng);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Map Header with Stop Markers
          SizedBox(
            height: 200,
            width: double.infinity,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(transit.sourceLat, transit.sourceLng),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.yatrabuddy.app',
                ),
                MarkerLayer(
                  markers: [
                    // User current location marker
                    Marker(
                      point: LatLng(transit.sourceLat, transit.sourceLng),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
                    ),
                    // Transit stop markers from Overpass API
                    ...transit.nearbyStops.map((stop) => Marker(
                          point: LatLng(stop.lat, stop.lng),
                          width: 32,
                          height: 32,
                          child: Icon(
                            stop.type.contains('Metro') || stop.type.contains('Train') ? Icons.train : Icons.directions_bus,
                            color: Colors.deepOrange,
                            size: 24,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),

          // Filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.cardColor,
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedFilter == 'All',
                  onSelected: (_) => setState(() => _selectedFilter = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bus Stops'),
                  selected: _selectedFilter == 'Bus',
                  onSelected: (_) => setState(() => _selectedFilter = 'Bus'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Metro/Trains'),
                  selected: _selectedFilter == 'Metro',
                  onSelected: (_) => setState(() => _selectedFilter = 'Metro'),
                ),
              ],
            ),
          ),

          // List of live stops
          Expanded(
            child: transit.isLoadingStops
                ? const Center(child: CircularProgressIndicator())
                : filteredStops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('No transit stops found for selected filter.'),
                            TextButton(
                              onPressed: () => transit.fetchNearbyStops(transit.sourceLat, transit.sourceLng),
                              child: const Text('Refresh from OpenStreetMap'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredStops.length,
                        itemBuilder: (ctx, i) {
                          final stop = filteredStops[i];
                          return StopTile(
                            stop: stop,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (_) => _buildStopDetailsSheet(context, stop),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopDetailsSheet(BuildContext context, dynamic stop) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stop.type,
                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              if (stop.distanceInKm != null)
                Text(
                  '${stop.distanceInKm} km away',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stop.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (stop.operator != null) ...[
            Text('Operator: ${stop.operator}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
          ],
          if (stop.lineInfo != null) ...[
            Text('Available Lines: ${stop.lineInfo}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
          ],
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    final transit = Provider.of<TransitProvider>(context, listen: false);
                    transit.selectDestLocation(
                      // Place suggestion from stop
                      dynamicPlace(stop.name, stop.lat, stop.lng),
                    );
                    Navigator.pop(context); // back to search/dashboard
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigate Here'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  dynamic dynamicPlace(String name, double lat, double lng) {
    return PlaceSuggestion(displayName: name, lat: lat, lon: lng, type: 'stop');
  }
}
