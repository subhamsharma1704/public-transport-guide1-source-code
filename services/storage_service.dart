import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/transport_route.dart';
import '../models/travel_note.dart';

/// StorageService manages lightweight local persistence using SharedPreferences.
/// Follows standard Flutter data persistence practices.
class StorageService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserProfile = 'user_profile_data';
  static const String _keyFavoriteRoutes = 'favorite_routes_list';
  static const String _keyTravelNotes = 'travel_notes_list';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyRecentSearches = 'recent_search_queries';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService must be initialized before access');
    }
    return _prefs!;
  }

  // Auth session
  static bool isLoggedIn() => prefs.getBool(_keyIsLoggedIn) ?? false;
  
  static Future<void> setLoggedIn(bool value, {String? email}) async {
    await prefs.setBool(_keyIsLoggedIn, value);
    if (email != null) {
      await prefs.setString(_keyUserEmail, email);
    }
  }

  static String? getUserEmail() => prefs.getString(_keyUserEmail);

  static Future<void> clearAuth() async {
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserEmail);
  }

  // User Profile
  static Future<void> saveProfile(UserProfile profile) async {
    final jsonStr = jsonEncode(profile.toJson());
    await prefs.setString(_keyUserProfile, jsonStr);
  }

  static UserProfile loadProfile() {
    final jsonStr = prefs.getString(_keyUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) {
      return UserProfile.defaultUser();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (e) {
      return UserProfile.defaultUser();
    }
  }

  // Favorite Routes
  static Future<void> saveFavorites(List<TransportRoute> favorites) async {
    final list = favorites.map((r) => r.toJson()).toList();
    await prefs.setString(_keyFavoriteRoutes, jsonEncode(list));
  }

  static List<TransportRoute> loadFavorites() {
    final jsonStr = prefs.getString(_keyFavoriteRoutes);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => TransportRoute.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Travel Notes (CRUD)
  static Future<void> saveTravelNotes(List<TravelNote> notes) async {
    final list = notes.map((n) => n.toJson()).toList();
    await prefs.setString(_keyTravelNotes, jsonEncode(list));
  }

  static List<TravelNote> loadTravelNotes() {
    final jsonStr = prefs.getString(_keyTravelNotes);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => TravelNote.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Recent Searches
  static Future<void> saveRecentSearches(List<String> searches) async {
    await prefs.setStringList(_keyRecentSearches, searches);
  }

  static List<String> loadRecentSearches() {
    return prefs.getStringList(_keyRecentSearches) ?? [
      'Connaught Place to Noida Sector 62',
      'Kashmere Gate to Rajiv Chowk',
      'Hauz Khas to Gurgaon Cyber City',
    ];
  }

  // Dark Mode Theme
  static bool isDarkMode() => prefs.getBool(_keyIsDarkMode) ?? false;
  static Future<void> setDarkMode(bool isDark) async {
    await prefs.setBool(_keyIsDarkMode, isDark);
  }
}
