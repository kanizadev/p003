import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationPermissionDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const LocationPermissionDialog({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF9CAF88).withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.location_off, color: Color(0xFF5A6B3A)),
          SizedBox(width: 10),
          Text('Location Required'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3A1F),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'To get accurate weather data for your location, please enable location services.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5A3A),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF5A6B3A)),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await LocationService.openLocationSettings();
          },
          child: const Text(
            'Settings',
            style: TextStyle(color: Color(0xFF5A6B3A)),
          ),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A6B3A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          LocationPermissionDialog(message: message, onRetry: onRetry),
    );
  }
}
