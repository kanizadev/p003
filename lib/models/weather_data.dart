class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final double visibility;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      description: json['weather'][0]['description'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: (json['main']['humidity'] ?? 0).toDouble(),
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      visibility: (json['visibility'] ?? 0).toDouble() / 1000, // Convert to km
      hourlyForecast: [],
      dailyForecast: [],
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String icon;
  final String description;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
    required this.description,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      icon: json['weather'][0]['icon'] ?? '01d',
      description: json['weather'][0]['description'] ?? 'Unknown',
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String icon;
  final String description;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.icon,
    required this.description,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['temp']['max'] ?? 0).toDouble(),
      minTemp: (json['temp']['min'] ?? 0).toDouble(),
      icon: json['weather'][0]['icon'] ?? '01d',
      description: json['weather'][0]['description'] ?? 'Unknown',
    );
  }
}
