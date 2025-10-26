import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/weather_data.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'services/weather_alerts_service.dart';
import 'utils/weather_utils.dart';
import 'widgets/location_permission_dialog.dart';
import 'widgets/weather_alerts_widget.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.comicNeueTextTheme(),
      ),
      home: const WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  WeatherData? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Initialize weather alerts service
    WeatherAlertsService.startAlertMonitoring();

    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final weatherData = await WeatherService.getCurrentWeather();

      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });

      // Check for weather alerts
      WeatherAlertsService.checkWeatherForAlerts(weatherData);

      _animationController.forward();
    } on LocationServiceException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();

      // Show location permission dialog
      if (mounted) {
        LocationPermissionDialog.show(
          context,
          message: e.message,
          onRetry: _loadWeatherData,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data: ${e.toString()}';
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _loadDhakaWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weatherData = await WeatherService.getWeatherForDhaka();
      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load Dhaka weather: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  LinearGradient _getWeatherGradient() {
    if (_weatherData == null) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF9CAF88), // Sage green
          Color(0xFF7A8B5A), // Darker sage
          Color(0xFF6B7C4A), // Forest sage
          Color(0xFF5A6B3A), // Deep sage
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      );
    }

    final weatherIcon = _weatherData!.icon;
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 18;

    // Weather-based gradients
    if (weatherIcon.contains('01')) {
      // Clear sky
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isNight
            ? [
                const Color(0xFF1a1a2e),
                const Color(0xFF16213e),
                const Color(0xFF0f3460),
                const Color(0xFF533483),
              ]
            : [
                const Color(0xFF87CEEB),
                const Color(0xFF98D8E8),
                const Color(0xFFB0E0E6),
                const Color(0xFFE0F6FF),
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    } else if (weatherIcon.contains('02') || weatherIcon.contains('03')) {
      // Partly cloudy
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isNight
            ? [
                const Color(0xFF2c3e50),
                const Color(0xFF34495e),
                const Color(0xFF7f8c8d),
                const Color(0xFF95a5a6),
              ]
            : [
                const Color(0xFF9CAF88),
                const Color(0xFF7A8B5A),
                const Color(0xFF6B7C4A),
                const Color(0xFF5A6B3A),
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    } else if (weatherIcon.contains('09') || weatherIcon.contains('10')) {
      // Rain
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4a6741),
          const Color(0xFF3d5a3d),
          const Color(0xFF2d4a2d),
          const Color(0xFF1e3a1e),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    } else if (weatherIcon.contains('11')) {
      // Thunderstorm
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2c3e50),
          const Color(0xFF34495e),
          const Color(0xFF2c3e50),
          const Color(0xFF1a252f),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    } else if (weatherIcon.contains('13')) {
      // Snow
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFE8F4FD),
          const Color(0xFFD1E7DD),
          const Color(0xFFB8D4EA),
          const Color(0xFF9FC5E8),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    } else if (weatherIcon.contains('50')) {
      // Mist/Fog
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B9DC3),
          const Color(0xFF7A8B9A),
          const Color(0xFF6B7C8A),
          const Color(0xFF5C6D7A),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    }

    // Default sage green gradient
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF9CAF88),
        Color(0xFF7A8B5A),
        Color(0xFF6B7C4A),
        Color(0xFF5A6B3A),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    WeatherAlertsService.stopAlertMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading || _errorMessage.isNotEmpty
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 60,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                  ),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          color: const Color(0xFF2D3A1F),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Weather',
                          style: GoogleFonts.comicNeue(
                            color: const Color(0xFF2D3A1F),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _loadWeatherData,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFF2D3A1F),
                          size: 24,
                        ),
                        tooltip: 'Refresh Weather',
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: _getWeatherGradient()),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: _buildWeatherContent(),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3A1F)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Loading weather data...',
            style: TextStyle(
              color: Color(0xFF2D3A1F),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Getting your location and weather info',
            style: TextStyle(
              color: const Color(0xFF4A5A3A).withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFF2D3A1F),
                size: 56,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Unable to load weather data',
              style: TextStyle(
                color: Color(0xFF2D3A1F),
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _errorMessage,
              style: TextStyle(
                color: const Color(0xFF4A5A3A).withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loadWeatherData,
                      icon: const Icon(Icons.refresh, size: 22),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        foregroundColor: const Color(0xFF2D3A1F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _loadDhakaWeather,
                  icon: const Icon(Icons.location_city, size: 22),
                  label: const Text('Dhaka Weather'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF7A8B5A,
                    ).withValues(alpha: 0.8),
                    foregroundColor: const Color(0xFF2D3A1F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildCurrentWeather(),
          const SizedBox(height: 24),
          const WeatherAlertsWidget(),
          const SizedBox(height: 32),
          _buildWeatherDetails(),
          const SizedBox(height: 32),
          _buildHourlyForecast(),
          const SizedBox(height: 32),
          _buildWeeklyForecast(),
          const SizedBox(height: 20), // Extra padding at bottom
          const SizedBox(height: 40), // Additional bottom spacing
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final weatherData = _weatherData!;
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';

    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
    } else if (hour >= 21 || hour < 5) {
      greeting = 'Good Night';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  greeting,
                  style: GoogleFonts.comicNeue(
                    color: const Color(0xFF2D3A1F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                weatherData.location,
                style: GoogleFonts.comicNeue(
                  color: const Color(0xFF2D3A1F),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: GoogleFonts.comicNeue(
                  color: const Color(0xFF4A5A3A).withValues(alpha: 0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeather() {
    final weatherData = _weatherData!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
            ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Weather Icon with enhanced styling
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Icon(
                        WeatherUtils.getWeatherIcon(weatherData.icon),
                        color: const Color(0xFF2D3A1F),
                        size: 60,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Temperature with enhanced styling
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: weatherData.temperature),
                builder: (context, value, child) {
                  return Text(
                    WeatherUtils.formatTemperature(value),
                    style: GoogleFonts.comicNeue(
                      color: const Color(0xFF2D3A1F),
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -1.5,
                      height: 0.9,
                    ),
                  );
                },
              ),

              // Weather Description
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  WeatherUtils.getWeatherDescription(weatherData.description),
                  style: GoogleFonts.comicNeue(
                    color: const Color(0xFF2D3A1F),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Feels Like with enhanced styling
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Feels like ${WeatherUtils.formatTemperature(weatherData.feelsLike)}',
                  style: GoogleFonts.comicNeue(
                    color: const Color(0xFF2D3A1F),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildWeatherAlerts(weatherData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherAlerts(WeatherData weatherData) {
    final alerts = <Widget>[];

    // Temperature alerts
    if (weatherData.temperature > 35) {
      alerts.add(_buildAlertChip('🌡️ Hot Weather', Colors.orange));
    } else if (weatherData.temperature < 5) {
      alerts.add(_buildAlertChip('❄️ Cold Weather', Colors.blue));
    }

    // Wind alerts
    if (weatherData.windSpeed > 20) {
      alerts.add(_buildAlertChip('💨 Strong Wind', Colors.grey));
    }

    // Visibility alerts
    if (weatherData.visibility < 5) {
      alerts.add(_buildAlertChip('🌫️ Low Visibility', Colors.grey));
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 4, children: alerts);
  }

  Widget _buildAlertChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    final weatherData = _weatherData!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
              ),
            ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    icon: WeatherIcons.humidity,
                    title: 'Humidity',
                    value: WeatherUtils.formatHumidity(weatherData.humidity),
                    progress: weatherData.humidity / 100,
                    color: const Color(0xFF2D3A1F),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDetailCard(
                    icon: WeatherIcons.strong_wind,
                    title: 'Wind',
                    value: WeatherUtils.formatWindSpeed(weatherData.windSpeed),
                    progress: (weatherData.windSpeed / 30).clamp(0.0, 1.0),
                    color: const Color(0xFF2D3A1F),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDetailCard(
                    icon: WeatherIcons.thermometer,
                    title: 'Visibility',
                    value: WeatherUtils.formatVisibility(
                      weatherData.visibility,
                    ),
                    progress: (weatherData.visibility / 20).clamp(0.0, 1.0),
                    color: const Color(0xFF2D3A1F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    icon: WeatherIcons.thermometer,
                    title: 'Feels Like',
                    value: '${weatherData.feelsLike.round()}°',
                    progress: (weatherData.feelsLike / 50).clamp(0.0, 1.0),
                    color: const Color(0xFF2D3A1F),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDetailCard(
                    icon: WeatherIcons.barometer,
                    title: 'Pressure',
                    value: (weatherData.humidity * 0.1).toStringAsFixed(1),
                    progress: (weatherData.humidity * 0.1 / 10).clamp(0.0, 1.0),
                    color: const Color(0xFF2D3A1F),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDetailCard(
                    icon: WeatherIcons.sunrise,
                    title: 'UV Index',
                    value: '${(weatherData.temperature / 10).round()}',
                    progress: (weatherData.temperature / 50).clamp(0.0, 1.0),
                    color: const Color(0xFF2D3A1F),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    double? progress,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            blurRadius: 1,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? const Color(0xFF2D3A1F), size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.comicNeue(
              color: const Color(0xFF2D3A1F),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.comicNeue(
              color: const Color(0xFF4A5A3A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: const Color(
                    0xFF4A5A3A,
                  ).withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? const Color(0xFF2D3A1F),
                  ),
                  minHeight: 3,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    final weatherData = _weatherData!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hourly Forecast',
              style: GoogleFonts.comicNeue(
                color: const Color(0xFF2D3A1F),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weatherData.hourlyForecast.length,
                itemBuilder: (context, index) {
                  final forecast = weatherData.hourlyForecast[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: 75,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.3),
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.15),
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(forecast.time),
                                style: GoogleFonts.comicNeue(
                                  color: const Color(0xFF2D3A1F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Icon(
                                WeatherUtils.getWeatherIcon(forecast.icon),
                                color: const Color(0xFF2D3A1F),
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                WeatherUtils.formatTemperature(
                                  forecast.temperature,
                                ),
                                style: GoogleFonts.comicNeue(
                                  color: const Color(0xFF2D3A1F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    final weatherData = _weatherData!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
              ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day Forecast',
              style: GoogleFonts.comicNeue(
                color: const Color(0xFF2D3A1F),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            ...weatherData.dailyForecast.asMap().entries.map((entry) {
              final index = entry.key;
              final forecast = entry.value;
              final isToday = index == 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          WeatherUtils.getWeatherIcon(forecast.icon),
                          color: const Color(0xFF2D3A1F),
                          size: 28,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          isToday
                              ? 'Today'
                              : DateFormat('EEEE').format(forecast.date),
                          style: GoogleFonts.comicNeue(
                            color: const Color(0xFF2D3A1F),
                            fontSize: 18,
                            fontWeight: isToday
                                ? FontWeight.w600
                                : FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          WeatherUtils.formatTemperature(forecast.maxTemp),
                          style: GoogleFonts.comicNeue(
                            color: const Color(0xFF2D3A1F),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/',
                          style: GoogleFonts.comicNeue(
                            color: const Color(0xFF6B7C4A),
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          WeatherUtils.formatTemperature(forecast.minTemp),
                          style: GoogleFonts.comicNeue(
                            color: const Color(0xFF4A5A3A),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
