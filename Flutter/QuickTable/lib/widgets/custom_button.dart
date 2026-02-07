import 'package:flutter/material.dart';
import '../helpers/responsive.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double height = Responsive.isMobile(context) ? 50 : 60;
    double fontSize = Responsive.isMobile(context) ? 18 : 22;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: fontSize)),
      ),
    );
  }
}
