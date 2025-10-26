import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class WeatherAlertsService {
  static final StreamController<WeatherAlert> _alertController =
      StreamController<WeatherAlert>.broadcast();

  static Stream<WeatherAlert> get alertStream => _alertController.stream;

  static final List<WeatherAlert> _activeAlerts = [];
  static Timer? _alertCheckTimer;

  static void startAlertMonitoring() {
    _alertCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _checkForAlerts(),
    );
  }

  static void stopAlertMonitoring() {
    _alertCheckTimer?.cancel();
    _alertCheckTimer = null;
  }

  static void checkWeatherForAlerts(WeatherData weatherData) {
    _checkTemperatureAlerts(weatherData);
    _checkWindAlerts(weatherData);
    _checkVisibilityAlerts(weatherData);
    _checkHumidityAlerts(weatherData);
    _checkPrecipitationAlerts(weatherData);
  }

  static void _checkForAlerts() {
    // This would typically check against stored weather data
    // For now, we'll generate some sample alerts
    _generateSampleAlerts();
  }

  static void _checkTemperatureAlerts(WeatherData weatherData) {
    if (weatherData.temperature > 40) {
      _addAlert(
        WeatherAlert(
          type: AlertType.temperature,
          severity: AlertSeverity.high,
          title: 'Extreme Heat Warning',
          message:
              'Temperature is extremely high. Stay hydrated and avoid prolonged sun exposure.',
          icon: Icons.warning,
          color: Colors.red,
          timestamp: DateTime.now(),
        ),
      );
    } else if (weatherData.temperature > 35) {
      _addAlert(
        WeatherAlert(
          type: AlertType.temperature,
          severity: AlertSeverity.medium,
          title: 'Heat Advisory',
          message: 'High temperature detected. Take precautions in the sun.',
          icon: Icons.wb_sunny,
          color: Colors.orange,
          timestamp: DateTime.now(),
        ),
      );
    } else if (weatherData.temperature < 0) {
      _addAlert(
        WeatherAlert(
          type: AlertType.temperature,
          severity: AlertSeverity.high,
          title: 'Freezing Temperature',
          message:
              'Temperature is below freezing. Dress warmly and be cautious of ice.',
          icon: Icons.ac_unit,
          color: Colors.blue,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  static void _checkWindAlerts(WeatherData weatherData) {
    if (weatherData.windSpeed > 30) {
      _addAlert(
        WeatherAlert(
          type: AlertType.wind,
          severity: AlertSeverity.high,
          title: 'Strong Wind Warning',
          message:
              'Very strong winds detected. Avoid outdoor activities if possible.',
          icon: Icons.air,
          color: Colors.grey,
          timestamp: DateTime.now(),
        ),
      );
    } else if (weatherData.windSpeed > 20) {
      _addAlert(
        WeatherAlert(
          type: AlertType.wind,
          severity: AlertSeverity.medium,
          title: 'Wind Advisory',
          message: 'Strong winds expected. Secure loose objects.',
          icon: Icons.air,
          color: Colors.grey,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  static void _checkVisibilityAlerts(WeatherData weatherData) {
    if (weatherData.visibility < 1) {
      _addAlert(
        WeatherAlert(
          type: AlertType.visibility,
          severity: AlertSeverity.high,
          title: 'Dense Fog Warning',
          message:
              'Very low visibility due to dense fog. Drive with extreme caution.',
          icon: Icons.foggy,
          color: Colors.grey,
          timestamp: DateTime.now(),
        ),
      );
    } else if (weatherData.visibility < 5) {
      _addAlert(
        WeatherAlert(
          type: AlertType.visibility,
          severity: AlertSeverity.medium,
          title: 'Low Visibility',
          message: 'Reduced visibility conditions. Drive carefully.',
          icon: Icons.visibility_off,
          color: Colors.grey,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  static void _checkHumidityAlerts(WeatherData weatherData) {
    if (weatherData.humidity > 90) {
      _addAlert(
        WeatherAlert(
          type: AlertType.humidity,
          severity: AlertSeverity.low,
          title: 'High Humidity',
          message: 'Very high humidity levels. Stay cool and hydrated.',
          icon: Icons.water_drop,
          color: Colors.blue,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  static void _checkPrecipitationAlerts(WeatherData weatherData) {
    if (weatherData.description.toLowerCase().contains('thunderstorm')) {
      _addAlert(
        WeatherAlert(
          type: AlertType.precipitation,
          severity: AlertSeverity.high,
          title: 'Thunderstorm Warning',
          message: 'Thunderstorm activity detected. Seek shelter immediately.',
          icon: Icons.flash_on,
          color: Colors.purple,
          timestamp: DateTime.now(),
        ),
      );
    } else if (weatherData.description.toLowerCase().contains('rain')) {
      _addAlert(
        WeatherAlert(
          type: AlertType.precipitation,
          severity: AlertSeverity.medium,
          title: 'Rain Alert',
          message: 'Rain expected. Carry an umbrella or rain gear.',
          icon: Icons.grain,
          color: Colors.blue,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  static void _generateSampleAlerts() {
    // Generate some sample alerts for demonstration
    final random = Random();
    if (random.nextBool()) {
      _addAlert(
        WeatherAlert(
          type: AlertType.temperature,
          severity: AlertSeverity.medium,
          title: 'Temperature Alert',
          message: 'Temperature is rising. Stay cool!',
          icon: Icons.thermostat,
          color: Colors.orange,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  static void _addAlert(WeatherAlert alert) {
    // Check if similar alert already exists
    bool exists = _activeAlerts.any(
      (existingAlert) =>
          existingAlert.type == alert.type &&
          existingAlert.title == alert.title,
    );

    if (!exists) {
      _activeAlerts.add(alert);
      _alertController.add(alert);

      // Auto-remove alert after 30 minutes
      Timer(const Duration(minutes: 30), () {
        _removeAlert(alert);
      });
    }
  }

  static void _removeAlert(WeatherAlert alert) {
    _activeAlerts.remove(alert);
  }

  static List<WeatherAlert> getActiveAlerts() {
    return List.from(_activeAlerts);
  }

  static void clearAllAlerts() {
    _activeAlerts.clear();
  }

  static void dispose() {
    _alertController.close();
    _alertCheckTimer?.cancel();
  }
}

class WeatherAlert {
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;

  WeatherAlert({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
  });
}

enum AlertType {
  temperature,
  wind,
  visibility,
  humidity,
  precipitation,
  general,
}

enum AlertSeverity { low, medium, high, critical }
