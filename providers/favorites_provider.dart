import 'package:flutter/material.dart';
import '../models/transport_route.dart';
import '../models/travel_note.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  List<TransportRoute> _favoriteRoutes = [];
  List<TravelNote> _travelNotes = [];

  List<TransportRoute> get favoriteRoutes => _favoriteRoutes;
  List<TravelNote> get travelNotes => _travelNotes;

  FavoritesProvider() {
    _loadData();
  }

  void _loadData() {
    _favoriteRoutes = StorageService.loadFavorites();
    _travelNotes = StorageService.loadTravelNotes();
    notifyListeners();
  }

  // --- Favorites CRUD ---
  bool isFavorite(String routeId) {
    return _favoriteRoutes.any((r) => r.id == routeId || (r.source == _findRouteSource(routeId) && r.destination == _findRouteDest(routeId)));
  }

  String _findRouteSource(String id) => '';
  String _findRouteDest(String id) => '';

  Future<void> toggleFavorite(TransportRoute route) async {
    final index = _favoriteRoutes.indexWhere((r) => r.source == route.source && r.destination == route.destination && r.transportMode == route.transportMode);
    if (index >= 0) {
      _favoriteRoutes.removeAt(index);
    } else {
      _favoriteRoutes.insert(0, route);
    }
    await StorageService.saveFavorites(_favoriteRoutes);
    notifyListeners();
  }

  Future<void> removeFavorite(int index) async {
    if (index >= 0 && index < _favoriteRoutes.length) {
      _favoriteRoutes.removeAt(index);
      await StorageService.saveFavorites(_favoriteRoutes);
      notifyListeners();
    }
  }

  // --- Travel Notes CRUD Operations ---
  Future<void> addTravelNote({
    required String title,
    required String content,
    required String routeName,
    String reminderTime = '',
  }) async {
    final newNote = TravelNote(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      routeName: routeName,
      createdAt: DateTime.now().toString().split('.')[0],
      reminderTime: reminderTime,
      isPinned: false,
    );

    _travelNotes.insert(0, newNote);
    await StorageService.saveTravelNotes(_travelNotes);
    notifyListeners();
  }

  Future<void> updateTravelNote(TravelNote updatedNote) async {
    final index = _travelNotes.indexWhere((n) => n.id == updatedNote.id);
    if (index >= 0) {
      _travelNotes[index] = updatedNote;
      await StorageService.saveTravelNotes(_travelNotes);
      notifyListeners();
    }
  }

  Future<void> deleteTravelNote(String id) async {
    _travelNotes.removeWhere((n) => n.id == id);
    await StorageService.saveTravelNotes(_travelNotes);
    notifyListeners();
  }

  Future<void> togglePinNote(String id) async {
    final index = _travelNotes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final current = _travelNotes[index];
      _travelNotes[index] = current.copyWith(isPinned: !current.isPinned);
      // Sort pinned first
      _travelNotes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
      await StorageService.saveTravelNotes(_travelNotes);
      notifyListeners();
    }
  }
}
