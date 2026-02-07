import 'package:flutter/widgets.dart';

class Responsive {
  static double wp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * percent / 100;
  }

  static double hp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * percent / 100;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
}
