import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/api_config.dart';
import '../../data/models/kitchen_map_dto.dart';

class KitchensMapPage extends StatefulWidget {
  const KitchensMapPage({super.key});

  @override
  State<KitchensMapPage> createState() => _KitchensMapPageState();
}

class _KitchensMapPageState extends State<KitchensMapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Dio _dio = Dio();

  Set<Marker> _markers = {};
  List<KitchenMapDto> _kitchens = [];

  static const LatLng _defaultCenter = LatLng(10.3932, -75.4794);

  @override
  void initState() {
    super.initState();
    _loadKitchens();
  }

  Future<void> _loadKitchens() async {
    final response = await _dio.get("${ApiConfig.baseUrl}/cocinas/map");

    _kitchens = (response.data as List)
        .map((item) => KitchenMapDto.fromJson(item))
        .toList();

    _addMarkers();
  }

  void _addMarkers() {
    Set<Marker> markers = {};

    for (final kitchen in _kitchens) {
      markers.add(
        Marker(
          markerId: MarkerId(kitchen.id.toString()),
          position: LatLng(kitchen.latitud, kitchen.longitud),
          infoWindow: InfoWindow(
            title: kitchen.nombre,
            snippet: "Tap para ver detalles",
          ),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de cocinas"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultCenter,
          zoom: 13,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadKitchens,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
