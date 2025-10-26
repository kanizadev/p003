import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../models/weather_data.dart';
import 'location_service.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Using a free API key for demo purposes
  static const String _apiKey = 'b6907d289e10d714a6e88b30761fae22';

  static Future<WeatherData> getCurrentWeather() async {
    try {
      // Get current location
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        throw LocationServiceException('Unable to get current location');
      }

      // Get city name from coordinates
      String cityName = await LocationService.getCityNameFromPosition(position);

      // Fetch current weather
      final currentWeatherUrl =
          '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      final currentResponse = await http.get(Uri.parse(currentWeatherUrl));

      if (currentResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final weatherData = WeatherData.fromJson(currentData);

        // Fetch 5-day forecast for hourly and daily data
        final forecastUrl =
            '$_baseUrl/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
        final forecastResponse = await http.get(Uri.parse(forecastUrl));

        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          final hourlyForecast = _parseHourlyForecast(forecastData['list']);
          final dailyForecast = _parseDailyForecast(forecastData['list']);

          return WeatherData(
            location: cityName,
            temperature: weatherData.temperature,
            feelsLike: weatherData.feelsLike,
            description: weatherData.description,
            icon: weatherData.icon,
            humidity: weatherData.humidity,
            windSpeed: weatherData.windSpeed,
            visibility: weatherData.visibility,
            hourlyForecast: hourlyForecast,
            dailyForecast: dailyForecast,
          );
        }
      }

      throw Exception('Failed to load weather data');
    } catch (e) {
      // Return demo data if API fails
      return _getDemoWeatherData();
    }
  }

  static Future<WeatherData> getWeatherForLocation(Placemark placemark) async {
    try {
      // Get coordinates from placemark
      List<Location> locations = await locationFromAddress(
        '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}',
      );

      if (locations.isEmpty) {
        throw Exception('Unable to get coordinates for location');
      }

      final location = locations.first;
      String cityName =
          '${placemark.locality}, ${placemark.administrativeArea}';

      // Fetch current weather
      final currentWeatherUrl =
          '$_baseUrl/weather?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&units=metric';
      final currentResponse = await http.get(Uri.parse(currentWeatherUrl));

      if (currentResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final weatherData = WeatherData.fromJson(currentData);

        // Fetch 5-day forecast for hourly and daily data
        final forecastUrl =
            '$_baseUrl/forecast?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&units=metric';
        final forecastResponse = await http.get(Uri.parse(forecastUrl));

        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          final hourlyForecast = _parseHourlyForecast(forecastData['list']);
          final dailyForecast = _parseDailyForecast(forecastData['list']);

          return WeatherData(
            location: cityName,
            temperature: weatherData.temperature,
            feelsLike: weatherData.feelsLike,
            description: weatherData.description,
            icon: weatherData.icon,
            humidity: weatherData.humidity,
            windSpeed: weatherData.windSpeed,
            visibility: weatherData.visibility,
            hourlyForecast: hourlyForecast,
            dailyForecast: dailyForecast,
          );
        }
      }

      throw Exception('Failed to load weather data');
    } catch (e) {
      // Return demo data if API fails
      return _getDemoWeatherData();
    }
  }

  static List<HourlyForecast> _parseHourlyForecast(List<dynamic> list) {
    return list.take(8).map((item) => HourlyForecast.fromJson(item)).toList();
  }

  static List<DailyForecast> _parseDailyForecast(List<dynamic> list) {
    // Group by date and get daily max/min
    Map<String, List<dynamic>> dailyData = {};

    for (var item in list) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      String dateKey = '${date.year}-${date.month}-${date.day}';

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = [];
      }
      dailyData[dateKey]!.add(item);
    }

    return dailyData.entries.take(7).map((entry) {
      var dayData = entry.value;
      var maxTemp = dayData
          .map((e) => e['main']['temp'])
          .reduce((a, b) => a > b ? a : b);
      var minTemp = dayData
          .map((e) => e['main']['temp'])
          .reduce((a, b) => a < b ? a : b);
      var weather = dayData.first['weather'][0];

      return DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch(dayData.first['dt'] * 1000),
        maxTemp: maxTemp.toDouble(),
        minTemp: minTemp.toDouble(),
        icon: weather['icon'],
        description: weather['description'],
      );
    }).toList();
  }

  static Future<WeatherData> getWeatherForDhaka() async {
    try {
      // Dhaka coordinates: 23.8103° N, 90.4125° E
      const double dhakaLat = 23.8103;
      const double dhakaLon = 90.4125;

      // Fetch current weather for Dhaka
      final currentWeatherUrl =
          '$_baseUrl/weather?lat=$dhakaLat&lon=$dhakaLon&appid=$_apiKey&units=metric';
      final currentResponse = await http.get(Uri.parse(currentWeatherUrl));

      if (currentResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final weatherData = WeatherData.fromJson(currentData);

        // Fetch 5-day forecast for Dhaka
        final forecastUrl =
            '$_baseUrl/forecast?lat=$dhakaLat&lon=$dhakaLon&appid=$_apiKey&units=metric';
        final forecastResponse = await http.get(Uri.parse(forecastUrl));

        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          final hourlyForecast = _parseHourlyForecast(forecastData['list']);
          final dailyForecast = _parseDailyForecast(forecastData['list']);

          return WeatherData(
            location: 'Dhaka, Bangladesh',
            temperature: weatherData.temperature,
            feelsLike: weatherData.feelsLike,
            description: weatherData.description,
            icon: weatherData.icon,
            humidity: weatherData.humidity,
            windSpeed: weatherData.windSpeed,
            visibility: weatherData.visibility,
            hourlyForecast: hourlyForecast,
            dailyForecast: dailyForecast,
          );
        }
      }

      // If API fails, return demo data for Dhaka
      return _getDemoWeatherData();
    } catch (e) {
      // Return demo data if API fails
      return _getDemoWeatherData();
    }
  }

  static WeatherData _getDemoWeatherData() {
    return WeatherData(
      location: 'Dhaka, Bangladesh',
      temperature: 28.0,
      feelsLike: 32.0,
      description: 'Partly Cloudy',
      icon: '02d',
      humidity: 75.0,
      windSpeed: 8.0,
      visibility: 12.0,
      hourlyForecast: List.generate(
        8,
        (index) => HourlyForecast(
          time: DateTime.now().add(Duration(hours: index)),
          temperature: 28.0 + (index * 1.5),
          icon: '02d',
          description: 'Partly Cloudy',
        ),
      ),
      dailyForecast: List.generate(
        7,
        (index) => DailyForecast(
          date: DateTime.now().add(Duration(days: index)),
          maxTemp: 28.0 + index,
          minTemp: 24.0 + index,
          icon: '02d',
          description: 'Partly Cloudy',
        ),
      ),
    );
  }
}
