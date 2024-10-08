import 'package:flutter/material.dart';

class StudentDetailCard extends StatelessWidget {
  final String leading;
  final String trailing;
  final bool isAddress;

  const StudentDetailCard({
    required this.leading,
    required this.trailing,
    this.isAddress = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isAddress
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leading,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trailing,
                    style: const TextStyle(),
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    leading,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      softWrap: true,
                      trailing,
                      style: const TextStyle(),
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
