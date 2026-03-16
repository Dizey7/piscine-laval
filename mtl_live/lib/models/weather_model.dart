/// Modèle météo pour le filtre intelligent
class WeatherData {
  final double temperature;
  final double feelsLike;
  final int weatherCode;
  final double windSpeed;
  final double precipitation;
  final int humidity;
  final DateTime timestamp;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.weatherCode,
    required this.windSpeed,
    required this.precipitation,
    required this.humidity,
    required this.timestamp,
  });

  String get conditionLabel {
    if (weatherCode == 0) return 'Dégagé';
    if (weatherCode <= 3) return 'Nuageux';
    if (weatherCode <= 48) return 'Brouillard';
    if (weatherCode <= 57) return 'Bruine';
    if (weatherCode <= 67) return 'Pluie';
    if (weatherCode <= 77) return 'Neige';
    if (weatherCode <= 82) return 'Averses';
    if (weatherCode <= 86) return 'Averses de neige';
    if (weatherCode <= 99) return 'Orage';
    return 'Inconnu';
  }

  String get conditionIcon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '🌨️';
    if (weatherCode <= 86) return '❄️';
    if (weatherCode <= 99) return '⛈️';
    return '🌡️';
  }

  /// Recommande-t-on des activités intérieures ?
  bool get shouldRecommendIndoor {
    return precipitation > 1.0 ||
        temperature < -15 ||
        temperature > 35 ||
        windSpeed > 50 ||
        weatherCode >= 63; // Pluie modérée+
  }

  String get temperatureDisplay => '${temperature.round()}°C';

  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json) {
    final current = json['current'] ?? json['current_weather'] ?? {};
    return WeatherData(
      temperature: (current['temperature_2m'] ?? current['temperature'] ?? 0).toDouble(),
      feelsLike: (current['apparent_temperature'] ?? current['temperature'] ?? 0).toDouble(),
      weatherCode: current['weather_code'] ?? current['weathercode'] ?? 0,
      windSpeed: (current['wind_speed_10m'] ?? current['windspeed'] ?? 0).toDouble(),
      precipitation: (current['precipitation'] ?? 0).toDouble(),
      humidity: current['relative_humidity_2m'] ?? 0,
      timestamp: DateTime.now(),
    );
  }
}
