import 'package:flutter/material.dart';
import 'package:drighna_ed_tech/models/transport_route_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransportRouteCard extends StatefulWidget {
  final TransportRoute route;

  const TransportRouteCard({super.key, required this.route});

  @override
  State<TransportRouteCard> createState() => _TransportRouteCardState();
}

class _TransportRouteCardState extends State<TransportRouteCard> {
  String vehicleImage = "";
  @override
  void initState() {
    super.initState();
    _initializeBimgUrl();
  }

  Future<void> _initializeBimgUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String imagesUrl = prefs.getString("imagesUrl") ?? '';

    setState(() {
      vehicleImage =
          "$imagesUrl/uploads/vehicle_photo/${widget.route.vehiclePhoto}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.route.vehiclePhoto.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  vehicleImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              '${AppLocalizations.of(context)!.route_title}: ${widget.route.routeTitle}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(AppLocalizations.of(context)!.vehicle_number,
                widget.route.vehicleNumber),
            _buildInfoRow(AppLocalizations.of(context)!.vehicle_model,
                widget.route.vehicleModel),
            _buildInfoRow(AppLocalizations.of(context)!.driver_name,
                widget.route.driverName),
            _buildInfoRow(AppLocalizations.of(context)!.driver_contact,
                widget.route.driverContact),
            _buildInfoRow(AppLocalizations.of(context)!.driver_license,
                widget.route.driverLicence),
            _buildInfoRow(
                AppLocalizations.of(context)!.made, widget.route.made),
            const Divider(height: 20.0),
            Text(
              '${AppLocalizations.of(context)!.pickup_points}:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ...widget.route.pickupPoints
                .map((pickup) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        color: const Color.fromARGB(255, 18, 192, 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pickup.pickupPoint,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  const Icon(Icons.straighten,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Distance:               ${pickup.destinationDistance} km',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Pickup Time:         ${pickup.pickupTime}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 30.0),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
