import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String condition;
  final String icon;
  final String travelAdvisory;

  WeatherInfo({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
    required this.icon,
    required this.travelAdvisory,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'] ?? {};
    final double temp = (current['temperature'] as num?)?.toDouble() ?? 28.0;
    final double wind = (current['windspeed'] as num?)?.toDouble() ?? 12.0;
    final int code = (current['weathercode'] as num?)?.toInt() ?? 0;

    String condition = 'Clear Sky';
    String icon = '☀️';
    String advisory = 'Ideal conditions for public transport commutes.';

    if (code == 0) {
      condition = 'Clear & Sunny';
      icon = '☀️';
      advisory = 'Great weather for bus and walking commutes.';
    } else if (code >= 1 && code <= 3) {
      condition = 'Partly Cloudy';
      icon = '⛅';
      advisory = 'Pleasant weather across transit lines.';
    } else if (code >= 45 && code <= 48) {
      condition = 'Foggy / Mist';
      icon = '🌫️';
      advisory = 'Slight bus delays expected due to low morning visibility.';
    } else if (code >= 51 && code <= 67) {
      condition = 'Rain / Drizzle';
      icon = '🌧️';
      advisory = 'Wet roads! Metro & covered transit recommended.';
    } else if (code >= 71 && code <= 86) {
      condition = 'Snow / Showers';
      icon = '❄️';
      advisory = 'Expect slower bus timings.';
    } else if (code >= 95) {
      condition = 'Thunderstorm';
      icon = '⛈️';
      advisory = 'Take shelter. Prefer Underground Metro lines.';
    }

    return WeatherInfo(
      temperature: temp,
      windSpeed: wind,
      weatherCode: code,
      condition: condition,
      icon: icon,
      travelAdvisory: advisory,
    );
  }

  factory WeatherInfo.defaultWeather() => WeatherInfo(
        temperature: 28.5,
        windSpeed: 10.2,
        weatherCode: 1,
        condition: 'Pleasant & Clear',
        icon: '⛅',
        travelAdvisory: 'Normal transit schedules across all routes.',
      );
}

class WeatherService {
  // Free Open-Meteo API (No API key needed)
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static Future<WeatherInfo> fetchLiveTransitWeather(double lat, double lng) async {
    try {
      final url = Uri.parse('$_baseUrl?latitude=$lat&longitude=$lng&current_weather=true');
      final response = await http.get(url).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherInfo.fromJson(data);
      }
    } catch (e) {
      // Fallback
    }
    return WeatherInfo.defaultWeather();
  }
}
