import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  static Future<String> getUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Location services disabled";
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return "Permission denied";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return "Permission permanently denied";
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert to city name
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          return "${place.locality ?? place.subAdministrativeArea ?? 'Unknown'}, ${place.country ?? ''}";
        } else {
          return "Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}";
        }
      } catch (e) {
        return "Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}";
      }

    } catch (e) {
      return "Error getting location";
    }
  }

  // Stream method for continuous location updates
  static Stream<String> getLocationStream() async* {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      yield "Location services disabled";
      return;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        yield "Permission denied";
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      yield "Permission permanently denied";
      return;
    }

    // Listen to position stream
    Stream<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    );

    String? lastLocation; // Cache last successful location

    // Convert each position to location name
    await for (Position position in positionStream) {
      try {
        // Add a small delay to avoid rate limiting
        await Future.delayed(Duration(milliseconds: 500));

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          Duration(seconds: 5),
          onTimeout: () => throw Exception("Geocoding timeout"),
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          String locality = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'Unknown';

          String country = place.country ?? '';

          String locationName = "$locality${country.isNotEmpty ? ', $country' : ''}";

          lastLocation = locationName;
          yield locationName;
        } else {
          if (lastLocation != null) {
            yield lastLocation!;
          } else {
            yield "Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}";
          }
        }
      } catch (e) {
        if (lastLocation != null) {
          yield lastLocation!;
        } else {
          yield "Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}";
        }
      }
    }
  }

  // Get detailed location information including coordinates
  static Future<Map<String, String>> getDetailedLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {"error": "Location services disabled"};
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {"error": "Permission denied"};
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {"error": "Permission permanently denied"};
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(Duration(seconds: 5));

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          return {
            "street": place.street ?? "",
            "subLocality": place.subLocality ?? "",
            "locality": place.locality ?? "",
            "subAdministrativeArea": place.subAdministrativeArea ?? "",
            "administrativeArea": place.administrativeArea ?? "",
            "postalCode": place.postalCode ?? "",
            "country": place.country ?? "",
            "latitude": position.latitude.toStringAsFixed(5),
            "longitude": position.longitude.toStringAsFixed(5),
          };
        } else {
          return {
            "latitude": position.latitude.toStringAsFixed(5),
            "longitude": position.longitude.toStringAsFixed(5),
          };
        }
      } catch (e) {
        return {
          "latitude": position.latitude.toStringAsFixed(5),
          "longitude": position.longitude.toStringAsFixed(5),
        };
      }
    } catch (e) {
      return {"error": "Error getting location: $e"};
    }
  }
}