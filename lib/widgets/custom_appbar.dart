import 'package:drighna_ed_tech/main.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final titleText;
  final List<Widget>? actions;
  final LinearGradient? backgroundGradient; // Allow it to be null
  final Color titleColor;
  final IconButton? iconButtonLeading;

  CustomAppBar({
    super.key,
    required this.titleText,
    this.actions,
    this.iconButtonLeading,
    LinearGradient? backgroundGradient, // Accept it as nullable
    this.titleColor = Colors.white,
  }) : backgroundGradient = backgroundGradient ??
            ThemeData().appGradient; // Set here if not provided

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: AppBar(
        centerTitle: true,
        leading: iconButtonLeading,
        automaticallyImplyLeading: false,
        title: titleText.runtimeType == String
            ? Text(
                titleText,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
              )
            : titleText,
        actions: actions,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: backgroundGradient,
          ),
        ),
        backgroundColor:
            Colors.transparent, // Ensure AppBar background is transparent
        elevation: 0, // No shadow
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
      kToolbarHeight + 80); // Adjusted height for the custom AppBar
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20); // Start from the top left corner

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0); // Go to the top right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
