import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'dart:typed_data';
import '../../../home/domain/entities/branch_entity.dart';
import '../../../../core/constants/maps_constants.dart';
import '../../../../core/utils/url_utils.dart';

class BranchesMapPage extends StatefulWidget {
  final List<BranchEntity> branches;

  const BranchesMapPage({
    super.key,
    required this.branches,
  });

  @override
  State<BranchesMapPage> createState() => _BranchesMapPageState();
}

class _BranchesMapPageState extends State<BranchesMapPage> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // فلترة الفروع التي لها إحداثيات
    final branchesWithLocation = widget.branches
        .where((b) => b.latitude != null && b.longitude != null)
        .toList();

    if (branchesWithLocation.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'no_branches_with_location'.tr();
      });
      return;
    }

    // محاولة الحصول على موقع المستخدم
    await _getUserLocation();

    // إنشاء الماركرز
    await _createMarkers(branchesWithLocation);

    // تحديد المركز الأولي للخريطة
    _setInitialCameraPosition(branchesWithLocation);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // التحقق من الأذونات
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // الحصول على الموقع
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _createMarkers(List<BranchEntity> branches) async {
    final Set<Marker> markers = {};

    for (final branch in branches) {
      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

      // محاولة تحميل coverImage كلوجو للماركر
      if (branch.coverImage != null && branch.coverImage!.isNotEmpty) {
        try {
          icon = await _createMarkerIconFromNetwork(branch.coverImage!);
        } catch (e) {
          print('Error loading marker icon for branch ${branch.id}: $e');
          // استخدام الماركر الافتراضي في حالة الخطأ
        }
      }

      markers.add(
        Marker(
          markerId: MarkerId(branch.id),
          position: LatLng(branch.latitude!, branch.longitude!),
          icon: icon,
          infoWindow: InfoWindow(
            title: context.locale.languageCode == 'ar'
                ? branch.nameAr
                : branch.nameEn,
            snippet: branch.location,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/branch-details',
                arguments: {'branchId': branch.id},
              );
            },
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<BitmapDescriptor> _createMarkerIconFromNetwork(String imageUrl) async {
    try {
      final String fullUrl = resolveFileUrl(imageUrl);
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        return BitmapDescriptor.fromBytes(
          imageBytes,
          size: Size(MapsConstants.markerSize, MapsConstants.markerSize),
        );
      }
    } catch (e) {
      print('Error creating marker icon: $e');
    }

    return BitmapDescriptor.defaultMarker;
  }

  void _setInitialCameraPosition(List<BranchEntity> branches) {
    if (_userPosition != null) {
      // إذا كان لدينا موقع المستخدم، استخدمه كمركز
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_userPosition!.latitude, _userPosition!.longitude),
          MapsConstants.defaultZoom,
        ),
      );
    } else if (branches.isNotEmpty) {
      // حساب المركز المتوسط للفروع
      final avgLat = branches
              .map((b) => b.latitude!)
              .reduce((a, b) => a + b) /
          branches.length;
      final avgLng = branches
              .map((b) => b.longitude!)
              .reduce((a, b) => a + b) /
          branches.length;

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(avgLat, avgLng),
          branches.length == 1
              ? MapsConstants.singleBranchZoom
              : MapsConstants.defaultZoom,
        ),
      );
    }
  }

  void _centerOnUserLocation() async {
    if (_userPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_userPosition!.latitude, _userPosition!.longitude),
          MapsConstants.defaultZoom,
        ),
      );
    } else {
      await _getUserLocation();
      if (_userPosition != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_userPosition!.latitude, _userPosition!.longitude),
            MapsConstants.defaultZoom,
          ),
        );
      }
    }
  }

  void _navigateToHome() {
    // الرجوع إلى الصفحة السابقة
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('branches_map'.tr()),
          leading: IconButton(
            icon: Icon(
              context.locale.languageCode == 'ar'
                  ? Iconsax.arrow_right_3
                  : Iconsax.arrow_left_2,
            ),
            onPressed: _navigateToHome,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('branches_map'.tr()),
          leading: IconButton(
            icon: Icon(
              context.locale.languageCode == 'ar'
                  ? Iconsax.arrow_right_3
                  : Iconsax.arrow_left_2,
            ),
            onPressed: _navigateToHome,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMessage!),
            ],
          ),
        ),
      );
    }

    final branchesWithLocation = widget.branches
        .where((b) => b.latitude != null && b.longitude != null)
        .toList();

    // حساب المركز الافتراضي
    final defaultLat = branchesWithLocation
            .map((b) => b.latitude!)
            .reduce((a, b) => a + b) /
        branchesWithLocation.length;
    final defaultLng = branchesWithLocation
            .map((b) => b.longitude!)
            .reduce((a, b) => a + b) /
        branchesWithLocation.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('branches_map'.tr()),
        leading: IconButton(
          icon: Icon(
            context.locale.languageCode == 'ar'
                ? Iconsax.arrow_right_3
                : Iconsax.arrow_left_2,
          ),
          onPressed: _navigateToHome,
        ),
        actions: [
          if (_userPosition != null || _isLoadingLocation)
            IconButton(
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              onPressed: _centerOnUserLocation,
              tooltip: 'my_location'.tr(),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(defaultLat, defaultLng),
              zoom: branchesWithLocation.length == 1
                  ? MapsConstants.singleBranchZoom
                  : MapsConstants.defaultZoom,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // سنستخدم زر مخصص
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // تأخير بسيط لضمان تحميل الماركرز
              Future.delayed(const Duration(milliseconds: 500), () {
                _setInitialCameraPosition(branchesWithLocation);
              });
            },
          ),
        ],
      ),
    );
  }
}

