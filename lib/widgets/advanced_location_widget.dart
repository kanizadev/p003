import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

class AdvancedLocationWidget extends StatefulWidget {
  final Function(Placemark) onLocationSelected;
  final String currentLocation;

  const AdvancedLocationWidget({
    super.key,
    required this.onLocationSelected,
    required this.currentLocation,
  });

  @override
  State<AdvancedLocationWidget> createState() => _AdvancedLocationWidgetState();
}

class _AdvancedLocationWidgetState extends State<AdvancedLocationWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Placemark> _searchResults = [];
  List<Placemark> _favoriteLocations = [];
  final List<Placemark> _recentLocations = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadFavoriteLocations();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteLocations() async {
    try {
      final favorites = await LocationService.getFavoriteLocations();
      setState(() {
        _favoriteLocations = favorites;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await LocationService.searchLocation(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatLocationName(Placemark placemark) {
    List<String> parts = [];
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  Icons.location_on,
                  color: Color(0xFF2D3A1F),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Advanced Location Search',
                  style: TextStyle(
                    color: Color(0xFF2D3A1F),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF2D3A1F)),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocation,
              style: const TextStyle(color: Color(0xFF2D3A1F)),
              decoration: InputDecoration(
                hintText: 'Search for a city, address, or landmark...',
                hintStyle: TextStyle(
                  color: const Color(0xFF4A5A3A).withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF2D3A1F),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Color(0xFF2D3A1F),
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocation('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3A1F)),
        ),
      );
    }

    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return _buildLocationTabs();
  }

  Widget _buildLocationTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF2D3A1F),
            unselectedLabelColor: Color(0xFF4A5A3A),
            indicatorColor: Color(0xFF2D3A1F),
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'Recent'),
              Tab(text: 'Nearby'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFavoriteLocations(),
                _buildRecentLocations(),
                _buildNearbyLocations(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteLocations() {
    if (_favoriteLocations.isEmpty) {
      return const Center(
        child: Text(
          'No favorite locations yet',
          style: TextStyle(color: Color(0xFF4A5A3A)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _favoriteLocations.length,
      itemBuilder: (context, index) {
        final placemark = _favoriteLocations[index];
        return _buildLocationCard(
          placemark,
          icon: Icons.favorite,
          onTap: () {
            widget.onLocationSelected(placemark);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildRecentLocations() {
    if (_recentLocations.isEmpty) {
      return const Center(
        child: Text(
          'No recent locations',
          style: TextStyle(color: Color(0xFF4A5A3A)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recentLocations.length,
      itemBuilder: (context, index) {
        final placemark = _recentLocations[index];
        return _buildLocationCard(
          placemark,
          icon: Icons.history,
          onTap: () {
            widget.onLocationSelected(placemark);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildNearbyLocations() {
    return FutureBuilder<List<Placemark>>(
      future: _getNearbyLocations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3A1F)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Unable to load nearby locations',
              style: TextStyle(color: Color(0xFF4A5A3A)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final placemark = snapshot.data![index];
            return _buildLocationCard(
              placemark,
              icon: Icons.near_me,
              onTap: () {
                widget.onLocationSelected(placemark);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<List<Placemark>> _getNearbyLocations() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        return await LocationService.getNearbyCities(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Color(0xFF4A5A3A)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final placemark = _searchResults[index];
        return _buildLocationCard(
          placemark,
          icon: Icons.search,
          onTap: () {
            widget.onLocationSelected(placemark);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildLocationCard(
    Placemark placemark, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF2D3A1F), size: 20),
        ),
        title: Text(
          _formatLocationName(placemark),
          style: const TextStyle(
            color: Color(0xFF2D3A1F),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: placemark.country != null
            ? Text(
                placemark.country!,
                style: TextStyle(
                  color: Color(0xFF4A5A3A).withValues(alpha: 0.7),
                ),
              )
            : null,
        onTap: onTap,
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF4A5A3A).withValues(alpha: 0.5),
          size: 16,
        ),
      ),
    );
  }
}
