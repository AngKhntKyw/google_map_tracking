import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_tracking/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  // static const LatLng sourceLocation = LatLng(16.8380012, 96.1209507);
  static const LatLng destination = LatLng(16.8440761, 96.1289329);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLoactionIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (value) {
        setState(() {
          currentLocation = value;
          log(currentLocation.toString());
        });
      },
    );
    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLocation) {
        setState(() {
          log(newLocation.toString());

          currentLocation = newLocation;
          // googleMapController.animateCamera(
          //   CameraUpdate.newCameraPosition(
          //     CameraPosition(
          //       zoom: 15,
          //       target: LatLng(
          //         newLocation.latitude!,
          //         newLocation.longitude!,
          //       ),
          //     ),
          //   ),
          // );
          getPolyPoints();
        });
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: google_api_key,
      request: PolylineRequest(
        origin: PointLatLng(
            currentLocation!.latitude!, currentLocation!.longitude!),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();

      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
      setState(() {});
    }
  }

  void setCutomMarkerIcon() async {
    BitmapDescriptor.asset(ImageConfiguration.empty, 'assets/Pin_source.png')
        .then(
      (value) {
        sourceIcon = value;
      },
    );
    BitmapDescriptor.asset(
            ImageConfiguration.empty, 'assets/Pin_destination.png')
        .then(
      (value) {
        destinationIcon = value;
      },
    );
    BitmapDescriptor.asset(ImageConfiguration.empty, 'assets/Badge.png').then(
      (value) {
        currentLoactionIcon = value;
      },
    );
  }

  @override
  void initState() {
    getCurrentLocation();
    setCutomMarkerIcon();
    // getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentLocation == null
            ? "Loading..."
            : "Lat:${currentLocation!.latitude!} & Lng:${currentLocation!.longitude!}"),
      ),
      body: currentLocation == null
          ? const Center(child: Text("Loading..."))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 15,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: polylineCoordinates,
                  color: primaryColor,
                  width: 6,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                  icon: currentLoactionIcon,
                ),
                // Marker(
                //   markerId: const MarkerId('source'),
                //   position: sourceLocation,
                //   icon: sourceIcon,
                // ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                  icon: destinationIcon,
                ),
              },
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
            ),
    );
  }
}
