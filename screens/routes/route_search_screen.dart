import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transit_provider.dart';
import '../../widgets/route_card.dart';
import 'route_details_screen.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  late TextEditingController _sourceController;
  late TextEditingController _destController;

  @override
  void initState() {
    super.initState();
    final transit = Provider.of<TransitProvider>(context, listen: false);
    _sourceController = TextEditingController(text: transit.sourceCity);
    _destController = TextEditingController(text: transit.destCity);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transit = Provider.of<TransitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Route Guide'),
      ),
      body: Column(
        children: [
          // Search & Inputs Card
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot and line indicator
                    Padding(
                      padding: const EdgeInsets.only(top: 14.0, right: 12),
                      child: Column(
                        children: [
                          const Icon(Icons.radio_button_checked, size: 18, color: Colors.green),
                          Container(height: 38, width: 2, color: Colors.grey.shade300),
                          const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
                        ],
                      ),
                    ),

                    // Text Fields
                    Expanded(
                      child: Column(
                        children: [
                          // Source Input
                          TextField(
                            controller: _sourceController,
                            decoration: InputDecoration(
                              labelText: 'From (Origin)',
                              hintText: 'Search city, station, bus stop...',
                              suffixIcon: transit.isSearchingSuggestions
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _sourceController.clear();
                                        transit.searchSourceSuggestions('');
                                      },
                                    ),
                            ),
                            onChanged: (val) {
                              transit.searchSourceSuggestions(val);
                            },
                          ),
                          const SizedBox(height: 10),

                          // Destination Input
                          TextField(
                            controller: _destController,
                            decoration: InputDecoration(
                              labelText: 'To (Destination)',
                              hintText: 'Search landmark, metro station...',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _destController.clear();
                                  transit.searchDestSuggestions('');
                                },
                              ),
                            ),
                            onChanged: (val) {
                              transit.searchDestSuggestions(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Swap button
                    IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, size: 26),
                      onPressed: () {
                        transit.swapLocations();
                        _sourceController.text = transit.sourceCity;
                        _destController.text = transit.destCity;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.alt_route_rounded),
                    label: const Text('Calculate Live Routes (OSRM & OSM)', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      transit.searchRoutes();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Autocomplete suggestions list (If any)
          if (transit.sourceSuggestions.isNotEmpty || transit.destSuggestions.isNotEmpty)
            Expanded(
              child: ListView(
                children: [
                  if (transit.sourceSuggestions.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text('Live Origin Suggestions (OSM):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal)),
                    ),
                    ...transit.sourceSuggestions.map((place) => ListTile(
                          leading: const Icon(Icons.place_outlined, color: Colors.teal),
                          title: Text(place.displayName, style: const TextStyle(fontSize: 13)),
                          subtitle: Text('Type: ${place.type}', style: const TextStyle(fontSize: 11)),
                          onTap: () {
                            transit.selectSourceLocation(place);
                            _sourceController.text = transit.sourceCity;
                            FocusScope.of(context).unfocus();
                          },
                        )),
                  ],
                  if (transit.destSuggestions.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text('Live Destination Suggestions (OSM):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepOrange)),
                    ),
                    ...transit.destSuggestions.map((place) => ListTile(
                          leading: const Icon(Icons.flag_outlined, color: Colors.deepOrange),
                          title: Text(place.displayName, style: const TextStyle(fontSize: 13)),
                          subtitle: Text('Type: ${place.type}', style: const TextStyle(fontSize: 11)),
                          onTap: () {
                            transit.selectDestLocation(place);
                            _destController.text = transit.destCity;
                            FocusScope.of(context).unfocus();
                          },
                        )),
                  ],
                ],
              ),
            )
          else
            // Route results list
            Expanded(
              child: transit.isLoadingRoutes
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Fetching live transit calculations & fares...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : transit.routeError != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                              const SizedBox(height: 12),
                              Text(transit.routeError!),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => transit.searchRoutes(),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: transit.calculatedRoutes.length,
                          itemBuilder: (ctx, i) {
                            final route = transit.calculatedRoutes[i];
                            return RouteCard(
                              route: route,
                              onTap: () {
                                transit.selectRoute(route);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RouteDetailsScreen(route: route),
                                  ),
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
}
