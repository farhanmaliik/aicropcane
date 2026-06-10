// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import 'package:framerapp/utils/appcolors.dart';

class NearbyStore {
  final String name;
  final String type;
  final double lat;
  final double lon;
  final String? address;
  final String? phone;
  final String? opening_hours;
  double distanceKm;

  NearbyStore({
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    this.address,
    this.phone,
    this.opening_hours,
    this.distanceKm = 0.0,
  });

  factory NearbyStore.fromOverpassElement(Map<String, dynamic> el) {
    final tags = el['tags'] as Map<String, dynamic>? ?? {};
    final shop = tags['shop'] as String? ?? '';
    final landuse = tags['landuse'] as String? ?? '';
    final office = tags['office'] as String? ?? '';
    final amenity = tags['amenity'] as String? ?? '';

    String type = 'Other';
    if (shop == 'garden_centre' ||
        shop == 'garden_center' ||
        landuse == 'plant_nursery') {
      type = 'Garden Centre / Nursery';
    } else if (shop == 'agrarian' || shop == 'farm_supply') {
      type = 'Agro / Farm Supply';
    } else if (office.isNotEmpty || amenity == 'public_building') {
      // Agriculture-related government / extension offices & associations
      type = 'Agri Office / Expert';
    } else {
      // Skip unrelated (human pharmacy, florist, etc.) place types
      type = 'Other';
    }

    String? address;
    final street = tags['addr:street'];
    final housenumber = tags['addr:housenumber'];
    final city = tags['addr:city'];
    if (street != null || city != null) {
      address = [
        if (housenumber != null) housenumber,
        if (street != null) street,
        if (city != null) city,
      ].join(', ');
    }

    return NearbyStore(
      name: tags['name'] as String? ?? 'Unnamed Store',
      type: type,
      lat: (el['lat'] as num).toDouble(),
      lon: (el['lon'] as num).toDouble(),
      address: address,
      phone: tags['phone'] as String?,
      opening_hours: tags['opening_hours'] as String?,
    );
  }
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _deg2rad(double deg) => deg * (pi / 180);

class NearbyStoresScreen extends StatefulWidget {
  const NearbyStoresScreen({super.key});

  @override
  State<NearbyStoresScreen> createState() => _NearbyStoresScreenState();
}

class _NearbyStoresScreenState extends State<NearbyStoresScreen> {
  List<NearbyStore> _stores = [];
  bool _loading = true;
  String? _error;
  double? _userLat;
  double? _userLon;
  String _userCity = '';

