import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../utils/const.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Coordonnées de l'université (MGRR+6HW, Av. Cheikh Anta Diop, Dakar)
  static const LatLng _universityLocation = LatLng(14.6928, -17.4467);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Demander les permissions de localisation
      bool hasPermission = await LocationService.requestLocationPermission();
      
      if (!hasPermission) {
        setState(() {
          _hasLocationPermission = false;
          _isLoading = false;
        });
        _showPermissionDialog();
        return;
      }

      setState(() {
        _hasLocationPermission = true;
      });

      // Obtenir la position actuelle
      Position? position = await LocationService.getCurrentPosition();
      
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
        
        _setupMarkers();
        _drawRoute();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Erreur lors de l\'initialisation de la localisation: $e');
    }
  }

  void _setupMarkers() {
    _markers.clear();

    // Marqueur pour la position actuelle
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Ma position',
            snippet: 'Vous êtes ici',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Marqueur pour l'université
    _markers.add(
      const Marker(
        markerId: MarkerId('university'),
        position: _universityLocation,
        infoWindow: InfoWindow(
          title: 'Université',
          snippet: 'MGRR+6HW, Av. Cheikh Anta Diop, Dakar',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );

    setState(() {});
  }

  void _drawRoute() {
    if (_currentPosition == null) return;

    // Créer une ligne simple entre la position actuelle et l'université
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route_to_university'),
        points: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _universityLocation,
        ],
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );

    setState(() {});
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'Cette application a besoin d\'accéder à votre localisation pour vous guider vers l\'université. '
            'Veuillez autoriser l\'accès à la localisation dans les paramètres.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeLocation();
              },
              child: const Text('Réessayer'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Centrer la carte sur la position actuelle ou l'université
    if (_currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _currentPosition!.latitude < _universityLocation.latitude 
                  ? _currentPosition!.latitude 
                  : _universityLocation.latitude,
              _currentPosition!.longitude < _universityLocation.longitude 
                  ? _currentPosition!.longitude 
                  : _universityLocation.longitude,
            ),
            northeast: LatLng(
              _currentPosition!.latitude > _universityLocation.latitude 
                  ? _currentPosition!.latitude 
                  : _universityLocation.latitude,
              _currentPosition!.longitude > _universityLocation.longitude 
                  ? _currentPosition!.longitude 
                  : _universityLocation.longitude,
            ),
          ),
          100.0,
        ),
      );
    } else {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_universityLocation, 15),
      );
    }
  }

  void _centerOnCurrentLocation() async {
    if (_mapController != null && _currentPosition != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          16,
        ),
      );
    }
  }

  void _centerOnUniversity() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_universityLocation, 16),
      );
    }
  }

  String _getDistanceText() {
    if (_currentPosition == null) return '';
    
    double distance = LocationService.calculateDistanceToUniversity(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinéraire vers l\'université'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement de la carte...'),
                ],
              ),
            )
          : !_hasLocationPermission
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Permission de localisation requise',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Veuillez autoriser l\'accès à la localisation\npour utiliser cette fonctionnalité.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _initializeLocation,
                        child: const Text('Autoriser la localisation'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                            : _universityLocation,
                        zoom: 15,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
                    
                    // Informations sur la distance
                    if (_currentPosition != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.school, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Distance vers l\'université',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _getDistanceText(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Boutons de contrôle
                    Positioned(
                      bottom: 100,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: "center_location",
                            onPressed: _centerOnCurrentLocation,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.my_location, color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: "center_university",
                            onPressed: _centerOnUniversity,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.school, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      
      // Bouton d'action principal
      floatingActionButton: _hasLocationPermission && _currentPosition != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Ici vous pouvez ajouter la logique pour démarrer la navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigation vers l\'université démarrée'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.directions),
              label: const Text('Démarrer'),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}