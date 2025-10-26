# 🌤️ Weather App

A beautiful, modern weather application built with Flutter featuring real-time weather data, cute UI design, and comprehensive weather information.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![OpenWeatherMap](https://img.shields.io/badge/OpenWeatherMap-1E90FF?style=for-the-badge&logo=openweathermap&logoColor=white)

## ✨ Features

### 🌟 Core Features
- **Real-time Weather Data** - Get current weather conditions from OpenWeatherMap API
- **Location Services** - Automatic location detection and weather updates
- **Beautiful UI** - Modern glassmorphism design with cute Comic Neue font
- **Responsive Design** - Optimized for all screen sizes
- **Smooth Animations** - Engaging transitions and micro-interactions

### 📊 Weather Information
- **Current Weather** - Temperature, description, and weather icon
- **Detailed Metrics** - Humidity, wind speed, visibility, pressure, UV index
- **Hourly Forecast** - 24-hour weather predictions
- **7-Day Forecast** - Weekly weather outlook
- **Weather Alerts** - Smart notifications for extreme conditions

### 🎨 Design Features
- **Dynamic Backgrounds** - Weather-based gradient backgrounds
- **Glassmorphism Effects** - Modern frosted glass design elements
- **Cute Typography** - Comic Neue font for friendly appearance
- **Dark Theme** - Consistent dark green color scheme
- **Smooth Animations** - Fade, slide, and scale transitions


## 📱 Screenshots

### Main Weather Screen
- Current weather display with large temperature
- Weather description and "feels like" temperature
- Beautiful weather icon with animations

### Weather Details
- Comprehensive weather metrics
- Progress bars for visual representation
- Consistent card-based layout

### Forecast Views
- Horizontal scrolling hourly forecast
- Vertical 7-day forecast list
- Weather icons and temperature ranges

## 🛠️ Technical Details

### Architecture
- **Clean Architecture** - Separated concerns with models, services, and widgets
- **State Management** - Flutter's built-in StatefulWidget
- **API Integration** - HTTP requests to OpenWeatherMap API
- **Location Services** - Geolocator and Geocoding packages

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  intl: ^0.19.0
  weather_icons: ^3.0.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  permission_handler: ^11.0.1
  google_fonts: ^6.1.0
```


## 🎯 Features in Detail

### Weather Data
- **Current Conditions** - Real-time temperature, humidity, wind speed
- **Forecast Data** - Hourly and daily predictions
- **Location Info** - City name and coordinates
- **Weather Alerts** - Temperature, wind, and visibility warnings

### UI Components
- **Main Weather Card** - Large temperature display with weather icon
- **Detail Cards** - Metrics with progress bars and icons
- **Forecast Lists** - Scrollable weather predictions
- **Alert System** - Smart weather notifications

### Animations
- **Fade Transitions** - Smooth content appearance
- **Slide Animations** - Card entrance effects
- **Scale Animations** - Interactive element feedback
- **Temperature Counting** - Animated number transitions

## 🔧 Configuration

### API Setup
1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Get your API key
3. Replace the API key in `weather_service.dart`:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

### Location Permissions
The app requires location permissions to fetch weather data:
- **Android**: Add permissions in `android/app/src/main/AndroidManifest.xml`
- **iOS**: Add location usage description in `ios/Runner/Info.plist`

## 🎨 Customization

### Colors
The app uses a dark green theme. You can customize colors in the main.dart file:
```dart
// Primary colors
Color(0xFF2D3A1F) // Dark green
Color(0xFF4A5A3A) // Medium green
Color(0xFF6B7C4A) // Light green
```

### Fonts
The app uses Comic Neue for a cute appearance. You can change fonts in the theme:
```dart
textTheme: GoogleFonts.comicNeueTextTheme(),
```

### Icons
Weather icons are provided by the `weather_icons` package. You can customize the mapping in `weather_utils.dart`.

## 📱 Platform Support

- ✅ **Android** - Full support with location services
- ✅ **iOS** - Full support with location services
- ✅ **Web** - Responsive web application
- ✅ **Windows** - Desktop application
- ✅ **macOS** - Desktop application
- ✅ **Linux** - Desktop application



## 🙏 Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) for weather data API
- [Flutter](https://flutter.dev/) for the amazing framework
- [Google Fonts](https://fonts.google.com/) for Comic Neue font
- [Weather Icons](https://erikflowers.github.io/weather-icons/) for weather icons

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Check the [Flutter documentation](https://flutter.dev/docs)
- Review the [OpenWeatherMap API docs](https://openweathermap.org/api)

---

Made with ❤️ and Flutter