  // search radius in metres (covers a full city e.g. Faisalabad ~30 km across)
  static const int _radiusM = 30000;
  // radius shown in the UI, in km
  static const int _radiusKm = _radiusM ~/ 1000;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _loading = true;
      _error = null;
      _stores = [];
    });

    try {
      // 1. Get location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Please enable GPS.';
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied.';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Location permission permanently denied. Please enable it in app settings.';
          _loading = false;
        });
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _userLat = pos.latitude;
      _userLon = pos.longitude;
      _userCity = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';

      // 2. Query Overpass for nearby plant/agro/pharmacy stores
      final stores = await _fetchNearbyStores(pos.latitude, pos.longitude);

      setState(() {
        _stores = stores;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load stores: $e';
        _loading = false;
      });
    }
  }

  Future<List<NearbyStore>> _fetchNearbyStores(
      double lat, double lon) async {
    // Overpass QL query – finds plant & agriculture related supply stores,
    // nurseries, and agricultural offices/experts within _radiusM metres.
    // (nwr = node + way + relation; human pharmacies/florists are excluded.)
    final query = '''
[out:json][timeout:60];
(
  // Agro & farm supply stores (seeds, pesticides, fertilizers)
  nwr["shop"="agrarian"](around:$_radiusM,$lat,$lon);
  nwr["shop"="farm_supply"](around:$_radiusM,$lat,$lon);
  // Garden centres & plant nurseries
  nwr["shop"="garden_centre"](around:$_radiusM,$lat,$lon);
  nwr["shop"="garden_center"](around:$_radiusM,$lat,$lon);
  nwr["landuse"="plant_nursery"](around:$_radiusM,$lat,$lon);
  // Agriculture-related offices / extension services / experts
  nwr["office"]["name"~"agri|agricultur|zarai|krishi|extension|seed|fertil",i](around:$_radiusM,$lat,$lon);
  nwr["amenity"="public_building"]["name"~"agri|agricultur|zarai|krishi|extension",i](around:$_radiusM,$lat,$lon);
);
out center;
''';

    // Try multiple Overpass API mirrors for reliability
    final endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    ];

    http.Response? response;
    for (final endpoint in endpoints) {
      try {
        final r = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'User-Agent': 'AiCropCane/1.0 (Flutter crop disease detection app)',
          },
          body: 'data=${Uri.encodeComponent(query)}',
        ).timeout(const Duration(seconds: 45));
        if (r.statusCode == 200) {
          response = r;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (response == null || response.statusCode != 200) {
      throw Exception(
          'Overpass API error (${response?.statusCode ?? "no response"}): Unable to reach any server. Check your internet connection.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>? ?? [];

    final List<NearbyStore> stores = [];
    for (final el in elements) {
      final elMap = el as Map<String, dynamic>;
      final tags = elMap['tags'] as Map<String, dynamic>? ?? {};
      if (tags.isEmpty) continue;

      double elLat;
      double elLon;
      final center = elMap['center'] as Map<String, dynamic>?;
      if (center != null) {
        // ways & relations carry a 'center' field
        elLat = (center['lat'] as num).toDouble();
        elLon = (center['lon'] as num).toDouble();
      } else if (elMap['lat'] != null && elMap['lon'] != null) {
        elLat = (elMap['lat'] as num).toDouble();
        elLon = (elMap['lon'] as num).toDouble();
      } else {
        continue;
      }

      final store = NearbyStore.fromOverpassElement({
        ...elMap,
        'lat': elLat,
        'lon': elLon,
      });
      if (store.type == 'Other') continue; // skip unrecognised store types
      store.distanceKm = _haversineKm(lat, lon, elLat, elLon);
      stores.add(store);
    }

    stores.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return stores;
  }

  void _openMaps(NearbyStore store) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${store.lat},${store.lon}';
    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  void _callPhone(String phone) async {
    final url = 'tel:$phone';
    try {
      await launchUrlString(url);
    } catch (_) {}
  }

  IconData _typeIcon(String type) {
    if (type.contains('Garden') || type.contains('Nursery')) {
      return Icons.local_florist;
    }
    if (type.contains('Agro') || type.contains('Farm')) return Icons.agriculture;
    if (type.contains('Office') || type.contains('Expert')) {
      return Icons.support_agent;
    }
    return Icons.store;
  }

  Color _typeColor(String type) {
    if (type.contains('Garden') || type.contains('Nursery')) return Colors.green;
    if (type.contains('Agro') || type.contains('Farm')) return const Color(0xFF795548);
    if (type.contains('Office') || type.contains('Expert')) return Colors.teal;
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Nearby Agri Stores & Experts',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (!_loading)
            IconButton(
              onPressed: _loadStores,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Finding nearby stores...',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadStores,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_stores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, size: 72, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'No stores found nearby',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No agriculture stores, nurseries, or experts were found within $_radiusKm km of your location.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final url =
                      'https://www.google.com/maps/search/agricultural+stores+near+me';
                  try {
                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Search on Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header info strip
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: primaryColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Within $_radiusKm km • ${_stores.length} place${_stores.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _stores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _buildStoreCard(_stores[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(NearbyStore store) {
    final color = _typeColor(store.type);
    final distText = store.distanceKm < 1
        ? '${(store.distanceKm * 1000).round()} m'
        : '${store.distanceKm.toStringAsFixed(1)} km';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon(store.type), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          store.type,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Distance badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.near_me, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        distText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (store.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      store.address!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (store.opening_hours != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      store.opening_hours!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMaps(store),
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Navigate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (store.phone != null) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _callPhone(store.phone!),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
