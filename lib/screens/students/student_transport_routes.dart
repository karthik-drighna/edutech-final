import 'dart:convert';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:drighna_ed_tech/widgets/pencil_loader/page/pencil_loader_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drighna_ed_tech/models/transport_route_model.dart';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/transport_route_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentTransportRoutes extends StatefulWidget {
  const StudentTransportRoutes({super.key});

  @override
  _StudentTransportRoutesState createState() => _StudentTransportRoutesState();
}

class _StudentTransportRoutesState extends State<StudentTransportRoutes> {
  bool isLoading = false;
  TransportRoute? transportData; // Made nullable

  @override
  void initState() {
    super.initState();
    fetchTransportData();
  }

  Future<void> fetchTransportData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('studentId') ?? '';
    String apiUrl = prefs.getString('apiUrl') ?? '';
    String url = "$apiUrl${Constants.getTransportRouteListUrl}";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Client-Service": Constants.clientService,
          "Auth-Key": Constants.authKey,
          "Content-Type": "application/json",
          "User-ID": prefs.getString('userId') ?? '',
          "Authorization": prefs.getString('accessToken') ?? '',
        },
        body: jsonEncode({"student_id": studentId}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        // Create a list of PickupPoint from the 'pickup_point' part of the result
        List<dynamic> pickupPointsJson = result['pickup_point'];
        List<PickupPoint> pickupPoints = pickupPointsJson
            .map((pickupJson) => PickupPoint.fromJson(pickupJson))
            .toList();

        // Create TransportRoute from the 'route' part of the result
        TransportRoute route = TransportRoute.fromJson(
            result['route'] as Map<String, dynamic>, pickupPoints);

        setState(() {
          isLoading = false;
          transportData = route;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e); 
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.transport_routes,
      ),
      body: isLoading
          ? const Center(child: PencilLoaderProgressBar())
          : SingleChildScrollView(
              child: transportData != null
                  ? TransportRouteCard(
                      route:
                          transportData!) // Check for null before using the object
                  : const Center(child: Text('No route data available')),
            ),
    );
  }
}
