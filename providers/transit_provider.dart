import 'package:flutter/material.dart';
import '../models/transport_route.dart';
import '../models/transit_stop.dart';
import '../services/transit_api_service.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

class TransitProvider extends ChangeNotifier {
  // Search state
  String _sourceCity = 'Connaught Place, Delhi';
  double _sourceLat = 28.6304;
  double _sourceLng = 77.2177;

  String _destCity = 'Noida Sector 62, Uttar Pradesh';
  double _destLat = 28.6280;
  double _destLng = 77.3752;

  String _selectedModeFilter = 'All'; // All, Bus, Metro Line, AC Express Bus

  List<PlaceSuggestion> _sourceSuggestions = [];
  List<PlaceSuggestion> _destSuggestions = [];
  bool _isSearchingSuggestions = false;

  // Route results
  List<TransportRoute> _calculatedRoutes = [];
  TransportRoute? _selectedRoute;
  bool _isLoadingRoutes = false;
  String? _routeError;

  // Nearby stops
  List<TransitStop> _nearbyStops = [];
  bool _isLoadingStops = false;
  String? _stopsError;

  // Live Weather & Advisories
  WeatherInfo _liveWeather = WeatherInfo.defaultWeather();
  bool _isLoadingWeather = false;

  // Recent searches
  List<String> _recentSearches = [];

  // Getters
  String get sourceCity => _sourceCity;
  double get sourceLat => _sourceLat;
  double get sourceLng => _sourceLng;
  String get destCity => _destCity;
  double get destLat => _destLat;
  double get destLng => _destLng;
  String get selectedModeFilter => _selectedModeFilter;

  List<PlaceSuggestion> get sourceSuggestions => _sourceSuggestions;
  List<PlaceSuggestion> get destSuggestions => _destSuggestions;
  bool get isSearchingSuggestions => _isSearchingSuggestions;

  List<TransportRoute> get calculatedRoutes {
    if (_selectedModeFilter == 'All') return _calculatedRoutes;
    return _calculatedRoutes.where((r) => r.transportMode.toLowerCase().contains(_selectedModeFilter.toLowerCase())).toList();
  }

  TransportRoute? get selectedRoute => _selectedRoute;
  bool get isLoadingRoutes => _isLoadingRoutes;
  String? get routeError => _routeError;

  List<TransitStop> get nearbyStops => _nearbyStops;
  bool get isLoadingStops => _isLoadingStops;
  String? get stopsError => _stopsError;

  WeatherInfo get liveWeather => _liveWeather;
  bool get isLoadingWeather => _isLoadingWeather;
  List<String> get recentSearches => _recentSearches;

  TransitProvider() {
    _recentSearches = StorageService.loadRecentSearches();
    // Initial fetch for nearby stops & weather
    fetchNearbyStops(_sourceLat, _sourceLng);
    fetchWeather(_sourceLat, _sourceLng);
    // Calculate initial sample route
    searchRoutes();
  }

  void setModeFilter(String filter) {
    _selectedModeFilter = filter;
    notifyListeners();
  }

  void selectRoute(TransportRoute route) {
    _selectedRoute = route;
    notifyListeners();
  }

  Future<void> searchSourceSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _sourceSuggestions = [];
      notifyListeners();
      return;
    }
    _isSearchingSuggestions = true;
    notifyListeners();

    _sourceSuggestions = await TransitApiService.searchPlaces(query);
    _isSearchingSuggestions = false;
    notifyListeners();
  }

  Future<void> searchDestSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _destSuggestions = [];
      notifyListeners();
      return;
    }
    _isSearchingSuggestions = true;
    notifyListeners();

    _destSuggestions = await TransitApiService.searchPlaces(query);
    _isSearchingSuggestions = false;
    notifyListeners();
  }

  void selectSourceLocation(PlaceSuggestion place) {
    _sourceCity = place.displayName.split(',').take(2).join(',').trim();
    _sourceLat = place.lat;
    _sourceLng = place.lon;
    _sourceSuggestions = [];
    notifyListeners();
    fetchNearbyStops(_sourceLat, _sourceLng);
    fetchWeather(_sourceLat, _sourceLng);
  }

  void selectDestLocation(PlaceSuggestion place) {
    _destCity = place.displayName.split(',').take(2).join(',').trim();
    _destLat = place.lat;
    _destLng = place.lon;
    _destSuggestions = [];
    notifyListeners();
  }

  void swapLocations() {
    final tempName = _sourceCity;
    final tempLat = _sourceLat;
    final tempLng = _sourceLng;

    _sourceCity = _destCity;
    _sourceLat = _destLat;
    _sourceLng = _destLng;

    _destCity = tempName;
    _destLat = tempLat;
    _destLng = tempLng;

    notifyListeners();
    searchRoutes();
  }

  Future<void> searchRoutes() async {
    _isLoadingRoutes = true;
    _routeError = null;
    notifyListeners();

    try {
      final routes = await TransitApiService.calculateRoutes(
        sourceName: _sourceCity,
        sourceLat: _sourceLat,
        sourceLng: _sourceLng,
        destName: _destCity,
        destLat: _destLat,
        destLng: _destLng,
      );

      _calculatedRoutes = routes;
      if (routes.isNotEmpty) {
        _selectedRoute = routes.first;
      }

      // Add to recent search queries
      final searchStr = '$_sourceCity to $_destCity';
      if (!_recentSearches.contains(searchStr)) {
        _recentSearches.insert(0, searchStr);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
        await StorageService.saveRecentSearches(_recentSearches);
      }
    } catch (e) {
      _routeError = 'Could not fetch live routes. Check network or retry.';
    }

    _isLoadingRoutes = false;
    notifyListeners();
  }

  Future<void> fetchNearbyStops(double lat, double lng) async {
    _isLoadingStops = true;
    _stopsError = null;
    notifyListeners();

    try {
      _nearbyStops = await TransitApiService.fetchNearbyStops(lat: lat, lng: lng);
    } catch (e) {
      _stopsError = 'Failed to fetch live nearby stops';
    }

    _isLoadingStops = false;
    notifyListeners();
  }

  Future<void> fetchWeather(double lat, double lng) async {
    _isLoadingWeather = true;
    notifyListeners();

    _liveWeather = await WeatherService.fetchLiveTransitWeather(lat, lng);
    _isLoadingWeather = false;
    notifyListeners();
  }
}
