import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

/// Service météo via Open-Meteo (gratuit, sans clé API)
class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  /// Météo actuelle à Montréal
  Future<WeatherData> getCurrentWeather() async {
    final response = await _dio.get(
      '${AppConstants.openMeteoBaseUrl}/forecast',
      queryParameters: {
        'latitude': AppConstants.mtlLatitude,
        'longitude': AppConstants.mtlLongitude,
        'current': [
          'temperature_2m',
          'apparent_temperature',
          'weather_code',
          'wind_speed_10m',
          'precipitation',
          'relative_humidity_2m',
        ].join(','),
        'timezone': 'America/Montreal',
      },
    );
    return WeatherData.fromOpenMeteo(response.data);
  }

  /// Prévisions horaires pour les prochaines 48h
  Future<List<HourlyForecast>> getHourlyForecast() async {
    final response = await _dio.get(
      '${AppConstants.openMeteoBaseUrl}/forecast',
      queryParameters: {
        'latitude': AppConstants.mtlLatitude,
        'longitude': AppConstants.mtlLongitude,
        'hourly': 'temperature_2m,weather_code,precipitation_probability',
        'timezone': 'America/Montreal',
        'forecast_hours': 48,
      },
    );

    final hourly = response.data['hourly'];
    final times = (hourly['time'] as List).cast<String>();
    final temps = (hourly['temperature_2m'] as List).cast<num>();
    final codes = (hourly['weather_code'] as List).cast<int>();
    final precip = (hourly['precipitation_probability'] as List).cast<int>();

    return List.generate(times.length, (i) => HourlyForecast(
      time: DateTime.parse(times[i]),
      temperature: temps[i].toDouble(),
      weatherCode: codes[i],
      precipitationProbability: precip[i],
    ));
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  bool get isRainy => precipitationProbability > 50 || weatherCode >= 51;
}
