import 'package:drighna_ed_tech/models/hostel_model.dart';
import 'package:flutter/material.dart';

class HostelListItem extends StatelessWidget {
  final Hostel hostel;

  const HostelListItem({super.key, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hostel.hostelName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  hostel.assign == "1" ? "Assigned" : "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 4, 185, 55),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Room Type', hostel.roomType),
            _buildInfoRow('Room No', hostel.roomNo),
            _buildInfoRow('Beds', hostel.noOfBed.toString()),
            _buildInfoRow('Cost per Bed', hostel.costPerBed),
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
          const SizedBox(width: 5.0),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
