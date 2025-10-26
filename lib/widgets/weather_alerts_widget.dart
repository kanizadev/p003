import 'package:flutter/material.dart';
import '../services/weather_alerts_service.dart';

class WeatherAlertsWidget extends StatefulWidget {
  const WeatherAlertsWidget({super.key});

  @override
  State<WeatherAlertsWidget> createState() => _WeatherAlertsWidgetState();
}

class _WeatherAlertsWidgetState extends State<WeatherAlertsWidget>
    with TickerProviderStateMixin {
  List<WeatherAlert> _alerts = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadAlerts();
    _listenToAlerts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadAlerts() {
    setState(() {
      _alerts = WeatherAlertsService.getActiveAlerts();
    });
  }

  void _listenToAlerts() {
    WeatherAlertsService.alertStream.listen((alert) {
      setState(() {
        _alerts = WeatherAlertsService.getActiveAlerts();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF2D3A1F),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Weather Alerts',
                  style: TextStyle(
                    color: Color(0xFF2D3A1F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllAlerts(context),
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFF2D3A1F), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _alerts.length,
                itemBuilder: (context, index) {
                  final alert = _alerts[index];
                  return _buildAlertCard(alert);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(WeatherAlert alert) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            alert.color.withValues(alpha: 0.3),
            alert.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: alert.color.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: alert.color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alert.icon, color: alert.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.title,
                  style: TextStyle(
                    color: alert.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildSeverityIndicator(alert.severity),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              alert.message,
              style: const TextStyle(
                color: Color(0xFF2D3A1F),
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(alert.timestamp),
            style: TextStyle(
              color: const Color(0xFF4A5A3A).withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator(AlertSeverity severity) {
    Color color;
    switch (severity) {
      case AlertSeverity.low:
        color = Colors.green;
        break;
      case AlertSeverity.medium:
        color = Colors.orange;
        break;
      case AlertSeverity.high:
        color = Colors.red;
        break;
      case AlertSeverity.critical:
        color = Colors.purple;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showAllAlerts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAllAlertsSheet(),
    );
  }

  Widget _buildAllAlertsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9CAF88),
            Color(0xFF7A8B5A),
            Color(0xFF6B7C4A),
            Color(0xFF5A6B3A),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'All Weather Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Alerts list
          Expanded(
            child: _alerts.isEmpty
                ? const Center(
                    child: Text(
                      'No active alerts',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      final alert = _alerts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: alert.color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: alert.color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                alert.icon,
                                color: alert.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        alert.title,
                                        style: TextStyle(
                                          color: alert.color,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildSeverityIndicator(alert.severity),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(alert.timestamp),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
