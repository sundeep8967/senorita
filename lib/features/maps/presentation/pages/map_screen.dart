import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/utils/extensions.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  // Demo nearby users data
  final List<NearbyUser> _nearbyUsers = [
    NearbyUser(
      id: '1',
      name: 'Emma',
      age: 25,
      distance: 0.5,
      imageUrl: 'https://i.pravatar.cc/100?img=1',
      location: const LatLng(37.7849, -122.4094),
      isOnline: true,
    ),
    NearbyUser(
      id: '2',
      name: 'Sophia',
      age: 28,
      distance: 1.2,
      imageUrl: 'https://i.pravatar.cc/100?img=2',
      location: const LatLng(37.7849, -122.4074),
      isOnline: false,
    ),
    NearbyUser(
      id: '3',
      name: 'Isabella',
      age: 24,
      distance: 2.1,
      imageUrl: 'https://i.pravatar.cc/100?img=3',
      location: const LatLng(37.7869, -122.4094),
      isOnline: true,
    ),
    NearbyUser(
      id: '4',
      name: 'Mia',
      age: 26,
      distance: 3.5,
      imageUrl: 'https://i.pravatar.cc/100?img=4',
      location: const LatLng(37.7829, -122.4114),
      isOnline: true,
    ),
    NearbyUser(
      id: '5',
      name: 'Charlotte',
      age: 27,
      distance: 4.2,
      imageUrl: 'https://i.pravatar.cc/100?img=5',
      location: const LatLng(37.7889, -122.4054),
      isOnline: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Use demo location (San Francisco)
        _currentPosition = Position(
          latitude: 37.7849,
          longitude: -122.4094,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        try {
          _currentPosition = await Geolocator.getCurrentPosition();
        } catch (e) {
          // Fallback to demo location
          _currentPosition = Position(
            latitude: 37.7849,
            longitude: -122.4094,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }

      _createMarkers();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Use demo location
      _currentPosition = Position(
        latitude: 37.7849,
        longitude: -122.4094,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      _createMarkers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createMarkers() {
    _markers.clear();

    // Add current location marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'You are here',
            snippet: 'Your current location',
          ),
        ),
      );
    }

    // Add nearby users markers
    for (var user in _nearbyUsers) {
      _markers.add(
        Marker(
          markerId: MarkerId(user.id),
          position: user.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            user.isOnline ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: '${user.name}, ${user.age}',
            snippet: '${user.distance} km away',
          ),
          onTap: () => _showUserBottomSheet(user),
        ),
      );
    }
  }

  void _showUserBottomSheet(NearbyUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage: NetworkImage(user.imageUrl),
                    ),
                    if (user.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}, ${user.age}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${user.distance} km away',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (user.isOnline)
                        Text(
                          'Online now',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.showSuccessSnackBar('Like sent to ${user.name}!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: const Icon(Icons.favorite, color: Colors.white),
                    label: Text(
                      'Like',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.showSnackBar('Profile viewed');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.person, color: AppColors.primary),
                    label: Text(
                      'View Profile',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Nearby Matches',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.showSnackBar('Refreshing nearby users...');
              _getCurrentLocation();
            },
            icon: Icon(
              Icons.refresh,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(37.7849, -122.4094),
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                
                // Floating action button for current location
                Positioned(
                  bottom: 100.h,
                  right: 16.w,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (_currentPosition != null && _mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          ),
                        );
                      }
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),

                // Bottom sheet with nearby users list
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            'Nearby (${_nearbyUsers.length})',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: _nearbyUsers.length,
                            itemBuilder: (context, index) {
                              final user = _nearbyUsers[index];
                              return GestureDetector(
                                onTap: () => _showUserBottomSheet(user),
                                child: Container(
                                  width: 60.w,
                                  margin: EdgeInsets.only(right: 12.w),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 25.r,
                                            backgroundImage: NetworkImage(user.imageUrl),
                                          ),
                                          if (user.isOnline)
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: 12.w,
                                                height: 12.h,
                                                decoration: BoxDecoration(
                                                  color: AppColors.success,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 2),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class NearbyUser {
  final String id;
  final String name;
  final int age;
  final double distance;
  final String imageUrl;
  final LatLng location;
  final bool isOnline;

  const NearbyUser({
    required this.id,
    required this.name,
    required this.age,
    required this.distance,
    required this.imageUrl,
    required this.location,
    required this.isOnline,
  });
}