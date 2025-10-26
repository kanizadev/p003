import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

class LocationSearchWidget extends StatefulWidget {
  final Function(Placemark) onLocationSelected;
  final String currentLocation;

  const LocationSearchWidget({
    super.key,
    required this.onLocationSelected,
    required this.currentLocation,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Placemark> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await LocationService.searchLocation(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  String _formatLocationName(Placemark placemark) {
    String city = placemark.locality ?? '';
    String state = placemark.administrativeArea ?? '';
    String country = placemark.country ?? '';

    List<String> parts = [
      city,
      state,
      country,
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9CAF88).withValues(alpha: 0.9), // Sage green
            const Color(0xFF7A8B5A).withValues(alpha: 0.8), // Darker sage
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: const Color(0xFF6B7C4A).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Search field
          TextField(
            controller: _searchController,
            onChanged: _searchLocation,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search for a city...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _searchLocation('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Current location
          if (widget.currentLocation.isNotEmpty) ...[
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.white),
              title: const Text(
                'Current Location',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              subtitle: Text(
                widget.currentLocation,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.white30),
          ],

          // Search results
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (_searchResults.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final placemark = _searchResults[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      _formatLocationName(placemark),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      widget.onLocationSelected(placemark);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            )
          else if (_searchController.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No locations found',
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}
