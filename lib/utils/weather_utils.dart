import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherUtils {
  static IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return WeatherIcons.day_sunny;
      case '02d':
      case '02n':
        return WeatherIcons.day_cloudy;
      case '03d':
      case '03n':
        return WeatherIcons.cloud;
      case '04d':
      case '04n':
        return WeatherIcons.cloudy;
      case '09d':
      case '09n':
        return WeatherIcons.rain;
      case '10d':
      case '10n':
        return WeatherIcons.day_rain;
      case '11d':
      case '11n':
        return WeatherIcons.thunderstorm;
      case '13d':
      case '13n':
        return WeatherIcons.snow;
      case '50d':
      case '50n':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.day_sunny;
    }
  }

  static String getWeatherDescription(String description) {
    return description
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static String formatTemperature(double temp) {
    return '${temp.round()}°';
  }

  static String formatWindSpeed(double speed) {
    return '${speed.round()} km/h';
  }

  static String formatVisibility(double visibility) {
    return '${visibility.round()} km';
  }

  static String formatHumidity(double humidity) {
    return '${humidity.round()}%';
  }
}
